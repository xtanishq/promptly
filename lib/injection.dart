import 'package:get_it/get_it.dart';

import 'in_app_purchase/bloc/purchase_bloc.dart';
import 'in_app_purchase/purchase_repository.dart';
import 'network/dio_client.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Monetization — app-lifetime singletons.
  getIt.registerLazySingleton<PurchaseRepository>(() => PurchaseRepository());
  getIt.registerLazySingleton<PurchaseBloc>(
    () => PurchaseBloc(getIt<PurchaseRepository>()),
  );
}
