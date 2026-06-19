import '../../core/constants/inventory_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/batch_model.dart';
import '../models/ingredient_model.dart';
import '../models/production_plan_model.dart';

class InventoryDatasource {
  final ApiClient _apiClient;

  InventoryDatasource(this._apiClient);

  Future<List<IngredientModel>> getIngredients({bool? isRawMaterial, String? keyword}) async {
    final response = await _apiClient.get(
      InventoryEndpoints.ingredients,
      queryParameters: {
        ...?(isRawMaterial == null ? null : {'isRawMaterial': isRawMaterial}),
        ...?(keyword == null || keyword.trim().isEmpty ? null : {'keyword': keyword.trim()}),
      },
    );

    final List<dynamic> dataList = response.data['data'] ?? [];
    return dataList.map((json) => IngredientModel.fromJson(Map<String, dynamic>.from(json as Map))).toList();
  }

  Future<IngredientModel> getIngredientById(int ingredientId) async {
    final response = await _apiClient.get('${InventoryEndpoints.ingredients}/$ingredientId');
    return IngredientModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<List<BatchModel>> getBatches({int? ingredientId, int? kitchenId}) async {
    final response = await _apiClient.get(
      InventoryEndpoints.batches,
      queryParameters: {
        ...?(ingredientId == null ? null : {'ingredientId': ingredientId}),
        ...?(kitchenId == null ? null : {'kitchenId': kitchenId}),
      },
    );

    final List<dynamic> dataList = response.data['data'] ?? [];
    return dataList.map((json) => BatchModel.fromJson(Map<String, dynamic>.from(json as Map))).toList();
  }

  Future<BatchModel> createBatch(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(InventoryEndpoints.batches, data: payload);
    return BatchModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<BatchModel> updateBatch(int batchId, Map<String, dynamic> payload) async {
    final response = await _apiClient.put('${InventoryEndpoints.batches}/$batchId', data: payload);
    return BatchModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<void> deleteBatch(int batchId) async {
    await _apiClient.delete('${InventoryEndpoints.batches}/$batchId');
  }

  Future<ProductionPlanModel> buildProductionPlan(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(InventoryEndpoints.productionPlan, data: payload);
    return ProductionPlanModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<List<dynamic>> getPendingOrders(int kitchenId) async {
    final response = await _apiClient.get(
      InventoryEndpoints.pendingOrders,
      queryParameters: {'kitchenId': kitchenId},
    );
    return response.data['data'] ?? [];
  }

  Future<ProductionPlanModel> buildAutoProductionPlan(int kitchenId) async {
    final response = await _apiClient.post(
      InventoryEndpoints.autoProductionPlan,
      queryParameters: {'kitchenId': kitchenId},
    );
    return ProductionPlanModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }
}
