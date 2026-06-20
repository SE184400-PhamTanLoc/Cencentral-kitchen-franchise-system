/// Model thông báo trả về từ GET /api/notifications
class NotificationModel {
  final int notificationId;
  final int userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final String timeAgo;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notificationId: json['notificationId'] ?? 0,
        userId: json['userId'] ?? 0,
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        isRead: json['isRead'] ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
        timeAgo: json['timeAgo'] ?? '',
      );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        notificationId: notificationId,
        userId: userId,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        timeAgo: timeAgo,
      );
}

/// Model thông tin công nợ cửa hàng
class StoreCreditInfoModel {
  final int storeId;
  final String storeName;
  final double creditLimit;
  final double currentDebt;
  final double availableCredit;
  final double usagePercent;
  final bool canPlaceOrder;
  final int pendingOrderCount;
  final int activeOrderCount;

  const StoreCreditInfoModel({
    required this.storeId,
    required this.storeName,
    required this.creditLimit,
    required this.currentDebt,
    required this.availableCredit,
    required this.usagePercent,
    required this.canPlaceOrder,
    required this.pendingOrderCount,
    required this.activeOrderCount,
  });

  factory StoreCreditInfoModel.fromJson(Map<String, dynamic> json) =>
      StoreCreditInfoModel(
        storeId: json['storeId'] ?? 0,
        storeName: json['storeName'] ?? '',
        creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0,
        currentDebt: (json['currentDebt'] as num?)?.toDouble() ?? 0,
        availableCredit: (json['availableCredit'] as num?)?.toDouble() ?? 0,
        usagePercent: (json['usagePercent'] as num?)?.toDouble() ?? 0,
        canPlaceOrder: json['canPlaceOrder'] ?? true,
        pendingOrderCount: json['pendingOrderCount'] ?? 0,
        activeOrderCount: json['activeOrderCount'] ?? 0,
      );
}
