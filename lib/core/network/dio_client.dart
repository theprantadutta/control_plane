import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  return ApiConfig(
    endpoint: EnvConfig.apiEndpoint,
    apiKey: EnvConfig.adminApiKey,
  );
});

/// Dio client provider
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

  // Add auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (config.apiKey.isNotEmpty) {
        options.headers['X-Api-Key'] = config.apiKey;
      }
      return handler.next(options);
    },
    onError: (error, handler) {
      // Handle common errors
      if (error.response?.statusCode == 401) {
        // Unauthorized - API key invalid
      } else if (error.response?.statusCode == 429) {
        // Rate limited
      }
      return handler.next(error);
    },
  ));

  return dio;
});
