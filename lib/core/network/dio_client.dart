import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';

/// Environment configuration
class EnvConfig {
  static String get apiEndpoint =>
      dotenv.env['API_ENDPOINT'] ?? 'https://freeway.pranta.dev';
  static String get adminApiKey => dotenv.env['ADMIN_API_KEY'] ?? '';
}

/// API configuration state
class ApiConfig {
  final String endpoint;
  final String apiKey;

  const ApiConfig({required this.endpoint, required this.apiKey});

  bool get isConfigured => endpoint.isNotEmpty && apiKey.isNotEmpty;
}

/// API configuration provider - loads from .env
final apiConfigProvider = Provider<ApiConfig>((ref) {
  final config = ApiConfig(
    endpoint: EnvConfig.apiEndpoint,
    apiKey: EnvConfig.adminApiKey,
  );
  AppLogger.info('API Config loaded - Endpoint: ${config.endpoint}, Key configured: ${config.apiKey.isNotEmpty}', 'DioClient');
  return config;
});

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException [$statusCode]: $message';
    }
    return 'ApiException: $message';
  }
}

/// Dio client provider with logging and error handling
final dioClientProvider = Provider<Dio>((ref) {
  final config = ref.watch(apiConfigProvider);

  final dio = Dio(BaseOptions(
    baseUrl: config.endpoint,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Request logging interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      AppLogger.info(
        '>>> ${options.method} ${options.uri}',
        'HTTP',
      );
      if (options.data != null) {
        AppLogger.debug('Request body: ${options.data}', 'HTTP');
      }

      // Add auth header
      if (config.apiKey.isNotEmpty) {
        options.headers['X-Api-Key'] = config.apiKey;
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      AppLogger.info(
        '<<< ${response.statusCode} ${response.requestOptions.uri}',
        'HTTP',
      );
      AppLogger.debug('Response: ${response.data}', 'HTTP');
      return handler.next(response);
    },
    onError: (error, handler) {
      final statusCode = error.response?.statusCode;
      final uri = error.requestOptions.uri;

      AppLogger.error(
        '!!! ${error.type.name} [$statusCode] $uri',
        error.message,
        error.stackTrace,
        'HTTP',
      );

      if (error.response?.data != null) {
        AppLogger.error('Error response: ${error.response?.data}', null, null, 'HTTP');
      }

      // Transform to more user-friendly error
      String message;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timed out. Please check your network.';
          break;
        case DioExceptionType.connectionError:
          message = 'Could not connect to server. Please check your network.';
          break;
        case DioExceptionType.badResponse:
          if (statusCode == 401) {
            message = 'Unauthorized. Please check your API key.';
          } else if (statusCode == 403) {
            message = 'Access forbidden. Check your permissions.';
          } else if (statusCode == 404) {
            message = 'Resource not found.';
          } else if (statusCode == 429) {
            message = 'Rate limited. Please try again later.';
          } else if (statusCode != null && statusCode >= 500) {
            message = 'Server error. Please try again later.';
          } else {
            final errorData = error.response?.data;
            if (errorData is Map && errorData['detail'] != null) {
              message = errorData['detail'].toString();
            } else {
              message = 'Request failed with status $statusCode';
            }
          }
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled.';
          break;
        default:
          message = error.message ?? 'An unexpected error occurred.';
      }

      return handler.next(DioException(
        requestOptions: error.requestOptions,
        error: ApiException(message, statusCode: statusCode, data: error.response?.data),
        type: error.type,
        response: error.response,
      ));
    },
  ));

  return dio;
});
