/// Model đại diện một item trong giỏ hàng (local state).
class CartItemModel {
  final int ingredientId;
  final String name;
  final String unit;
  final double unitPrice;
  int quantity;

  CartItemModel({
    required this.ingredientId,
    required this.name,
    required this.unit,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get subtotal => unitPrice * quantity;

  CartItemModel copyWith({int? quantity}) => CartItemModel(
        ingredientId: ingredientId,
        name: name,
        unit: unit,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER MODELS (API Response)
// ─────────────────────────────────────────────────────────────────────────────

/// Phản hồi khi đặt hàng thành công.
class PlaceOrderResponse {
  final int orderId;
  final String orderCode;
  final String orderStatus;
  final double totalAmount;
  final DateTime? createdAt;
  final String message;

  const PlaceOrderResponse({
    required this.orderId,
    required this.orderCode,
    required this.orderStatus,
    required this.totalAmount,
    this.createdAt,
    required this.message,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) =>
      PlaceOrderResponse(
        orderId: json['orderId'] ?? 0,
        orderCode: json['orderCode'] ?? '',
        orderStatus: json['orderStatus'] ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
        message: json['message'] ?? '',
      );
}

/// Tóm tắt đơn hàng trong danh sách lịch sử.
class OrderSummaryModel {
  final int orderId;
  final String orderCode;
  final int storeId;
  final String storeName;
  final int kitchenId;
  final String kitchenName;
  final double totalAmount;
  final String orderStatus;
  final String? notes;
  final int itemCount;
  final String createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderSummaryModel({
    required this.orderId,
    required this.orderCode,
    required this.storeId,
    required this.storeName,
    required this.kitchenId,
    required this.kitchenName,
    required this.totalAmount,
    required this.orderStatus,
    this.notes,
    required this.itemCount,
    required this.createdByName,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) =>
      OrderSummaryModel(
        orderId: json['orderId'] ?? 0,
        orderCode: json['orderCode'] ?? '',
        storeId: json['storeId'] ?? 0,
        storeName: json['storeName'] ?? '',
        kitchenId: json['kitchenId'] ?? 0,
        kitchenName: json['kitchenName'] ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        orderStatus: json['orderStatus'] ?? '',
        notes: json['notes'],
        itemCount: json['itemCount'] ?? 0,
        createdByName: json['createdByName'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
      );
}

/// Một dòng chi tiết trong đơn hàng.
class OrderDetailItemModel {
  final int orderDetailId;
  final int ingredientId;
  final String ingredientName;
  final String unit;
  final double quantityOrdered;
  final double? quantityDelivered;
  final double unitPrice;
  double get subtotal => quantityOrdered * unitPrice;

  const OrderDetailItemModel({
    required this.orderDetailId,
    required this.ingredientId,
    required this.ingredientName,
    required this.unit,
    required this.quantityOrdered,
    this.quantityDelivered,
    required this.unitPrice,
  });

  factory OrderDetailItemModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailItemModel(
        orderDetailId: json['orderDetailId'] ?? 0,
        ingredientId: json['ingredientId'] ?? 0,
        ingredientName: json['ingredientName'] ?? '',
        unit: json['unit'] ?? '',
        quantityOrdered:
            (json['quantityOrdered'] as num?)?.toDouble() ?? 0,
        quantityDelivered:
            (json['quantityDelivered'] as num?)?.toDouble(),
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      );
}

/// Chi tiết đầy đủ một đơn hàng.
class OrderDetailModel extends OrderSummaryModel {
  final List<OrderDetailItemModel> items;

  const OrderDetailModel({
    required super.orderId,
    required super.orderCode,
    required super.storeId,
    required super.storeName,
    required super.kitchenId,
    required super.kitchenName,
    required super.totalAmount,
    required super.orderStatus,
    super.notes,
    required super.itemCount,
    required super.createdByName,
    super.createdAt,
    super.updatedAt,
    required this.items,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailModel(
        orderId: json['orderId'] ?? 0,
        orderCode: json['orderCode'] ?? '',
        storeId: json['storeId'] ?? 0,
        storeName: json['storeName'] ?? '',
        kitchenId: json['kitchenId'] ?? 0,
        kitchenName: json['kitchenName'] ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        orderStatus: json['orderStatus'] ?? '',
        notes: json['notes'],
        itemCount: json['itemCount'] ?? 0,
        createdByName: json['createdByName'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrderDetailItemModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

/// Tồn kho tại cửa hàng franchise.
class StoreInventoryModel {
  final int storeInventoryId;
  final int storeId;
  final int ingredientId;
  final String ingredientName;
  final String sku;
  final String unit;
  final double stockQuantity;
  final DateTime? lastUpdated;

  const StoreInventoryModel({
    required this.storeInventoryId,
    required this.storeId,
    required this.ingredientId,
    required this.ingredientName,
    required this.sku,
    required this.unit,
    required this.stockQuantity,
    this.lastUpdated,
  });

  factory StoreInventoryModel.fromJson(Map<String, dynamic> json) =>
      StoreInventoryModel(
        storeInventoryId: json['storeInventoryId'] ?? 0,
        storeId: json['storeId'] ?? 0,
        ingredientId: json['ingredientId'] ?? 0,
        ingredientName: json['ingredientName'] ?? '',
        sku: json['sku'] ?? '',
        unit: json['unit'] ?? '',
        stockQuantity:
            (json['stockQuantity'] as num?)?.toDouble() ?? 0,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.tryParse(json['lastUpdated'])
            : null,
      );
}

/// Item tiêu thụ/hao hụt để gửi lên API.
class ConsumeItemPayload {
  final int ingredientId;
  final double quantity;

  const ConsumeItemPayload({
    required this.ingredientId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'quantity': quantity,
      };
}
