class ChainInventoryModel {
  final int ingredientId;
  final String ingredientName;
  final String unit;
  final double kitchenStock;
  final double storeStock;
  final double totalStock;

  ChainInventoryModel({
    required this.ingredientId,
    required this.ingredientName,
    required this.unit,
    required this.kitchenStock,
    required this.storeStock,
    required this.totalStock,
  });

  factory ChainInventoryModel.fromJson(Map<String, dynamic> json) {
    return ChainInventoryModel(
      ingredientId: json['ingredientId'] ?? 0,
      ingredientName: json['ingredientName'] ?? '',
      unit: json['unit'] ?? '',
      kitchenStock: (json['kitchenStock'] as num?)?.toDouble() ?? 0,
      storeStock: (json['storeStock'] as num?)?.toDouble() ?? 0,
      totalStock: (json['totalStock'] as num?)?.toDouble() ?? 0,
    );
  }
}
