class ProductionPlanItemModel {
  final int ingredientId;
  final String ingredientName;
  final String sku;
  final String unit;
  final bool isRawMaterial;
  final double requiredQuantity;
  final double availableQuantity;
  final double shortageQuantity;

  const ProductionPlanItemModel({
    required this.ingredientId,
    required this.ingredientName,
    required this.sku,
    required this.unit,
    required this.isRawMaterial,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.shortageQuantity,
  });

  factory ProductionPlanItemModel.fromJson(Map<String, dynamic> json) {
    return ProductionPlanItemModel(
      ingredientId: json['ingredientId'] ?? 0,
      ingredientName: json['ingredientName'] ?? '',
      sku: json['sku'] ?? '',
      unit: json['unit'] ?? '',
      isRawMaterial: json['isRawMaterial'] ?? true,
      requiredQuantity: (json['requiredQuantity'] as num?)?.toDouble() ?? 0,
      availableQuantity: (json['availableQuantity'] as num?)?.toDouble() ?? 0,
      shortageQuantity: (json['shortageQuantity'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProductionPlanModel {
  final int outputIngredientId;
  final String outputIngredientName;
  final String? outputSku;
  final String? recipeDescription;
  final double requestedQuantity;
  final List<ProductionPlanItemModel> materials;

  const ProductionPlanModel({
    required this.outputIngredientId,
    required this.outputIngredientName,
    required this.outputSku,
    required this.recipeDescription,
    required this.requestedQuantity,
    required this.materials,
  });

  factory ProductionPlanModel.fromJson(Map<String, dynamic> json) {
    final materialList = (json['materials'] as List<dynamic>? ?? [])
        .map((e) => ProductionPlanItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ProductionPlanModel(
      outputIngredientId: json['outputIngredientId'] ?? 0,
      outputIngredientName: json['outputIngredientName'] ?? '',
      outputSku: json['outputSku'],
      recipeDescription: json['recipeDescription'],
      requestedQuantity: (json['requestedQuantity'] as num?)?.toDouble() ?? 0,
      materials: materialList,
    );
  }
}

