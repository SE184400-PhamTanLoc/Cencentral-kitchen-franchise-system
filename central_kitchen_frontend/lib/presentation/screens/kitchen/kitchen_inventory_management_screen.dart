import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/inventory_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/ingredient_model.dart';
import '../../../data/models/production_plan_model.dart';
import 'inventory_product_detail_screen.dart';

class KitchenInventoryManagementScreen extends StatefulWidget {
  const KitchenInventoryManagementScreen({super.key});

  @override
  State<KitchenInventoryManagementScreen> createState() => _KitchenInventoryManagementScreenState();
}

class _KitchenInventoryManagementScreenState extends State<KitchenInventoryManagementScreen> {
  final _bomQuantityController = TextEditingController(text: '1');
  int? _selectedIngredientId;
  int _selectedSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<InventoryProvider>().loadKitchenInventory(kitchenId: auth.kitchenId);
    });
  }

  @override
  void dispose() {
    _bomQuantityController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _openUserMenu(BuildContext context) {
    final auth = context.read<AuthProvider>();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      _avatarInitial(auth.currentUser?.fullName),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(auth.currentUser?.fullName ?? 'Nhân viên bếp'),
                  subtitle: Text(auth.currentUser?.roleName ?? 'Kitchen staff'),
                ),
                const SizedBox(height: 8),
                _MenuTile(
                  icon: Icons.badge_outlined,
                  title: 'Trang cá nhân',
                  subtitle: 'Xem thông tin tài khoản hiện tại',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _selectedSectionIndex = 0);
                  },
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.logout_outlined,
                  title: 'Đăng xuất',
                  subtitle: 'Thoát khỏi tài khoản hiện tại',
                  danger: true,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _logout(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<InventoryProvider>();
    final ingredients = provider.filteredIngredients;
    final batches = provider.filteredBatches;
    final selectedIngredient = _findIngredient(provider.ingredients, _selectedIngredientId);
    final pages = <Widget>[
      _OverviewTab(
        ingredientCount: provider.ingredients.length,
        batchCount: provider.batches.length,
        lowStockCount: provider.ingredients.where((item) => item.availableQuantity <= item.minStockLevel).length,
        expiredBatchCount: provider.batches.where((batch) => batch.isExpired).length,
        onImportStock: () => _openQuickBatchSheet(context, auth.kitchenId, provider.ingredients),
        onOpenBom: () => setState(() => _selectedSectionIndex = 3),
      ),
      _IngredientsTab(
        ingredients: ingredients,
        searchQuery: provider.searchQuery,
        rawFilter: provider.rawFilter,
        onSearchChanged: (value) {
          provider.setSearchQuery(value);
          provider.fetchIngredients(keyword: value);
        },
        onFilterChanged: (value) {
          provider.setRawFilter(value);
          provider.fetchIngredients(isRawMaterial: value);
        },
        onTapIngredient: (ingredient) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => InventoryProductDetailScreen(ingredient: ingredient)),
          );
        },
      ),
      _BatchesTab(
        batches: batches,
        searchQuery: provider.batchSearchQuery,
        statusFilter: provider.batchStatusFilter,
        ingredientLookup: {
          for (final ingredient in provider.ingredients) ingredient.ingredientId: ingredient,
        },
        onSearchChanged: provider.setBatchSearchQuery,
        onFilterChanged: provider.setBatchStatusFilter,
        onTapBatch: (batch) {
          final ingredient = provider.ingredients.firstWhere(
            (item) => item.ingredientId == batch.ingredientId,
            orElse: () => provider.ingredients.isNotEmpty ? provider.ingredients.first : _fallbackIngredient(batch),
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => InventoryProductDetailScreen(ingredient: ingredient)),
          );
        },
      ),
      _BomTab(
        ingredients: provider.ingredients,
        selectedIngredientId: _selectedIngredientId,
        selectedIngredient: selectedIngredient,
        quantityController: _bomQuantityController,
        productionPlan: provider.productionPlan,
        onIngredientChanged: (value) => setState(() => _selectedIngredientId = value),
        onCalculate: () async {
          final ingredientId = _selectedIngredientId;
          if (ingredientId == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn nguyên liệu đầu ra.')));
            return;
          }
          final qty = double.tryParse(_bomQuantityController.text) ?? 0;
          if (qty <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số lượng phải lớn hơn 0.')));
            return;
          }
          final success = await provider.buildProductionPlan(ingredientId, qty);
          if (!context.mounted) return;
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.errorMessage ?? 'Không thể tính BOM.')),
            );
          }
        },
        onClear: provider.clearProductionPlan,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        toolbarHeight: 78,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, ${auth.currentUser?.fullName ?? 'Nhân viên bếp'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
            const SizedBox(height: 3),
            const Text(
              'Quản lý kho bếp và thao tác nhanh',
              style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () => context.read<InventoryProvider>().loadKitchenInventory(kitchenId: auth.kitchenId),
            icon: const Icon(Icons.refresh_outlined),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _openUserMenu(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary,
                child: Text(
                  _avatarInitial(auth.currentUser?.fullName),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
      body: provider.isLoading && provider.ingredients.isEmpty && provider.batches.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedSectionIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedSectionIndex,
        onTap: (index) => setState(() => _selectedSectionIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.onSurfaceVariant,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Nguyên liệu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list_outlined),
            label: 'Batches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            label: 'BOM',
          ),
        ],
      ),
    );
  }

  IngredientModel? _findIngredient(List<IngredientModel> ingredients, int? ingredientId) {
    if (ingredientId == null) return null;
    for (final ingredient in ingredients) {
      if (ingredient.ingredientId == ingredientId) {
        return ingredient;
      }
    }
    return null;
  }

  IngredientModel _fallbackIngredient(BatchModel batch) {
    return IngredientModel(
      ingredientId: batch.ingredientId,
      name: batch.ingredientName,
      sku: batch.ingredientName,
      unit: 'Unit',
      unitPrice: 0,
      isRawMaterial: true,
      minStockLevel: 0,
      createdAt: null,
      availableQuantity: 0,
      batchCount: 0,
      latestExpiryDate: null,
      latestBatchCode: null,
      hasRecipe: false,
      recipeDescription: null,
      recipeInputs: const [],
    );
  }

  String _avatarInitial(String? fullName) {
    final name = (fullName ?? 'K').trim();
    if (name.isEmpty) return 'K';
    return name.characters.first.toUpperCase();
  }
}

