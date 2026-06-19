class BatchModel {
  final int batchId;
  final String batchCode;
  final int ingredientId;
  final String ingredientName;
  final double quantity;
  final double remainingQuantity;
  final DateTime? manufactureDate;
  final DateTime expiryDate;
  final int kitchenId;
  final String kitchenName;
  final DateTime? createdAt;
  final bool isExpired;

  const BatchModel({
    required this.batchId,
    required this.batchCode,
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.remainingQuantity,
    required this.manufactureDate,
    required this.expiryDate,
    required this.kitchenId,
    required this.kitchenName,
    required this.createdAt,
    required this.isExpired,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      batchId: json['batchId'] ?? 0,
      batchCode: json['batchCode'] ?? '',
      ingredientId: json['ingredientId'] ?? 0,
      ingredientName: json['ingredientName'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      remainingQuantity: (json['remainingQuantity'] as num?)?.toDouble() ?? 0,
      manufactureDate: json['manufactureDate'] != null ? DateTime.tryParse(json['manufactureDate'].toString()) : null,
      expiryDate: DateTime.tryParse(json['expiryDate']?.toString() ?? '') ?? DateTime.now(),
      kitchenId: json['kitchenId'] ?? 0,
      kitchenName: json['kitchenName'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      isExpired: json['isExpired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchCode': batchCode,
      'ingredientId': ingredientId,
      'quantity': quantity,
      'remainingQuantity': remainingQuantity,
      'manufactureDate': manufactureDate?.toIso8601String().split('T').first,
      'expiryDate': expiryDate.toIso8601String().split('T').first,
      'kitchenId': kitchenId,
    };
  }
}

