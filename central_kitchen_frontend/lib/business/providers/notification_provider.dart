import 'package:flutter/material.dart';
import '../../data/datasources/notification_datasource.dart';
import '../../data/models/notification_model.dart';

/// Provider quản lý thông báo và thông tin công nợ cửa hàng.
class NotificationProvider with ChangeNotifier {
  final NotificationDatasource _datasource;

  NotificationProvider(this._datasource);

  // ─── State ────────────────────────────────────────────────────

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StoreCreditInfoModel? _creditInfo;

  // ─── Getters ─────────────────────────────────────────────────

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasUnread => _unreadCount > 0;
  StoreCreditInfoModel? get creditInfo => _creditInfo;

  // ─── Load Notifications ───────────────────────────────────────

  Future<void> loadNotificationsAsync() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _datasource.getNotifications();
      _notifications =
          (data['items'] as List).cast<NotificationModel>();
      _unreadCount = data['unreadCount'] as int;
    } catch (_) {
      // Thất bại im lặng — không block UI
    }
    _isLoading = false;
    notifyListeners();
  }

  // ─── Mark Read ────────────────────────────────────────────────

  Future<void> markAsReadAsync(int notificationId) async {
    try {
      await _datasource.markAsRead(notificationId);
      // Cập nhật local state ngay lập tức
      _notifications = _notifications
          .map((n) => n.notificationId == notificationId
              ? n.copyWith(isRead: true)
              : n)
          .toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllAsReadAsync() async {
    try {
      await _datasource.markAllAsRead();
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  // ─── Credit Info ──────────────────────────────────────────────

  Future<void> loadCreditInfoAsync(int storeId) async {
    try {
      _creditInfo = await _datasource.getStoreCreditInfo(storeId);
      notifyListeners();
    } catch (_) {}
  }

  // ─── Cancel Order ─────────────────────────────────────────────

  bool _isCancelling = false;
  String? _cancelError;

  bool get isCancelling => _isCancelling;
  String? get cancelError => _cancelError;

  Future<bool> cancelOrderAsync(int orderId, String reason) async {
    _isCancelling = true;
    _cancelError = null;
    notifyListeners();
    try {
      await _datasource.cancelOrder(orderId, reason);
      _isCancelling = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isCancelling = false;
      _cancelError = 'Không thể hủy đơn hàng. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
  }
}
