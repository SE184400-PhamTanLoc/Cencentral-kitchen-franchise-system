import '../../core/constants/franchise_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/notification_model.dart';

/// Datasource gọi các API Notification và Credit Info.
class NotificationDatasource {
  final ApiClient _apiClient;

  NotificationDatasource(this._apiClient);

  // ─── Thông báo ────────────────────────────────────────────────

  /// Lấy danh sách thông báo của user hiện tại.
  Future<Map<String, dynamic>> getNotifications() async {
    final response = await _apiClient.get(FranchiseEndpoints.notifications);
    final data = response.data as Map<String, dynamic>;
    return {
      'unreadCount': data['unreadCount'] ?? 0,
      'totalCount': data['totalCount'] ?? 0,
      'items': (data['data'] as List<dynamic>? ?? [])
          .map((e) =>
              NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    };
  }

  /// Đánh dấu một thông báo là đã đọc.
  Future<void> markAsRead(int notificationId) async {
    await _apiClient.put(FranchiseEndpoints.markRead(notificationId));
  }

  /// Đánh dấu tất cả thông báo là đã đọc.
  Future<void> markAllAsRead() async {
    await _apiClient.put(FranchiseEndpoints.markAllRead);
  }

  // ─── Credit Info ──────────────────────────────────────────────

  /// Lấy thông tin công nợ và hạn mức tín dụng của cửa hàng.
  Future<StoreCreditInfoModel> getStoreCreditInfo(int storeId) async {
    final response =
        await _apiClient.get(FranchiseEndpoints.creditInfo(storeId));
    return StoreCreditInfoModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map));
  }

  // ─── Order actions ────────────────────────────────────────────

  /// Hủy đơn hàng Pending.
  Future<Map<String, dynamic>> cancelOrder(
      int orderId, String reason) async {
    final response = await _apiClient.put(
      FranchiseEndpoints.cancelOrder(orderId),
      data: {'reason': reason},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
