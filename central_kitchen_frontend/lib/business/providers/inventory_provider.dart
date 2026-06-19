import 'package:flutter/material.dart';
import '../../data/datasources/inventory_datasource.dart';
import '../../data/models/batch_model.dart';
import '../../data/models/ingredient_model.dart';
import '../../data/models/production_plan_model.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryDatasource _inventoryDatasource;

  InventoryProvider(this._inventoryDatasource);

  final List<IngredientModel> _ingredients = [];
  final List<BatchModel> _batches = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool? _rawFilter;
  String _batchSearchQuery = '';
  String _batchStatusFilter = 'all';
  IngredientModel? _selectedIngredient;
  ProductionPlanModel? _productionPlan;

  List<IngredientModel> get ingredients => _ingredients;
  List<BatchModel> get batches => _batches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool? get rawFilter => _rawFilter;
  String get batchSearchQuery => _batchSearchQuery;
  String get batchStatusFilter => _batchStatusFilter;
  IngredientModel? get selectedIngredient => _selectedIngredient;
  ProductionPlanModel? get productionPlan => _productionPlan;

  List<IngredientModel> get filteredIngredients {
    return _ingredients.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _rawFilter == null || item.isRawMaterial == _rawFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<BatchModel> get filteredBatches {
    return _batches.where((batch) {
      final matchesSearch = batch.batchCode.toLowerCase().contains(_batchSearchQuery.toLowerCase()) ||
          batch.ingredientName.toLowerCase().contains(_batchSearchQuery.toLowerCase());
      final matchesStatus = switch (_batchStatusFilter) {
        'expired' => batch.isExpired,
        'active' => !batch.isExpired,
        _ => true,
      };
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> fetchIngredients({bool? isRawMaterial, String? keyword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final items = await _inventoryDatasource.getIngredients(
        isRawMaterial: isRawMaterial ?? _rawFilter,
        keyword: keyword ?? (_searchQuery.isEmpty ? null : _searchQuery),
      );
      _ingredients
        ..clear()
        ..addAll(items);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tải danh sách nguyên liệu.';
      notifyListeners();
    }
  }

  Future<void> fetchIngredientDetail(int ingredientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedIngredient = await _inventoryDatasource.getIngredientById(ingredientId);
      _batches
        ..clear()
        ..addAll(_selectedIngredient == null ? [] : []);
      if (_selectedIngredient != null) {
        _batches.addAll(await _inventoryDatasource.getBatches(ingredientId: ingredientId));
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tải chi tiết nguyên liệu.';
      notifyListeners();
    }
  }

  Future<void> loadKitchenInventory({int? kitchenId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _inventoryDatasource.getIngredients(),
        _inventoryDatasource.getBatches(kitchenId: kitchenId),
      ]);
      _ingredients
        ..clear()
        ..addAll(results[0] as List<IngredientModel>);
      _batches
        ..clear()
        ..addAll(results[1] as List<BatchModel>);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tải dữ liệu kho của bếp.';
      notifyListeners();
    }
  }

  Future<void> refreshBatches({int? ingredientId, int? kitchenId}) async {
    try {
      _batches
        ..clear()
        ..addAll(await _inventoryDatasource.getBatches(ingredientId: ingredientId, kitchenId: kitchenId));
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách lô.';
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setRawFilter(bool? value) {
    _rawFilter = value;
    notifyListeners();
  }

  Future<bool> createBatch(Map<String, dynamic> payload) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final created = await _inventoryDatasource.createBatch(payload);
      _batches.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Tạo lô thất bại.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBatch(int batchId, Map<String, dynamic> payload) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _inventoryDatasource.updateBatch(batchId, payload);
      final index = _batches.indexWhere((batch) => batch.batchId == batchId);
      if (index != -1) {
        _batches[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Cập nhật lô thất bại.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBatch(int batchId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _inventoryDatasource.deleteBatch(batchId);
      _batches.removeWhere((batch) => batch.batchId == batchId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Xóa lô thất bại.';
      notifyListeners();
      return false;
    }
  }

  void clearProductionPlan() {
    _productionPlan = null;
    notifyListeners();
  }

  void setBatchSearchQuery(String value) {
    _batchSearchQuery = value;
    notifyListeners();
  }

  void setBatchStatusFilter(String value) {
    _batchStatusFilter = value;
    notifyListeners();
  }

  Future<bool> buildProductionPlan(int outputIngredientId, double requestedQuantity) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _productionPlan = await _inventoryDatasource.buildProductionPlan({
        'outputIngredientId': outputIngredientId,
        'requestedQuantity': requestedQuantity,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tính BOM.';
      notifyListeners();
      return false;
    }
  }
}
