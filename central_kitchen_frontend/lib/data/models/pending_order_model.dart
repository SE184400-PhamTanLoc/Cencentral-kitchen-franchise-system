class PendingOrderModel {
  final int orderId;
  final String orderCode;
  final int storeId;
  final String storeName;
  final String orderStatus;
  final DateTime? createdAt;
  final List<PendingOrderDetailModel> orderDetails;

  PendingOrderModel({
    required this.orderId,
    required this.orderCode,
    required this.storeId,
    required this.storeName,
    required this.orderStatus,
    this.createdAt,
    required this.orderDetails,
  });

  factory PendingOrderModel.fromJson(Map<String, dynamic> json) {
    return PendingOrderModel(
      orderId: json['orderId'],
      orderCode: json['orderCode'] ?? '',
      storeId: json['storeId'],
      storeName: json['storeName'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      orderDetails: (json['orderDetails'] as List<dynamic>?)
              ?.map((item) => PendingOrderDetailModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PendingOrderDetailModel {
  final int ingredientId;
  final String ingredientName;
  final String unit;
  final double quantityOrdered;

  PendingOrderDetailModel({
    required this.ingredientId,
    required this.ingredientName,
    required this.unit,
    required this.quantityOrdered,
  });

  factory PendingOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return PendingOrderDetailModel(
      ingredientId: json['ingredientId'],
      ingredientName: json['ingredientName'] ?? '',
      unit: json['unit'] ?? '',
      quantityOrdered: (json['quantityOrdered'] as num).toDouble(),
    );
  }
}
