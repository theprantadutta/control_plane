import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';

/// Pricing info model
class PricingInfo {
  final String prompt;
  final String completion;

  PricingInfo({required this.prompt, required this.completion});

  factory PricingInfo.fromJson(Map<String, dynamic> json) {
    return PricingInfo(
      prompt: json['prompt']?.toString() ?? '0',
      completion: json['completion']?.toString() ?? '0',
    );
  }

  bool get isFree => prompt == '0' || prompt == '0.0';
}

/// Model info for list responses
class ModelInfo {
  final String id;
  final String name;
  final String? description;
  final int? contextLength;
  final PricingInfo pricing;
  final int? rank;

  ModelInfo({
    required this.id,
    required this.name,
    this.description,
    this.contextLength,
    required this.pricing,
    this.rank,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    try {
      return ModelInfo(
        id: json['model_id']?.toString() ?? json['id']?.toString() ?? 'unknown',
        name: json['model_name']?.toString() ?? json['name']?.toString() ?? 'Unknown Model',
        description: json['description']?.toString(),
        contextLength: json['context_length'] as int?,
        pricing: json['pricing'] != null
            ? PricingInfo.fromJson(json['pricing'] as Map<String, dynamic>)
            : PricingInfo(prompt: '0', completion: '0'),
        rank: json['rank'] as int?,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse ModelInfo', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
  }

  bool get isFree => pricing.isFree;

  @override
  String toString() => 'ModelInfo(id: $id, name: $name, context: $contextLength)';
}

/// Response for selected model endpoints (/model/free, /model/paid)
class SelectedModelResponse {
  final String modelId;
  final String modelName;
  final String? description;
  final int? contextLength;
  final PricingInfo pricing;

  SelectedModelResponse({
    required this.modelId,
    required this.modelName,
    this.description,
    this.contextLength,
    required this.pricing,
  });

  factory SelectedModelResponse.fromJson(Map<String, dynamic> json) {
    try {
      return SelectedModelResponse(
        modelId: json['model_id']?.toString() ?? 'unknown',
        modelName: json['model_name']?.toString() ?? 'Unknown Model',
        description: json['description']?.toString(),
        contextLength: json['context_length'] as int?,
        pricing: json['pricing'] != null
            ? PricingInfo.fromJson(json['pricing'] as Map<String, dynamic>)
            : PricingInfo(prompt: '0', completion: '0'),
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse SelectedModelResponse', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
  }

  bool get isFree => pricing.isFree;
}

/// Response for model list endpoints (/models/free, /models/paid)
class ModelsListResponse {
  final List<ModelInfo> models;
  final int totalCount;
  final DateTime? lastUpdated;

  ModelsListResponse({
    required this.models,
    required this.totalCount,
    this.lastUpdated,
  });

  factory ModelsListResponse.fromJson(Map<String, dynamic> json) {
    try {
      final modelsList = json['models'] as List? ?? [];
      return ModelsListResponse(
        models: modelsList
            .map((m) => ModelInfo.fromJson(m as Map<String, dynamic>))
            .toList(),
        totalCount: json['total_count'] as int? ?? modelsList.length,
        lastUpdated: json['last_updated'] != null
            ? DateTime.tryParse(json['last_updated'].toString())
            : null,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse ModelsListResponse', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
  }
}

/// Response for setting selected model
class SetModelResponse {
  final bool success;
  final String modelId;
  final String modelName;
  final String message;

  SetModelResponse({
    required this.success,
    required this.modelId,
    required this.modelName,
    required this.message,
  });

  factory SetModelResponse.fromJson(Map<String, dynamic> json) {
    try {
      return SetModelResponse(
        success: json['success'] as bool? ?? false,
        modelId: json['model_id']?.toString() ?? '',
        modelName: json['model_name']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse SetModelResponse', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
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
    try {
      // Properly handle api_key - only set if it exists and is not null
      final apiKeyValue = json['api_key'];
      final String? apiKey = (apiKeyValue != null && apiKeyValue.toString().isNotEmpty)
          ? apiKeyValue.toString()
          : null;

      return Project(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown Project',
        apiKeyPrefix: json['api_key_prefix']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
        isActive: json['is_active'] as bool? ?? true,
        rateLimitPerMinute: json['rate_limit_per_minute'] as int? ?? 60,
        apiKey: apiKey,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse Project', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
  }
}

/// Response for API key rotation (only contains key info)
class RotateKeyResult {
  final String id;
  final String apiKey;
  final String apiKeyPrefix;

  RotateKeyResult({
    required this.id,
    required this.apiKey,
    required this.apiKeyPrefix,
  });

  factory RotateKeyResult.fromJson(Map<String, dynamic> json) {
    try {
      return RotateKeyResult(
        id: json['id']?.toString() ?? '',
        apiKey: json['api_key']?.toString() ?? '',
        apiKeyPrefix: json['api_key_prefix']?.toString() ?? '',
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse RotateKeyResult', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
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
    try {
      return GlobalSummary(
        totalProjects: json['total_projects'] as int? ?? 0,
        activeProjects: json['active_projects'] as int? ?? 0,
        totalRequestsToday: json['total_requests_today'] as int? ?? 0,
        totalRequestsThisMonth: json['total_requests_this_month'] as int? ?? 0,
        totalCostThisMonthUsd: (json['total_cost_this_month_usd'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse GlobalSummary', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
  }
}

/// Usage summary for a project
class UsageSummary {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final int totalInputTokens;
  final int totalOutputTokens;
  final double totalCostUsd;
  final double avgResponseTimeMs;

  UsageSummary({
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.totalInputTokens,
    required this.totalOutputTokens,
    required this.totalCostUsd,
    required this.avgResponseTimeMs,
  });

  factory UsageSummary.fromJson(Map<String, dynamic> json) {
    return UsageSummary(
      totalRequests: json['total_requests'] as int? ?? 0,
      successfulRequests: json['successful_requests'] as int? ?? 0,
      failedRequests: json['failed_requests'] as int? ?? 0,
      totalInputTokens: json['total_input_tokens'] as int? ?? 0,
      totalOutputTokens: json['total_output_tokens'] as int? ?? 0,
      totalCostUsd: (json['total_cost_usd'] as num?)?.toDouble() ?? 0.0,
      avgResponseTimeMs: (json['avg_response_time_ms'] as num?)?.toDouble() ?? 0.0,
    );
  }

  int get totalTokens => totalInputTokens + totalOutputTokens;
  double get successRate => totalRequests > 0 ? successfulRequests / totalRequests * 100 : 0;
}

/// Per-model usage statistics
class ModelUsageStats {
  final String modelId;
  final String modelType;
  final int requests;
  final int tokens;
  final double costUsd;

  ModelUsageStats({
    required this.modelId,
    required this.modelType,
    required this.requests,
    required this.tokens,
    required this.costUsd,
  });

  factory ModelUsageStats.fromJson(Map<String, dynamic> json) {
    return ModelUsageStats(
      modelId: json['model_id']?.toString() ?? 'unknown',
      modelType: json['model_type']?.toString() ?? 'unknown',
      requests: json['requests'] as int? ?? 0,
      tokens: json['tokens'] as int? ?? 0,
      costUsd: (json['cost_usd'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Project usage response from /admin/analytics/usage
class ProjectUsage {
  final String projectId;
  final String projectName;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final UsageSummary summary;
  final List<ModelUsageStats> byModel;

  ProjectUsage({
    required this.projectId,
    required this.projectName,
    this.periodStart,
    this.periodEnd,
    required this.summary,
    required this.byModel,
  });

  factory ProjectUsage.fromJson(Map<String, dynamic> json) {
    try {
      final period = json['period'] as Map<String, dynamic>? ?? {};
      final byModelList = json['by_model'] as List? ?? [];

      return ProjectUsage(
        projectId: json['project_id']?.toString() ?? '',
        projectName: json['project_name']?.toString() ?? 'Unknown',
        periodStart: period['start'] != null ? DateTime.tryParse(period['start'].toString()) : null,
        periodEnd: period['end'] != null ? DateTime.tryParse(period['end'].toString()) : null,
        summary: UsageSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
        byModel: byModelList
            .map((m) => ModelUsageStats.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse ProjectUsage', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
  }
}

/// Individual usage log entry
class UsageLog {
  final String id;
  final String projectId;
  final String modelId;
  final String modelType;
  final int inputTokens;
  final int outputTokens;
  final int responseTimeMs;
  final double costUsd;
  final bool success;
  final String? errorMessage;
  final String? requestId;
  final DateTime createdAt;
  final String? provider;
  final List<Map<String, dynamic>>? requestMessages;
  final String? responseContent;
  final String? finishReason;

  UsageLog({
    required this.id,
    required this.projectId,
    required this.modelId,
    required this.modelType,
    required this.inputTokens,
    required this.outputTokens,
    required this.responseTimeMs,
    required this.costUsd,
    required this.success,
    this.errorMessage,
    this.requestId,
    required this.createdAt,
    this.provider,
    this.requestMessages,
    this.responseContent,
    this.finishReason,
  });

  factory UsageLog.fromJson(Map<String, dynamic> json) {
    try {
      return UsageLog(
        id: json['id']?.toString() ?? '',
        projectId: json['project_id']?.toString() ?? '',
        modelId: json['model_id']?.toString() ?? 'unknown',
        modelType: json['model_type']?.toString() ?? 'unknown',
        inputTokens: json['input_tokens'] as int? ?? 0,
        outputTokens: json['output_tokens'] as int? ?? 0,
        responseTimeMs: json['response_time_ms'] as int? ?? 0,
        costUsd: (json['cost_usd'] as num?)?.toDouble() ?? 0.0,
        success: json['success'] as bool? ?? false,
        errorMessage: json['error_message']?.toString(),
        requestId: json['request_id']?.toString(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        provider: json['provider']?.toString(),
        requestMessages: json['request_messages'] != null
            ? List<Map<String, dynamic>>.from(json['request_messages'] as List)
            : null,
        responseContent: json['response_content']?.toString(),
        finishReason: json['finish_reason']?.toString(),
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse UsageLog', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
  }

  int get totalTokens => inputTokens + outputTokens;
}

/// Paginated usage logs response
class UsageLogsResponse {
  final List<UsageLog> logs;
  final int totalCount;
  final int limit;
  final int offset;

  UsageLogsResponse({
    required this.logs,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  factory UsageLogsResponse.fromJson(Map<String, dynamic> json) {
    try {
      final logsList = json['logs'] as List? ?? [];
      return UsageLogsResponse(
        logs: logsList.map((l) => UsageLog.fromJson(l as Map<String, dynamic>)).toList(),
        totalCount: json['total_count'] as int? ?? logsList.length,
        limit: json['limit'] as int? ?? 50,
        offset: json['offset'] as int? ?? 0,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to parse UsageLogsResponse', e, stack, 'API');
      AppLogger.debug('Raw JSON: $json', 'API');
      rethrow;
    }
  }

  bool get hasMore => offset + logs.length < totalCount;
}

/// Freeway API service
class FreewayApi {
  final Dio _dio;

  FreewayApi(this._dio);

  // Model endpoints
  Future<SelectedModelResponse> getSelectedFreeModel() async {
    AppLogger.info('Fetching selected free model...', 'API');
    try {
      final response = await _dio.get('/model/free');
      final result = SelectedModelResponse.fromJson(response.data);
      AppLogger.info('Got free model: ${result.modelId}', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to get selected free model', e, stack, 'API');
      rethrow;
    }
  }

  Future<SelectedModelResponse> getSelectedPaidModel() async {
    AppLogger.info('Fetching selected paid model...', 'API');
    try {
      final response = await _dio.get('/model/paid');
      final result = SelectedModelResponse.fromJson(response.data);
      AppLogger.info('Got paid model: ${result.modelId}', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to get selected paid model', e, stack, 'API');
      rethrow;
    }
  }

  Future<ModelsListResponse> getAllFreeModels() async {
    AppLogger.info('Fetching all free models...', 'API');
    try {
      final response = await _dio.get('/models/free');
      final result = ModelsListResponse.fromJson(response.data);
      AppLogger.info('Got ${result.totalCount} free models', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to get free models', e, stack, 'API');
      rethrow;
    }
  }

  Future<ModelsListResponse> getAllPaidModels() async {
    AppLogger.info('Fetching all paid models...', 'API');
    try {
      final response = await _dio.get('/models/paid');
      final result = ModelsListResponse.fromJson(response.data);
      AppLogger.info('Got ${result.totalCount} paid models', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to get paid models', e, stack, 'API');
      rethrow;
    }
  }

  // Model selection endpoints
  Future<SetModelResponse> setSelectedFreeModel(String modelId) async {
    AppLogger.info('Setting selected free model to: $modelId', 'API');
    try {
      final response = await _dio.put('/admin/model/free', data: {
        'model_id': modelId,
      });
      final result = SetModelResponse.fromJson(response.data);
      AppLogger.info('Set free model: ${result.modelName}', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to set selected free model', e, stack, 'API');
      rethrow;
    }
  }

  Future<SetModelResponse> setSelectedPaidModel(String modelId) async {
    AppLogger.info('Setting selected paid model to: $modelId', 'API');
    try {
      final response = await _dio.put('/admin/model/paid', data: {
        'model_id': modelId,
      });
      final result = SetModelResponse.fromJson(response.data);
      AppLogger.info('Set paid model: ${result.modelName}', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to set selected paid model', e, stack, 'API');
      rethrow;
    }
  }

  // Admin endpoints
  Future<List<Project>> getProjects() async {
    AppLogger.info('Fetching projects...', 'API');
    try {
      final response = await _dio.get('/admin/projects');
      final projectsList = response.data['projects'] as List? ?? [];
      final result = projectsList
          .map((p) => Project.fromJson(p as Map<String, dynamic>))
          .toList();
      AppLogger.info('Got ${result.length} projects', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to get projects', e, stack, 'API');
      rethrow;
    }
  }

  Future<Project> createProject({
    required String name,
    int rateLimitPerMinute = 60,
    Map<String, dynamic>? metadata,
  }) async {
    AppLogger.info('Creating project: $name', 'API');
    try {
      final response = await _dio.post('/admin/projects', data: {
        'name': name,
        'rate_limit_per_minute': rateLimitPerMinute,
        if (metadata != null) 'metadata': metadata,
      });
      final result = Project.fromJson(response.data);
      AppLogger.info('Created project: ${result.id}', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to create project', e, stack, 'API');
      rethrow;
    }
  }

  Future<Project> getProject(String id) async {
    AppLogger.info('Fetching project: $id', 'API');
    try {
      final response = await _dio.get('/admin/projects/$id');
      return Project.fromJson(response.data);
    } catch (e, stack) {
      AppLogger.error('Failed to get project', e, stack, 'API');
      rethrow;
    }
  }

  Future<Project> updateProject(
    String id, {
    String? name,
    bool? isActive,
    int? rateLimitPerMinute,
    Map<String, dynamic>? metadata,
  }) async {
    AppLogger.info('Updating project: $id', 'API');
    try {
      final response = await _dio.patch('/admin/projects/$id', data: {
        if (name != null) 'name': name,
        if (isActive != null) 'is_active': isActive,
        if (rateLimitPerMinute != null) 'rate_limit_per_minute': rateLimitPerMinute,
        if (metadata != null) 'metadata': metadata,
      });
      final result = Project.fromJson(response.data);
      AppLogger.info('Updated project: ${result.id}', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to update project', e, stack, 'API');
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    AppLogger.info('Deleting project: $id', 'API');
    try {
      await _dio.delete('/admin/projects/$id');
      AppLogger.info('Deleted project: $id', 'API');
    } catch (e, stack) {
      AppLogger.error('Failed to delete project', e, stack, 'API');
      rethrow;
    }
  }

  Future<RotateKeyResult> rotateApiKey(String id) async {
    AppLogger.info('Rotating API key for project: $id', 'API');
    try {
      final response = await _dio.post('/admin/projects/$id/rotate-key');
      final result = RotateKeyResult.fromJson(response.data);
      AppLogger.info('Rotated API key for project: $id, new prefix: ${result.apiKeyPrefix}', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to rotate API key', e, stack, 'API');
      rethrow;
    }
  }

  Future<GlobalSummary> getGlobalSummary() async {
    AppLogger.info('Fetching global summary...', 'API');
    try {
      final response = await _dio.get('/admin/analytics/summary');
      final result = GlobalSummary.fromJson(response.data);
      AppLogger.info('Got summary: ${result.totalProjects} projects, ${result.totalRequestsToday} requests today', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to get global summary', e, stack, 'API');
      rethrow;
    }
  }

  // Analytics endpoints
  Future<ProjectUsage> getProjectUsage(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    AppLogger.info('Fetching usage for project: $projectId', 'API');
    try {
      final queryParams = <String, dynamic>{
        'project_id': projectId,
      };
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dio.get(
        '/admin/analytics/usage',
        queryParameters: queryParams,
      );
      final result = ProjectUsage.fromJson(response.data);
      AppLogger.info('Got usage for project: ${result.projectName}, ${result.summary.totalRequests} requests', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to get project usage', e, stack, 'API');
      rethrow;
    }
  }

  Future<UsageLogsResponse> getProjectLogs(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    AppLogger.info('Fetching logs for project: $projectId (limit: $limit, offset: $offset)', 'API');
    try {
      final queryParams = <String, dynamic>{
        'project_id': projectId,
        'limit': limit,
        'offset': offset,
      };
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dio.get(
        '/admin/analytics/logs',
        queryParameters: queryParams,
      );
      final result = UsageLogsResponse.fromJson(response.data);
      AppLogger.info('Got ${result.logs.length} logs for project (total: ${result.totalCount})', 'API');
      return result;
    } catch (e, stack) {
      AppLogger.error('Failed to get project logs', e, stack, 'API');
      rethrow;
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    AppLogger.info('Checking health...', 'API');
    try {
      await _dio.get('/health');
      AppLogger.info('Health check passed', 'API');
      return true;
    } catch (e) {
      AppLogger.warning('Health check failed: $e', 'API');
      return false;
    }
  }
}

/// Freeway API provider
final freewayApiProvider = Provider<FreewayApi>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FreewayApi(dio);
});
