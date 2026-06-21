import '../../core/network/api_client.dart';
import '../models/ingredient_model.dart';
import '../models/recipe_model.dart';

class ManagerCatalogDatasource {
  final ApiClient _apiClient;

  ManagerCatalogDatasource(this._apiClient);

  Future<List<IngredientModel>> getIngredients() async {
    final response = await _apiClient.get('/api/ingredients');
    final dataList = response.data['data'] as List<dynamic>;
    return dataList.map((json) => IngredientModel.fromJson(json)).toList();
  }

  Future<IngredientModel> createIngredient(Map<String, dynamic> body) async {
    final response = await _apiClient.post('/api/ingredients', data: body);
    return IngredientModel.fromJson(response.data['data']);
  }

  Future<IngredientModel> updateIngredient(int id, Map<String, dynamic> body) async {
    final response = await _apiClient.put('/api/ingredients/$id', data: body);
    return IngredientModel.fromJson(response.data['data']);
  }

  Future<void> deleteIngredient(int id) async {
    await _apiClient.delete('/api/ingredients/$id');
  }

  Future<List<RecipeModel>> getRecipes() async {
    final response = await _apiClient.get('/api/recipes');
    final dataList = response.data['data'] as List<dynamic>;
    return dataList.map((json) => RecipeModel.fromJson(json)).toList();
  }

  Future<RecipeModel> createRecipe(Map<String, dynamic> body) async {
    final response = await _apiClient.post('/api/recipes', data: body);
    return RecipeModel.fromJson(response.data['data']);
  }

  Future<RecipeModel> updateRecipe(int id, Map<String, dynamic> body) async {
    final response = await _apiClient.put('/api/recipes/$id', data: body);
    return RecipeModel.fromJson(response.data['data']);
  }

  Future<void> deleteRecipe(int id) async {
    await _apiClient.delete('/api/recipes/$id');
  }
}
