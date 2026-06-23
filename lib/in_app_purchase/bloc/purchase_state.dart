part of 'purchase_bloc.dart';

/// Terminal/transient status of the last user-initiated purchase action.
/// UI awaits a terminal status (success / error / cancelled) after dispatching.
enum PurchaseStatus { idle, loading, success, error, cancelled }

class PurchaseState extends Equatable {
  final bool isSubscribed;
  final int credits;
  final PurchaseStatus status;
  final String? error;

  const PurchaseState({
    required this.isSubscribed,
    required this.credits,
    required this.status,
    this.error,
  });

  const PurchaseState.initial()
      : isSubscribed = false,
        credits = 0,
        status = PurchaseStatus.idle,
        error = null;

  bool hasEnoughCredits(int needed) => credits >= needed;

  PurchaseState copyWith({
    bool? isSubscribed,
    int? credits,
    PurchaseStatus? status,
    String? error,
  }) {
    return PurchaseState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      credits: credits ?? this.credits,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isSubscribed, credits, status, error];
}