class _OverviewTab extends StatelessWidget {
  final int ingredientCount;
  final int batchCount;
  final int lowStockCount;
  final int expiredBatchCount;
  final VoidCallback onImportStock;
  final VoidCallback onOpenBom;

  const _OverviewTab({
    required this.ingredientCount,
    required this.batchCount,
    required this.lowStockCount,
    required this.expiredBatchCount,
    required this.onImportStock,
    required this.onOpenBom,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng quan kho bếp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Quản lý nguyên liệu, batch và BOM ngay từ màn này.',
                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onImportStock,
                        icon: const Icon(Icons.playlist_add_circle_outlined),
                        label: const Text('Nhập kho'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpenBom,
                        icon: const Icon(Icons.calculate_outlined),
                        label: const Text('Mở BOM'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _MetricCard(title: 'Tồn thấp', value: lowStockCount.toString(), icon: Icons.warning_amber_rounded, color: Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: 'Batch hết hạn', value: expiredBatchCount.toString(), icon: Icons.event_busy_outlined, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          _WorkflowCard(
            title: 'Quy trình bếp',
            items: const [
              '1. Mở tab Nguyên liệu để theo dõi tồn kho.',
              '2. Chọn một nguyên liệu để xem batch, sửa hoặc xóa.',
              '3. Dùng tab BOM để tính nhanh định mức xuất kho.',
            ],
          ),
        ],
      ),
    );
  }
}

extension on _KitchenInventoryManagementScreenState {
  Future<void> _openQuickBatchSheet(
    BuildContext hostContext,
    int? kitchenId,
    List<IngredientModel> ingredients,
  ) async {
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(hostContext).showSnackBar(
        const SnackBar(content: Text('Chưa có nguyên liệu để nhập kho.')),
      );
      return;
    }

    final ingredientIdController = TextEditingController(text: ingredients.first.ingredientId.toString());
    final batchCodeController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final remainingController = TextEditingController(text: '1');
    final manufactureDateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
    final expiryDateController = TextEditingController();

