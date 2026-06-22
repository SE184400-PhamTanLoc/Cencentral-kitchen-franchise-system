class ManagerStatsModel {
  final int totalStores;
  final int totalPendingOrders;
  final double totalDebt;
  final double todayRevenue;

  ManagerStatsModel({
    required this.totalStores,
    required this.totalPendingOrders,
    required this.totalDebt,
    required this.todayRevenue,
  });

  factory ManagerStatsModel.fromJson(Map<String, dynamic> json) {
    return ManagerStatsModel(
      totalStores: json['totalStores'] ?? 0,
      totalPendingOrders: json['totalPendingOrders'] ?? 0,
      totalDebt: (json['totalDebt'] ?? 0).toDouble(),
      todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
    );
  }
}

class ManagerPendingOrderModel {
  final int orderId;
  final String orderCode;
  final String storeName;
  final double totalAmount;
  final DateTime createdAt;
  final String notes;

  ManagerPendingOrderModel({
    required this.orderId,
    required this.orderCode,
    required this.storeName,
    required this.totalAmount,
    required this.createdAt,
    required this.notes,
  });

  factory ManagerPendingOrderModel.fromJson(Map<String, dynamic> json) {
    return ManagerPendingOrderModel(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      storeName: json['storeName'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      notes: json['notes'] ?? '',
    );
  }
}
