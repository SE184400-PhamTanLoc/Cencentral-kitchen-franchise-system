class IngredientModel {
  final int ingredientId;
  final String name;
  final String sku;
  final String unit;
  final double unitPrice;
  final bool isRawMaterial;
  final double minStockLevel;
  final DateTime? createdAt;
  final double availableQuantity;
  final int batchCount;
  final DateOnly? latestExpiryDate;
  final String? latestBatchCode;
  final bool hasRecipe;
  final String? recipeDescription;
  final List<RecipeInputModel> recipeInputs;

  const IngredientModel({
    required this.ingredientId,
    required this.name,
    required this.sku,
    required this.unit,
    required this.unitPrice,
    required this.isRawMaterial,
    required this.minStockLevel,
    required this.createdAt,
    required this.availableQuantity,
    required this.batchCount,
    required this.latestExpiryDate,
    required this.latestBatchCode,
    required this.hasRecipe,
    required this.recipeDescription,
    required this.recipeInputs,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    DateOnly? parseDateOnly(dynamic value) {
      if (value == null) return null;
      final parsed = DateTime.tryParse(value.toString());
      if (parsed == null) return null;
      return DateOnly(parsed.year, parsed.month, parsed.day);
    }

    return IngredientModel(
      ingredientId: json['ingredientId'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      unit: json['unit'] ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      isRawMaterial: json['isRawMaterial'] ?? true,
      minStockLevel: (json['minStockLevel'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      availableQuantity: (json['availableQuantity'] as num?)?.toDouble() ?? 0,
      batchCount: json['batchCount'] ?? 0,
      latestExpiryDate: parseDateOnly(json['latestExpiryDate']),
      latestBatchCode: json['latestBatchCode'],
      hasRecipe: json['hasRecipe'] ?? false,
      recipeDescription: json['recipeDescription'],
      recipeInputs: (json['recipeInputs'] as List<dynamic>? ?? [])
          .map((item) => RecipeInputModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'name': name,
      'sku': sku,
      'unit': unit,
      'unitPrice': unitPrice,
      'isRawMaterial': isRawMaterial,
      'minStockLevel': minStockLevel,
      'createdAt': createdAt?.toIso8601String(),
      'availableQuantity': availableQuantity,
      'batchCount': batchCount,
      'latestExpiryDate': latestExpiryDate?.toString(),
      'latestBatchCode': latestBatchCode,
      'hasRecipe': hasRecipe,
      'recipeDescription': recipeDescription,
      'recipeInputs': recipeInputs.map((item) => item.toJson()).toList(),
    };
  }
}

class DateOnly {
  final int year;
  final int month;
  final int day;

  const DateOnly(this.year, this.month, this.day);

  @override
  String toString() {
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    return '$year-$mm-$dd';
  }
}

class RecipeInputModel {
  final int inputIngredientId;
  final String inputIngredientName;
  final String unit;
  final bool isRawMaterial;
  final double quantityRequired;

  const RecipeInputModel({
    required this.inputIngredientId,
    required this.inputIngredientName,
    required this.unit,
    required this.isRawMaterial,
    required this.quantityRequired,
  });

  factory RecipeInputModel.fromJson(Map<String, dynamic> json) {
    return RecipeInputModel(
      inputIngredientId: json['inputIngredientId'] ?? 0,
      inputIngredientName: json['inputIngredientName'] ?? '',
      unit: json['unit'] ?? '',
      isRawMaterial: json['isRawMaterial'] ?? true,
      quantityRequired: (json['quantityRequired'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inputIngredientId': inputIngredientId,
      'inputIngredientName': inputIngredientName,
      'unit': unit,
      'isRawMaterial': isRawMaterial,
      'quantityRequired': quantityRequired,
    };
  }
}
