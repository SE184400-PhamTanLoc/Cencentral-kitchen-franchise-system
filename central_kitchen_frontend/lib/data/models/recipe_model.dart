import 'ingredient_model.dart';

class RecipeModel {
  final int recipeId;
  final int outputIngredientId;
  final String outputIngredientName;
  final String? description;
  final String? createdByName;
  final List<RecipeInputModel> details;

  const RecipeModel({
    required this.recipeId,
    required this.outputIngredientId,
    required this.outputIngredientName,
    this.description,
    this.createdByName,
    required this.details,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      recipeId: json['recipeId'] ?? 0,
      outputIngredientId: json['outputIngredientId'] ?? 0,
      outputIngredientName: json['outputIngredientName'] ?? '',
      description: json['description'],
      createdByName: json['createdByName'],
      details: (json['details'] as List<dynamic>? ?? [])
          .map((item) => RecipeInputModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}
