import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../error/failures.dart';
import '../utils/app_logger.dart';
import '../utils/auth_repository.dart';

/// Professional-grade API client built on Dio.
///
/// Features:
/// - Automatic Bearer token injection
/// - Connectivity check before every request
/// - Retry with exponential backoff (configurable)
/// - Structured error mapping to [AppFailure]
/// - Detailed request/response logging via [AppLogger]
/// - Centralized timeout configuration
///
/// Usage:
/// ```dart
/// final client = ApiClient.instance;
/// final response = await client.get('/api/styles');
/// final response = await client.postMultipart('/api/wardrobe', fields: {...}, files: [...]);
/// ```
class ApiClient {
  ApiClient._();

  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  static const String _baseUrl = 'https://my-worker.scratched.workers.dev';

  /// Alternate base for endpoints that use http://
  static const String _baseUrlHttp = 'http://my-worker.scratched.workers.dev';

  late final Dio _dio;
  bool _isInitialized = false;

  // ── Configuration ─────────────────────────────────────────────

  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 120);
  static const Duration _sendTimeout = Duration(seconds: 120);
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 2);

  // ── Initialization ────────────────────────────────────────────

  void init() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _RetryInterceptor(dio: _dio),
    ]);

    _isInitialized = true;
    AppLogger.info('ApiClient initialized');
  }

  Dio get dio {
    if (!_isInitialized) init();
    return _dio;
  }

  // ── Public API ────────────────────────────────────────────────

  /// GET request.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
    bool useHttp = false,
  }) async {
    await _ensureConnectivity();
    final baseUrl = useHttp ? _baseUrlHttp : _baseUrl;
    return dio.get('$baseUrl$path', queryParameters: queryParams);
  }

  /// POST request with JSON body.
  Future<Response> post(
    String path, {
    dynamic data,
    bool useHttp = false,
  }) async {
    await _ensureConnectivity();
    final baseUrl = useHttp ? _baseUrlHttp : _baseUrl;
    return dio.post('$baseUrl$path', data: data);
  }

  /// POST multipart/form-data — the workhorse for all image uploads.
  ///
  /// [fields] → text form fields (e.g. styleId, prompt).
  /// [files]  → list of (fieldName, filePath) tuples.
  Future<Response> postMultipart(
    String path, {
    Map<String, String> fields = const {},
    List<MapEntry<String, String>> files = const [],
    bool useHttp = false,
  }) async {
    await _ensureConnectivity();
    final baseUrl = useHttp ? _baseUrlHttp : _baseUrl;

    final formData = FormData();

    // Add text fields
    for (final entry in fields.entries) {
      formData.fields.add(MapEntry(entry.key, entry.value));
    }

    // Add file fields
    for (final entry in files) {
      formData.files.add(MapEntry(
        entry.key,
        await MultipartFile.fromFile(entry.value),
      ));
    }

    return dio.post(
      '$baseUrl$path',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // ── Connectivity ──────────────────────────────────────────────

  Future<void> _ensureConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        throw AppFailure.network(
          message: 'No internet connection. Please check your network and try again.',
        );
      }
    } catch (e) {
      if (e is AppFailure) rethrow;
      // If connectivity check itself fails, let the request proceed
      // — the Dio timeout will catch genuine offline state.
    }
  }

  // ── Error Mapping ─────────────────────────────────────────────

  /// Converts a [DioException] into a typed [AppFailure].
  /// Call this in your repository catch blocks.
  static AppFailure mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppFailure.network(
          message: 'Request timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        return AppFailure.network(
          message: 'Could not connect to server. Please check your internet.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final body = e.response?.data;
        final serverMessage = _extractServerMessage(body);

        if (statusCode == 401 || statusCode == 403) {
          return AppFailure.unauthorized(
            message: serverMessage ?? 'Session expired. Please restart the app.',
          );
        }
        if (statusCode == 429) {
          return AppFailure.server(
            message: 'Too many requests. Please wait a moment and try again.',
          );
        }
        if (statusCode >= 500) {
          return AppFailure.server(
            message: serverMessage ?? 'Server error. Please try again later.',
          );
        }
        return AppFailure.server(
          message: serverMessage ?? 'Request failed (HTTP $statusCode).',
        );

      case DioExceptionType.cancel:
        return AppFailure.unknown(message: 'Request was cancelled.');

      default:
        return AppFailure.unknown(
          message: e.message ?? 'An unexpected error occurred.',
        );
    }
  }

  static String? _extractServerMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['error'] as String? ??
          body['message'] as String? ??
          body['msg'] as String?;
    }
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════
// INTERCEPTORS
// ═══════════════════════════════════════════════════════════════════

/// Injects the Bearer token from [AuthRepository] into every request.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthRepository().accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Structured logging for requests, responses, and errors.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('→ ${options.method} ${options.uri}');
    if (options.data is FormData) {
      final fd = options.data as FormData;
      AppLogger.debug('  Fields: ${fd.fields.map((e) => '${e.key}=${e.value}').join(', ')}');
      AppLogger.debug('  Files: ${fd.files.map((e) => '${e.key} (${e.value.filename})').join(', ')}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '← ERROR ${err.response?.statusCode ?? 'N/A'} ${err.requestOptions.uri}',
      err.message,
    );
    handler.next(err);
  }
}

/// Retries failed requests with exponential backoff.
/// Only retries on network/timeout errors — not on 4xx client errors.
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  _RetryInterceptor({required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final retries = err.requestOptions.extra['retryCount'] ?? 0;
    if (retries >= ApiClient._maxRetries) {
      AppLogger.warning('Max retries (${ApiClient._maxRetries}) reached for ${err.requestOptions.uri}');
      return handler.next(err);
    }

    final delay = ApiClient._retryDelay * (retries + 1); // exponential backoff
    AppLogger.info('Retry ${retries + 1}/${ApiClient._maxRetries} in ${delay.inSeconds}s for ${err.requestOptions.uri}');
    await Future.delayed(delay);

    err.requestOptions.extra['retryCount'] = retries + 1;

    try {
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
