import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:promptly/in_app_purchase/iap_config.dart';
import 'package:promptly/in_app_purchase/purchase_repository.dart';
import 'package:promptly/services/google_ads_material/ads_variable.dart';
import 'package:promptly/utils/auth_repository.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

/// Event-driven SUBSCRIPTION state machine over [PurchaseRepository].
/// App-lifetime singleton (registered in get_it). Mirrors subscription status
/// into [AdsVariable] so the rest of the GetX/Obx app keeps reacting unchanged.
///
/// Credits are NOT tracked here — they live on the backend ([AuthRepository]).
/// A successful purchase grants credits via [AuthRepository.addCredits].
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseRepository _repo;
  StreamSubscription<bool>? _entitlementSub;

  PurchaseBloc(this._repo) : super(const PurchaseState.initial()) {
    on<PurchaseStarted>(_onStarted);
    on<SubscriptionPurchaseRequested>(_onSubscription);
    on<CreditPackPurchaseRequested>(_onCreditPack);
    on<PurchasesRestoreRequested>(_onRestore);
    on<EntitlementChanged>(_onEntitlementChanged);
    on<DebugSimulateSubscription>(_onDebugSimulate);

    _entitlementSub =
        _repo.entitlementChanges().listen((active) => add(EntitlementChanged(active)));
  }

  // ── Bridge ─────────────────────────────────────────────────────────────────
  // Keep legacy AdsVariable.isPurchase readers (Obx) in sync with every change.
  @override
  void onChange(Change<PurchaseState> change) {
    super.onChange(change);
    AdsVariable.isPurchase.value = change.nextState.isSubscribed;
  }

  // ── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _onStarted(PurchaseStarted e, Emitter<PurchaseState> emit) async {
    try {
      final active = await _repo.isEntitlementActive(forceRefresh: true);
      emit(state.copyWith(isSubscribed: active, status: PurchaseStatus.idle));
    } catch (e, st) {
      FirebaseCrashlytics.instance
          .recordError(e, st, reason: 'PurchaseStarted failed', fatal: false);
    }
  }

  Future<void> _onSubscription(
    SubscriptionPurchaseRequested e,
    Emitter<PurchaseState> emit,
  ) async {
    // Already entitled → nothing to buy. Treat as success; this also avoids
    // Play's "unable to change subscription plan" error on a re-purchase tap.
    if (state.isSubscribed) {
      emit(state.copyWith(status: PurchaseStatus.success));
      return;
    }

    emit(state.copyWith(status: PurchaseStatus.loading));
    try {
      final active = await _repo.purchaseSubscription(e.package);
      if (!active) {
        FirebaseCrashlytics.instance.recordError(
          'Purchase ok but entitlement "${IapConfig.entitlementKey}" inactive',
          StackTrace.current,
          reason: 'subscription entitlement mismatch',
          fatal: false,
        );
        emit(state.copyWith(
          status: PurchaseStatus.error,
          error: 'Purchase completed but could not be verified. Try Restore Purchases.',
        ));
        return;
      }
      // Grant the subscription bonus credits on the backend.
      final bonus = e.package.packageType == PackageType.annual
          ? IapConfig.yearlyCredits
          : IapConfig.monthlyCredits;
      await AuthRepository().addCredits(bonus);
      emit(state.copyWith(isSubscribed: true, status: PurchaseStatus.success));
    } on PlatformException catch (ex) {
      if (PurchasesErrorHelper.getErrorCode(ex) ==
          PurchasesErrorCode.purchaseCancelledError) {
        emit(state.copyWith(status: PurchaseStatus.cancelled));
        return;
      }
      // Store rejected the purchase (e.g. "can't change plan" because the
      // account already owns this sub). If the entitlement is in fact active,
      // recognise it as success instead of surfacing the raw store error.
      try {
        if (await _repo.isEntitlementActive(forceRefresh: true)) {
          emit(state.copyWith(isSubscribed: true, status: PurchaseStatus.success));
          return;
        }
      } catch (_) {}
      emit(_fromStoreError(ex));
    } catch (ex) {
      emit(state.copyWith(status: PurchaseStatus.error, error: ex.toString()));
    }
  }

  Future<void> _onCreditPack(
    CreditPackPurchaseRequested e,
    Emitter<PurchaseState> emit,
  ) async {
    emit(state.copyWith(status: PurchaseStatus.loading));
    try {
      await _repo.purchaseCreditProduct(e.productId);
      // Credit the backend; the UI reads the fresh balance from AuthRepository.
      await AuthRepository().addCredits(e.creditsToAdd);
      emit(state.copyWith(status: PurchaseStatus.success));
    } on PlatformException catch (e) {
      emit(_fromStoreError(e));
    } catch (e) {
      emit(state.copyWith(status: PurchaseStatus.error, error: e.toString()));
    }
  }

  Future<void> _onRestore(
    PurchasesRestoreRequested e,
    Emitter<PurchaseState> emit,
  ) async {
    emit(state.copyWith(status: PurchaseStatus.loading));
    try {
      final active = await _repo.restore();
      emit(state.copyWith(
        isSubscribed: active,
        status: active ? PurchaseStatus.success : PurchaseStatus.error,
        error: active ? null : 'No active subscription found',
      ));
    } catch (e) {
      emit(state.copyWith(status: PurchaseStatus.error, error: e.toString()));
    }
  }

  void _onEntitlementChanged(EntitlementChanged e, Emitter<PurchaseState> emit) {
    emit(state.copyWith(isSubscribed: e.isActive, status: PurchaseStatus.idle));
  }

  /// Debug-only — marks subscribed and grants bonus credits on the backend.
  Future<void> _onDebugSimulate(
    DebugSimulateSubscription e,
    Emitter<PurchaseState> emit,
  ) async {
    await AuthRepository().addCredits(e.bonusCredits);
    emit(state.copyWith(isSubscribed: true, status: PurchaseStatus.success));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  PurchaseState _fromStoreError(PlatformException e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    if (code == PurchasesErrorCode.purchaseCancelledError) {
      return state.copyWith(status: PurchaseStatus.cancelled);
    }
    return state.copyWith(
      status: PurchaseStatus.error,
      error: e.message ?? 'Purchase failed',
    );
  }

  @override
  Future<void> close() {
    _entitlementSub?.cancel();
    return super.close();
  }
}
