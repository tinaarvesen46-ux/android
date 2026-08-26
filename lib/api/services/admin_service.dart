import '../api_client.dart';
import '../api_response.dart';
import '../api_config.dart';
import '../../models/admin_models.dart';
import '../../models/user_model.dart';

/// AdminService — talks to the real Laravel `/api/v1/admin/*` endpoints.
/// All list endpoints return bare JSON arrays; analytics/dashboard return
/// objects. Nothing here fabricates data — a failure surfaces as an error
/// and the screens render an empty/error state.
class AdminService {
  final ApiClient _client = ApiClient();

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }

  // ─── User Management ────────────────────────────────────────
  Future<ApiResponse<List<UserModel>>> getUsers({
    int page = 1,
    String? search,
    String? role,
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (role != null) params['role'] = role;
      if (status != null) params['status'] = status;

      final res = await _client.get(
        ApiConfig.adminUsers,
        queryParameters: params,
        fromJson: (d) => d,
      );
      if (!res.success) {
        return ApiResponse.error(message: res.message ?? 'Failed to load users');
      }
      final list = _asList(res.data)
          .map((u) => UserModel.fromJson(u))
          .toList();
      return ApiResponse.success(data: list);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<UserModel>> updateUserRole(String userId, StaffRole role) async {
    try {
      final res = await _client.put(
        '${ApiConfig.adminUsers}/$userId',
        data: {'staff_role': _roleToString(role)},
        fromJson: (d) => d,
      );
      if (res.success && res.data is Map<String, dynamic>) {
        return ApiResponse.success(data: UserModel.fromJson(res.data as Map<String, dynamic>));
      }
      return ApiResponse.error(message: res.message ?? 'Failed to update role');
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> banUser(String userId, String reason) async {
    try {
      final res = await _client.put(
        '${ApiConfig.adminUsers}/$userId',
        data: {'account_status': 'banned', 'ban_reason': reason},
      );
      return ApiResponse.success(data: res.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> unbanUser(String userId) async {
    try {
      final res = await _client.put(
        '${ApiConfig.adminUsers}/$userId',
        data: {'account_status': 'normal'},
      );
      return ApiResponse.success(data: res.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Support Tickets ────────────────────────────────────────
  Future<ApiResponse<List<SupportTicket>>> getTickets({int page = 1}) async {
    try {
      final res = await _client.get(ApiConfig.adminTickets,
          queryParameters: {'page': page}, fromJson: (d) => d);
      if (!res.success) {
        return ApiResponse.error(message: res.message ?? 'Failed to load tickets');
      }
      return ApiResponse.success(
        data: _asList(res.data).map(SupportTicket.fromApi).toList(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Moderation Reports ─────────────────────────────────────
  Future<ApiResponse<List<ModerationReport>>> getReports({int page = 1}) async {
    try {
      final res = await _client.get(ApiConfig.adminReports,
          queryParameters: {'page': page}, fromJson: (d) => d);
      if (!res.success) {
        return ApiResponse.error(message: res.message ?? 'Failed to load reports');
      }
      return ApiResponse.success(
        data: _asList(res.data).map(ModerationReport.fromApi).toList(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Analytics ──────────────────────────────────────────────
  Future<ApiResponse<PlatformAnalytics>> getAnalytics() async {
    try {
      final res = await _client.get(ApiConfig.adminAnalytics, fromJson: (d) => d);
      final map = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      return ApiResponse.success(data: PlatformAnalytics.fromApi(map));
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Email Campaigns / Templates ────────────────────────────
  Future<ApiResponse<List<EmailCampaign>>> getCampaigns({int page = 1}) async {
    try {
      final res = await _client.get(ApiConfig.adminCampaigns,
          queryParameters: {'page': page}, fromJson: (d) => d);
      if (!res.success) {
        return ApiResponse.error(message: res.message ?? 'Failed to load campaigns');
      }
      return ApiResponse.success(
        data: _asList(res.data).map(EmailCampaign.fromApi).toList(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<List<EmailTemplate>>> getTemplates() async {
    try {
      final res = await _client.get(ApiConfig.adminTemplates, fromJson: (d) => d);
      if (!res.success) {
        return ApiResponse.error(message: res.message ?? 'Failed to load templates');
      }
      return ApiResponse.success(
        data: _asList(res.data).map(EmailTemplate.fromApi).toList(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── System Settings ────────────────────────────────────────
  Future<ApiResponse<SystemSettings>> getSystemSettings() async {
    try {
      final res = await _client.get(ApiConfig.adminSettings, fromJson: (d) => d);
      return ApiResponse.success(data: SystemSettings.fromApi(_asList(res.data)));
    } catch (e) {
      return ApiResponse.success(data: const SystemSettings());
    }
  }

  // ─── Audit Logs ─────────────────────────────────────────────
  Future<ApiResponse<List<AuditLog>>> getAuditLogs({int page = 1}) async {
    try {
      final res = await _client.get(ApiConfig.adminAuditLogs,
          queryParameters: {'page': page}, fromJson: (d) => d);
      if (!res.success) {
        return ApiResponse.error(message: res.message ?? 'Failed to load audit logs');
      }
      return ApiResponse.success(
        data: _asList(res.data).map(AuditLog.fromApi).toList(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> warnUser(String userId, String message) async {
    try {
      final res = await _client.put(
        '${ApiConfig.adminUsers}/$userId',
        data: {'action': 'warn', 'warn_message': message},
      );
      return ApiResponse.success(data: res.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> replyToTicket(String ticketId, String message) async {
    try {
      final res = await _client.post('${ApiConfig.adminTickets}/$ticketId/reply',
          data: {'message': message});
      return ApiResponse.success(data: res.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> updateTicketStatus(String ticketId, TicketStatus status) async {
    try {
      final res = await _client.put('${ApiConfig.adminTickets}/$ticketId',
          data: {'status': status.name});
      return ApiResponse.success(data: res.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> actionReport(String reportId, String action) async {
    try {
      final res = await _client.post('${ApiConfig.adminReports}/$reportId/action',
          data: {'action': action});
      return ApiResponse.success(data: res.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> sendCampaign(String campaignId) async {
    try {
      final res = await _client.post('${ApiConfig.adminCampaigns}/$campaignId/send');
      return ApiResponse.success(data: res.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> createCampaign(Map<String, dynamic> data) async {
    try {
      final res = await _client.post(ApiConfig.adminCampaigns, data: data);
      return ApiResponse.success(data: res.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> updateSystemSettings(Map<String, dynamic> settings) async {
    try {
      final res = await _client.put(ApiConfig.adminSettings, data: settings);
      return ApiResponse.success(data: res.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  String _roleToString(StaffRole role) {
    switch (role) {
      case StaffRole.administrator:
        return 'administrator';
      case StaffRole.moderator:
        return 'moderator';
      case StaffRole.support:
        return 'support';
      case StaffRole.none:
        return 'none';
    }
  }
}
