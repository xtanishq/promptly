part of 'purchase_bloc.dart';

sealed class PurchaseEvent extends Equatable {
  const PurchaseEvent();
  @override
  List<Object?> get props => [];
}

/// Hydrate subscription + credit state at startup (forces a fresh fetch).
class PurchaseStarted extends PurchaseEvent {
  const PurchaseStarted();
}

/// User tapped subscribe on a specific package.
class SubscriptionPurchaseRequested extends PurchaseEvent {
  final Package package;
  const SubscriptionPurchaseRequested(this.package);
  @override
  List<Object?> get props => [package.identifier];
}

/// User tapped buy on a one-time credit pack.
class CreditPackPurchaseRequested extends PurchaseEvent {
  final String productId;
  final int creditsToAdd;
  const CreditPackPurchaseRequested(this.productId, this.creditsToAdd);
  @override
  List<Object?> get props => [productId, creditsToAdd];
}

/// Spend credits for a gated action (Copy / Generate).
class CreditSpent extends PurchaseEvent {
  final int amount;
  const CreditSpent(this.amount);
  @override
  List<Object?> get props => [amount];
}

/// Grant credits directly (used by restore bonuses / debug simulate).
class CreditsGranted extends PurchaseEvent {
  final int amount;
  const CreditsGranted(this.amount);
  @override
  List<Object?> get props => [amount];
}

/// User tapped "Restore Purchases".
class PurchasesRestoreRequested extends PurchaseEvent {
  const PurchasesRestoreRequested();
}

/// Internal — RevenueCat pushed a customer-info change.
class EntitlementChanged extends PurchaseEvent {
  final bool isActive;
  const EntitlementChanged(this.isActive);
  @override
  List<Object?> get props => [isActive];
}

/// Debug-only — simulate a successful subscription without hitting the store.
class DebugSimulateSubscription extends PurchaseEvent {
  final int bonusCredits;
  const DebugSimulateSubscription(this.bonusCredits);
  @override
  List<Object?> get props => [bonusCredits];
}
