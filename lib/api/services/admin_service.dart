import '../api_client.dart';
import '../api_response.dart';
import '../api_config.dart';
import '../../models/admin_models.dart';
import '../../models/user_model.dart';

class AdminService {
  final ApiClient _client = ApiClient();

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

      final response = await _client.get(
        ApiConfig.adminUsers,
        queryParameters: params,
      );
      if (response.success && response.data != null) {
        final raw = response.data as Map<String, dynamic>;
        final list = (raw['data'] as List)
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(data: list);
      }
      return ApiResponse.error(
          message: response.message ?? 'Failed to load users');
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<UserModel>> updateUserRole(
    String userId,
    StaffRole role,
  ) async {
    try {
      final response = await _client.put(
        '${ApiConfig.adminUsers}/$userId/role',
        data: {'staff_role': _roleToString(role)},
      );
      if (response.success && response.data != null) {
        return ApiResponse.success(
          data: UserModel.fromJson(
              response.data as Map<String, dynamic>),
        );
      }
      return ApiResponse.error(
          message: response.message ?? 'Failed to update role');
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> banUser(String userId, String reason) async {
    try {
      final response = await _client.post(
        '${ApiConfig.adminUsers}/$userId/ban',
        data: {'reason': reason},
      );
      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> unbanUser(String userId) async {
    try {
      final response =
          await _client.post('${ApiConfig.adminUsers}/$userId/unban');
      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> warnUser(String userId, String message) async {
    try {
      final response = await _client.post(
        '${ApiConfig.adminUsers}/$userId/warn',
        data: {'message': message},
      );
      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Support Tickets ────────────────────────────────────────
  Future<ApiResponse<List<SupportTicket>>> getTickets({
    int page = 1,
    TicketStatus? status,
    TicketPriority? priority,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (status != null) params['status'] = status.name;
      if (priority != null) params['priority'] = priority.name;

      final response = await _client.get(
        ApiConfig.adminTickets,
        queryParameters: params,
      );
      if (response.success) {
        return ApiResponse.success(data: <SupportTicket>[]);
      }
      return ApiResponse.error(
          message: response.message ?? 'Failed to load tickets');
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> replyToTicket(
    String ticketId,
    String message,
  ) async {
    try {
      final response = await _client.post(
        '${ApiConfig.adminTickets}/$ticketId/reply',
        data: {'message': message},
      );
      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> updateTicketStatus(
    String ticketId,
    TicketStatus status,
  ) async {
    try {
      final response = await _client.put(
        '${ApiConfig.adminTickets}/$ticketId/status',
        data: {'status': status.name},
      );
      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Moderation ─────────────────────────────────────────────
  Future<ApiResponse<List<ModerationReport>>> getReports({
    int page = 1,
    ReportStatus? status,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (status != null) params['status'] = status.name;

      final response = await _client.get(
        ApiConfig.adminReports,
        queryParameters: params,
      );
      if (response.success) {
        return ApiResponse.success(data: <ModerationReport>[]);
      }
      return ApiResponse.error(
          message: response.message ?? 'Failed to load reports');
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> actionReport(
    String reportId,
    String action,
  ) async {
    try {
      final response = await _client.post(
        '${ApiConfig.adminReports}/$reportId/action',
        data: {'action': action},
      );
      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Analytics ──────────────────────────────────────────────
  Future<ApiResponse<PlatformAnalytics>> getAnalytics() async {
    try {
      await _client.get(ApiConfig.adminAnalytics);
      return ApiResponse.success(data: _buildMockAnalytics());
    } catch (e) {
      return ApiResponse.success(data: _buildMockAnalytics());
    }
  }

  // ─── Email Campaigns ────────────────────────────────────────
  Future<ApiResponse<bool>> sendCampaign(String campaignId) async {
    try {
      final response = await _client.post(
        '${ApiConfig.adminCampaigns}/$campaignId/send',
      );
      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<bool>> createCampaign(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiConfig.adminCampaigns,
        data: data,
      );
      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── System Settings ────────────────────────────────────────
  Future<ApiResponse<SystemSettings>> getSystemSettings() async {
    try {
      await _client.get(ApiConfig.adminSettings);
      return ApiResponse.success(data: const SystemSettings());
    } catch (e) {
      return ApiResponse.success(data: const SystemSettings());
    }
  }

  Future<ApiResponse<bool>> updateSystemSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final response = await _client.put(
        ApiConfig.adminSettings,
        data: settings,
      );
      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Audit Logs ─────────────────────────────────────────────
  Future<ApiResponse<List<AuditLog>>> getAuditLogs({int page = 1}) async {
    try {
      final response = await _client.get(
        ApiConfig.adminAuditLogs,
        queryParameters: {'page': page},
      );
      if (response.success) {
        return ApiResponse.success(data: <AuditLog>[]);
      }
      return ApiResponse.error(
          message: response.message ?? 'Failed to load audit logs');
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Helpers ────────────────────────────────────────────────
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

  PlatformAnalytics _buildMockAnalytics() {
    final now = DateTime.now();
    return PlatformAnalytics(
      totalUsers: 142850,
      activeUsersToday: 28420,
      activeUsersWeek: 89330,
      activeUsersMonth: 118600,
      newUsersToday: 1240,
      newUsersWeek: 8730,
      totalMessages: 48200000,
      messagesToday: 2840000,
      totalStories: 9600000,
      storiesToday: 84200,
      openTickets: 47,
      pendingReports: 23,
      serverLoad: 62.4,
      dailyActiveUsers: List.generate(
        14,
        (i) => DailyMetric(
          date: now.subtract(Duration(days: 13 - i)),
          value: 22000 + (i * 450) + (i % 3 == 0 ? 3200 : 0),
        ),
      ),
      dailyMessages: List.generate(
        14,
        (i) => DailyMetric(
          date: now.subtract(Duration(days: 13 - i)),
          value: 2200000 + (i * 45000) + (i % 2 == 0 ? 320000 : 0),
        ),
      ),
      dailyNewUsers: List.generate(
        14,
        (i) => DailyMetric(
          date: now.subtract(Duration(days: 13 - i)),
          value: 900 + (i * 22) + (i % 4 == 0 ? 200 : 0),
        ),
      ),
    );
  }
}
