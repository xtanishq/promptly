part of 'purchase_bloc.dart';

/// Terminal/transient status of the last user-initiated purchase action.
/// UI awaits a terminal status (success / error / cancelled) after dispatching.
enum PurchaseStatus { idle, loading, success, error, cancelled }

/// Subscription state only. Credits live entirely on the backend now
/// (see [AuthRepository.credits]); this bloc no longer tracks them.
class PurchaseState extends Equatable {
  final bool isSubscribed;
  final PurchaseStatus status;
  final String? error;

  const PurchaseState({
    required this.isSubscribed,
    required this.status,
    this.error,
  });

  const PurchaseState.initial()
      : isSubscribed = false,
        status = PurchaseStatus.idle,
        error = null;

  PurchaseState copyWith({
    bool? isSubscribed,
    PurchaseStatus? status,
    String? error,
  }) {
    return PurchaseState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isSubscribed, status, error];
}
