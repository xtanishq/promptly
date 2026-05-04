import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_logger.dart';

@singleton
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 300),
        receiveTimeout: const Duration(seconds: 300),
        responseType: ResponseType.json,
      
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.debug('--> ${options.method} ${options.uri}');
          // If we had tokens, we'd add auth headers here
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug('<-- ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.error(
            '<-- Error ${e.response?.statusCode} ${e.requestOptions.uri}',
            e,
          );
          return handler.next(e);
        },
      ),
    );
  }
}