    await showModalBottomSheet(
      context: hostContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (sheetContext, setState) {
              Future<void> pickDate(TextEditingController controller) async {
                final initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
                final selected = await showDatePicker(
                  context: sheetContext,
                  initialDate: initialDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (selected != null && sheetContext.mounted) {
                  controller.text = selected.toIso8601String().split('T').first;
                  setState(() {});
                }
              }

              final selectedIngredientId = int.tryParse(ingredientIdController.text);
              final selectedIngredient = ingredients.firstWhere(
                (item) => item.ingredientId == selectedIngredientId,
                orElse: () => ingredients.first,
              );

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhập kho nhanh',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tạo batch mới để ghi nhận nguyên liệu vừa nhập về bếp.',
                      style: TextStyle(color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<int>(
                      value: selectedIngredient.ingredientId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Nguyên liệu'),
                      items: ingredients
                          .map(
                            (ingredient) => DropdownMenuItem<int>(
                              value: ingredient.ingredientId,
                              child: Text(ingredient.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        ingredientIdController.text = value.toString();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: batchCodeController,
                            decoration: const InputDecoration(labelText: 'Mã lô'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Tổng số lượng'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: remainingController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Số lượng còn lại'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: manufactureDateController,
                            readOnly: true,
                            onTap: () => pickDate(manufactureDateController),
                            decoration: const InputDecoration(
                              labelText: 'Ngày sản xuất',
                              suffixIcon: Icon(Icons.date_range_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: expiryDateController,
                      readOnly: true,
                      onTap: () => pickDate(expiryDateController),
                      decoration: const InputDecoration(
                        labelText: 'Hạn sử dụng',
                        suffixIcon: Icon(Icons.event_available_outlined),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final ingredientId = int.tryParse(ingredientIdController.text);
                          final quantity = double.tryParse(quantityController.text) ?? 0;
                          final remaining = double.tryParse(remainingController.text) ?? 0;

                          if (ingredientId == null || batchCodeController.text.trim().isEmpty || quantity <= 0 || expiryDateController.text.isEmpty) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đủ nguyên liệu, mã lô, số lượng và hạn sử dụng.')),
                            );
                            return;
                          }

                          final success = await sheetContext.read<InventoryProvider>().createBatch({
                            'batchCode': batchCodeController.text.trim(),
                            'ingredientId': ingredientId,
                            'quantity': quantity,
                            'remainingQuantity': remaining,
                            'manufactureDate': manufactureDateController.text.isEmpty ? null : manufactureDateController.text,
                            'expiryDate': expiryDateController.text,
                            'kitchenId': kitchenId,
                          });

                          if (!sheetContext.mounted) return;
                          if (success) {
                            Navigator.pop(sheetContext);
                            await hostContext.read<InventoryProvider>().loadKitchenInventory(kitchenId: kitchenId);
                            ScaffoldMessenger.of(hostContext).showSnackBar(
                              const SnackBar(content: Text('Nhập kho thành công!')),
                            );
                          } else {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(content: Text(sheetContext.read<InventoryProvider>().errorMessage ?? 'Nhập kho thất bại')),
                            );
                          }
                        },
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Lưu nhập kho'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primary)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _WorkflowCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(item, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsTab extends StatelessWidget {
  final List<IngredientModel> ingredients;
  final String searchQuery;
  final bool? rawFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool?> onFilterChanged;
  final ValueChanged<IngredientModel> onTapIngredient;

  const _IngredientsTab({
    required this.ingredients,
    required this.searchQuery,
    required this.rawFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onTapIngredient,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<InventoryProvider>().fetchIngredients(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SearchField(
            value: searchQuery,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
          _FilterChips(
            selected: rawFilter,
            onChanged: onFilterChanged,
          ),
          const SizedBox(height: 16),
          if (ingredients.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: Text('Không có nguyên liệu phù hợp.')),
            )
          else
            ...ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _IngredientCard(
                  ingredient: ingredient,
                  onTap: () => onTapIngredient(ingredient),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Tìm theo tên hoặc SKU',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: value.isEmpty
            ? null
            : IconButton(
                onPressed: () => onChanged(''),
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final bool? selected;
  final ValueChanged<bool?> onChanged;

  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = <({String label, bool? value})>[
      (label: 'Tất cả', value: null),
      (label: 'Nguyên liệu thô', value: true),
      (label: 'Bán thành phẩm', value: false),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(item.label),
                  selected: item.value == selected,
                  onSelected: (_) => onChanged(item.value),
                  selectedColor: AppTheme.primary.withOpacity(0.12),
                  labelStyle: TextStyle(color: item.value == selected ? AppTheme.primary : AppTheme.onSurfaceVariant),
                  side: const BorderSide(color: AppTheme.outlineVariant),
                  backgroundColor: Colors.white,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final IngredientModel ingredient;
  final VoidCallback onTap;

  const _IngredientCard({required this.ingredient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lowStock = ingredient.availableQuantity <= ingredient.minStockLevel;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    ingredient.isRawMaterial ? AppTheme.secondary : AppTheme.primaryContainer,
                    AppTheme.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(ingredient.isRawMaterial ? Icons.grain_outlined : Icons.bakery_dining_outlined, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                      ),
                      if (lowStock) const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('SKU: ${ingredient.sku}', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Tag(label: ingredient.isRawMaterial ? 'Raw' : 'BFP'),
                      _Tag(label: '${ingredient.availableQuantity.toStringAsFixed(1)} ${ingredient.unit}'),
                      _Tag(label: '${ingredient.batchCount} lô'),
                      if (ingredient.latestExpiryDate != null)
                        _Tag(label: 'HSD: ${ingredient.latestExpiryDate!.day.toString().padLeft(2, '0')}/${ingredient.latestExpiryDate!.month.toString().padLeft(2, '0')}/${ingredient.latestExpiryDate!.year}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant)),
    );
  }
}

class _BatchesTab extends StatelessWidget {
  final List<BatchModel> batches;
  final String searchQuery;
  final String statusFilter;
  final Map<int, IngredientModel> ingredientLookup;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<BatchModel> onTapBatch;

  const _BatchesTab({
    required this.batches,
    required this.searchQuery,
    required this.statusFilter,
    required this.ingredientLookup,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onTapBatch,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('all', 'Tất cả'),
      ('active', 'Còn hạn'),
      ('expired', 'Hết hạn'),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SearchField(
          value: searchQuery,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((item) {
              final selected = item.$1 == statusFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(item.$2),
                  selected: selected,
                  onSelected: (_) => onFilterChanged(item.$1),
                  selectedColor: AppTheme.primary.withOpacity(0.12),
                  labelStyle: TextStyle(color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant),
                  side: const BorderSide(color: AppTheme.outlineVariant),
                  backgroundColor: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (batches.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(child: Text('Không có batch phù hợp.')),
          )
        else
          ...batches.map(
            (batch) {
              final ingredient = ingredientLookup[batch.ingredientId];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BatchCard(
                  batch: batch,
                  onTap: () => onTapBatch(batch),
                  subtitle: ingredient?.name ?? batch.ingredientName,
                ),
              );
            },
          ),
      ],
    );
  }
}

class _BatchCard extends StatelessWidget {
  final BatchModel batch;
  final String subtitle;
  final VoidCallback onTap;

  const _BatchCard({
    required this.batch,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final expired = batch.isExpired;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(batch.batchCode, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: expired ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    expired ? 'Hết hạn' : 'Còn hạn',
                    style: TextStyle(color: expired ? Colors.red : Colors.green, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Còn lại ${batch.remainingQuantity.toStringAsFixed(2)} / ${batch.quantity.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('HSD: ${batch.expiryDate.day.toString().padLeft(2, '0')}/${batch.expiryDate.month.toString().padLeft(2, '0')}/${batch.expiryDate.year}', style: const TextStyle(color: AppTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _BomTab extends StatelessWidget {
  final List<IngredientModel> ingredients;
  final int? selectedIngredientId;
  final IngredientModel? selectedIngredient;
  final TextEditingController quantityController;
  final ProductionPlanModel? productionPlan;
  final ValueChanged<int?> onIngredientChanged;
  final VoidCallback onCalculate;
  final VoidCallback onClear;

  const _BomTab({
    required this.ingredients,
    required this.selectedIngredientId,
    required this.selectedIngredient,
    required this.quantityController,
    required this.productionPlan,
    required this.onIngredientChanged,
    required this.onCalculate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tính BOM nhanh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              const SizedBox(height: 8),
              const Text(
                'Chọn nguyên liệu đầu ra và nhập số lượng cần sản xuất để hệ thống quy đổi nguyên liệu thô tương ứng.',
                style: TextStyle(color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: selectedIngredientId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Nguyên liệu đầu ra'),
                items: ingredients
                    .map(
                      (ingredient) => DropdownMenuItem<int>(
                        value: ingredient.ingredientId,
                        child: Text(ingredient.name),
                      ),
                    )
                    .toList(),
                onChanged: onIngredientChanged,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng cần sản xuất',
                  prefixIcon: Icon(Icons.calculate_outlined),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCalculate,
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: const Text('Tính BOM'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: onClear,
                    child: const Text('Xóa kết quả'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (productionPlan == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: Text('Chưa có kết quả BOM.'),
            ),
          )
        else
          _BomResultCard(plan: productionPlan!),
      ],
    );
  }
}

class _BomResultCard extends StatelessWidget {
  final ProductionPlanModel plan;

  const _BomResultCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.outputIngredientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary)),
          const SizedBox(height: 4),
          Text('Số lượng yêu cầu: ${plan.requestedQuantity}', style: const TextStyle(color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 14),
          ...plan.materials.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.ingredientName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Text(
                        item.shortageQuantity > 0 ? 'Thiếu' : 'Đủ',
                        style: TextStyle(
                          color: item.shortageQuantity > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Cần: ${item.requiredQuantity.toStringAsFixed(2)} ${item.unit}'),
                  Text('Khả dụng: ${item.availableQuantity.toStringAsFixed(2)} ${item.unit}'),
                  if (item.shortageQuantity > 0)
                    Text('Thiếu: ${item.shortageQuantity.toStringAsFixed(2)} ${item.unit}', style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : AppTheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: danger ? Colors.redAccent.withOpacity(0.06) : AppTheme.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: danger ? Colors.redAccent.withOpacity(0.15) : AppTheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
