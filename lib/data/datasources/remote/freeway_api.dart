import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

/// Freeway API response models
class ModelInfo {
  final String id;
  final String name;
  final String? description;
  final int contextLength;
  final String promptPrice;
  final String completionPrice;
  final bool isFree;

  ModelInfo({
    required this.id,
    required this.name,
    this.description,
    required this.contextLength,
    required this.promptPrice,
    required this.completionPrice,
    required this.isFree,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      contextLength: json['context_length'] as int,
      promptPrice: json['pricing']['prompt'] as String,
      completionPrice: json['pricing']['completion'] as String,
      isFree: (json['pricing']['prompt'] == '0' ||
          json['pricing']['prompt'] == '0.0'),
    );
  }
}

class SelectedModelResponse {
  final String selectedModel;
  final ModelInfo? modelInfo;

  SelectedModelResponse({
    required this.selectedModel,
    this.modelInfo,
  });

  factory SelectedModelResponse.fromJson(Map<String, dynamic> json) {
    return SelectedModelResponse(
      selectedModel: json['selected_model'] as String,
      modelInfo: json['model_info'] != null
          ? ModelInfo.fromJson(json['model_info'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ModelsListResponse {
  final List<ModelInfo> models;
  final int count;

  ModelsListResponse({
    required this.models,
    required this.count,
  });

  factory ModelsListResponse.fromJson(Map<String, dynamic> json) {
    return ModelsListResponse(
      models: (json['models'] as List)
          .map((m) => ModelInfo.fromJson(m as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int,
    );
  }
}

class Project {
  final String id;
  final String name;
  final String apiKeyPrefix;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int rateLimitPerMinute;
  final String? apiKey; // Only present on create/rotate

  Project({
    required this.id,
    required this.name,
    required this.apiKeyPrefix,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.rateLimitPerMinute,
    this.apiKey,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      apiKeyPrefix: json['api_key_prefix'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool,
      rateLimitPerMinute: json['rate_limit_per_minute'] as int,
      apiKey: json['api_key'] as String?,
    );
  }
}

class GlobalSummary {
  final int totalProjects;
  final int activeProjects;
  final int totalRequestsToday;
  final int totalRequestsThisMonth;
  final double totalCostThisMonthUsd;

  GlobalSummary({
    required this.totalProjects,
    required this.activeProjects,
    required this.totalRequestsToday,
    required this.totalRequestsThisMonth,
    required this.totalCostThisMonthUsd,
  });

  factory GlobalSummary.fromJson(Map<String, dynamic> json) {
    return GlobalSummary(
      totalProjects: json['total_projects'] as int,
      activeProjects: json['active_projects'] as int,
      totalRequestsToday: json['total_requests_today'] as int,
      totalRequestsThisMonth: json['total_requests_this_month'] as int,
      totalCostThisMonthUsd: (json['total_cost_this_month_usd'] as num).toDouble(),
    );
  }
}

/// Freeway API service
class FreewayApi {
  final Dio _dio;

  FreewayApi(this._dio);

  // Model endpoints
  Future<SelectedModelResponse> getSelectedFreeModel() async {
    final response = await _dio.get('/model/free');
    return SelectedModelResponse.fromJson(response.data);
  }

  Future<SelectedModelResponse> getSelectedPaidModel() async {
    final response = await _dio.get('/model/paid');
    return SelectedModelResponse.fromJson(response.data);
  }

  Future<ModelsListResponse> getAllFreeModels() async {
    final response = await _dio.get('/models/free');
    return ModelsListResponse.fromJson(response.data);
  }

  Future<ModelsListResponse> getAllPaidModels() async {
    final response = await _dio.get('/models/paid');
    return ModelsListResponse.fromJson(response.data);
  }

  // Admin endpoints
  Future<List<Project>> getProjects() async {
    final response = await _dio.get('/admin/projects');
    return (response.data['projects'] as List)
        .map((p) => Project.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject({
    required String name,
    int rateLimitPerMinute = 60,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _dio.post('/admin/projects', data: {
      'name': name,
      'rate_limit_per_minute': rateLimitPerMinute,
      if (metadata != null) 'metadata': metadata,
    });
    return Project.fromJson(response.data);
  }

  Future<Project> getProject(String id) async {
    final response = await _dio.get('/admin/projects/$id');
    return Project.fromJson(response.data);
  }

  Future<Project> updateProject(
    String id, {
    String? name,
    bool? isActive,
    int? rateLimitPerMinute,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _dio.patch('/admin/projects/$id', data: {
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (rateLimitPerMinute != null) 'rate_limit_per_minute': rateLimitPerMinute,
      if (metadata != null) 'metadata': metadata,
    });
    return Project.fromJson(response.data);
  }

  Future<void> deleteProject(String id) async {
    await _dio.delete('/admin/projects/$id');
  }

  Future<Project> rotateApiKey(String id) async {
    final response = await _dio.post('/admin/projects/$id/rotate-key');
    return Project.fromJson(response.data);
  }

  Future<GlobalSummary> getGlobalSummary() async {
    final response = await _dio.get('/admin/analytics/summary');
    return GlobalSummary.fromJson(response.data);
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      await _dio.get('/health');
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Freeway API provider
final freewayApiProvider = Provider<FreewayApi>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FreewayApi(dio);
});
