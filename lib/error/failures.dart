import 'package:equatable/equatable.dart';

abstract class AppFailure extends Equatable {
  final String? message;
  const AppFailure({this.message});

  @override
  List<Object?> get props => [message];

  factory AppFailure.server({String? message}) = ServerFailure;
  factory AppFailure.cache({String? message}) = CacheFailure;
  factory AppFailure.network({String? message}) = NetworkFailure;
  factory AppFailure.unauthorized({String? message}) = UnauthorizedFailure;
  factory AppFailure.unknown({String? message}) = UnknownFailure;

  T when<T>({
    required T Function(String? message) server,
    required T Function(String? message) cache,
    required T Function(String? message) network,
    required T Function(String? message) unauthorized,
    required T Function(String? message) unknown,
  }) {
    if (this is ServerFailure) return server(message);
    if (this is CacheFailure) return cache(message);
    if (this is NetworkFailure) return network(message);
    if (this is UnauthorizedFailure) return unauthorized(message);
    return unknown(message);
  }
}

class ServerFailure extends AppFailure {
  const ServerFailure({super.message});
}
class CacheFailure extends AppFailure {
  const CacheFailure({super.message});
}
class NetworkFailure extends AppFailure {
  const NetworkFailure({super.message});
}
class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({super.message});
}
class UnknownFailure extends AppFailure {
  const UnknownFailure({super.message});
}
