import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage keys
class StorageKeys {
  static const String apiEndpoint = 'api_endpoint';
  static const String apiKey = 'api_key';
}

/// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// API configuration state
class ApiConfig {
  final String? endpoint;
  final String? apiKey;

  const ApiConfig({this.endpoint, this.apiKey});

  bool get isConfigured => endpoint != null && apiKey != null;

  ApiConfig copyWith({String? endpoint, String? apiKey}) {
    return ApiConfig(
      endpoint: endpoint ?? this.endpoint,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}

/// API configuration notifier
class ApiConfigNotifier extends StateNotifier<ApiConfig> {
  final FlutterSecureStorage _storage;

  ApiConfigNotifier(this._storage) : super(const ApiConfig()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final endpoint = await _storage.read(key: StorageKeys.apiEndpoint);
    final apiKey = await _storage.read(key: StorageKeys.apiKey);
    state = ApiConfig(endpoint: endpoint, apiKey: apiKey);
  }

  Future<void> setEndpoint(String endpoint) async {
    await _storage.write(key: StorageKeys.apiEndpoint, value: endpoint);
    state = state.copyWith(endpoint: endpoint);
  }

  Future<void> setApiKey(String apiKey) async {
    await _storage.write(key: StorageKeys.apiKey, value: apiKey);
    state = state.copyWith(apiKey: apiKey);
  }

  Future<void> clearConfig() async {
    await _storage.delete(key: StorageKeys.apiEndpoint);
    await _storage.delete(key: StorageKeys.apiKey);
    state = const ApiConfig();
  }
}

/// API configuration provider
final apiConfigProvider =
    StateNotifierProvider<ApiConfigNotifier, ApiConfig>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiConfigNotifier(storage);
});

/// Dio client provider
final dioClientProvider = Provider<Dio>((ref) {
  final config = ref.watch(apiConfigProvider);

  final dio = Dio(BaseOptions(
    baseUrl: config.endpoint ?? '',
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
      if (config.apiKey != null) {
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

  // Add logging interceptor in debug mode
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (o) => print('[DIO] $o'),
  ));

  return dio;
});
