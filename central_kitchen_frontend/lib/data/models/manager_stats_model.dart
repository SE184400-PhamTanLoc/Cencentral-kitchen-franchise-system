class ManagerStatsModel {
  final int totalStores;
  final int totalPendingOrders;
  final double totalDebt;
  final double todayRevenue;
  final int dispatchedOrders;
  final int approvedOrders;

  ManagerStatsModel({
    required this.totalStores,
    required this.totalPendingOrders,
    required this.totalDebt,
    required this.todayRevenue,
    required this.dispatchedOrders,
    required this.approvedOrders,
  });

  factory ManagerStatsModel.fromJson(Map<String, dynamic> json) {
    return ManagerStatsModel(
      totalStores: json['totalStores'] ?? 0,
      totalPendingOrders: json['totalPendingOrders'] ?? 0,
      totalDebt: (json['totalDebt'] ?? 0).toDouble(),
      todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
      dispatchedOrders: json['dispatchedOrders'] ?? 0,
      approvedOrders: json['approvedOrders'] ?? 0,
    );
  }
}

class ManagerPendingOrderModel {
  final int orderId;
  final String orderCode;
  final String storeName;
  final int storeId;
  final int itemCount;
  final String orderStatus;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime orderDate;
  final DateTime? updatedAt;
  final String notes;

  ManagerPendingOrderModel({
    required this.orderId,
    required this.orderCode,
    required this.storeName,
    required this.storeId,
    required this.itemCount,
    required this.orderStatus,
    required this.totalAmount,
    required this.createdAt,
    required this.orderDate,
    required this.updatedAt,
    required this.notes,
  });

  factory ManagerPendingOrderModel.fromJson(Map<String, dynamic> json) {
    return ManagerPendingOrderModel(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      storeName: json['storeName'] ?? '',
      storeId: json['storeId'] ?? 0,
      itemCount: json['itemCount'] ?? 0,
      orderStatus: json['orderStatus'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      notes: json['notes'] ?? '',
    );
  }
}
