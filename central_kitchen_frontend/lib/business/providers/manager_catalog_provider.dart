import 'package:flutter/material.dart';
import '../../data/datasources/manager_catalog_datasource.dart';
import '../../data/models/ingredient_model.dart';
import '../../data/models/recipe_model.dart';

class ManagerCatalogProvider extends ChangeNotifier {
  final ManagerCatalogDatasource _datasource;

  ManagerCatalogProvider(this._datasource);

  List<IngredientModel> _ingredients = [];
  List<RecipeModel> _recipes = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  List<IngredientModel> get ingredients => _ingredients;
  List<RecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCatalogData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _datasource.getIngredients(),
        _datasource.getRecipes(),
      ]);
      _ingredients = futures[0] as List<IngredientModel>;
      _recipes = futures[1] as List<RecipeModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createIngredient(Map<String, dynamic> body) async {
    await _datasource.createIngredient(body);
    await loadCatalogData();
  }

  Future<void> updateIngredient(int id, Map<String, dynamic> body) async {
    await _datasource.updateIngredient(id, body);
    await loadCatalogData();
  }

  Future<void> deleteIngredient(int id) async {
    await _datasource.deleteIngredient(id);
    await loadCatalogData();
  }

  Future<void> createRecipe(Map<String, dynamic> body) async {
    await _datasource.createRecipe(body);
    await loadCatalogData();
  }

  Future<void> updateRecipe(int id, Map<String, dynamic> body) async {
    await _datasource.updateRecipe(id, body);
    await loadCatalogData();
  }

  Future<void> deleteRecipe(int id) async {
    await _datasource.deleteRecipe(id);
    await loadCatalogData();
  }
}
