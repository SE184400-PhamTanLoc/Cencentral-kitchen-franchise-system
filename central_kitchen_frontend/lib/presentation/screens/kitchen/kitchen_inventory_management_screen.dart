import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/inventory_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/ingredient_model.dart';
import '../../../data/models/pending_order_model.dart';
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

  void updateState(VoidCallback fn) => setState(fn);

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
                  icon: Icons.chat_bubble_outline,
                  title: 'Nhắn tin nội bộ',
                  subtitle: 'Trao đổi với các cửa hàng',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).pushNamed('/chat');
                  },
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Bản đồ & Định vị',
                  subtitle: 'Giám sát xe giao hàng',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).pushNamed('/map');
                  },
                ),
                const SizedBox(height: 10),
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
        ingredients: provider.ingredients.where((item) => !item.isRawMaterial).toList(),
        selectedIngredientId: _selectedIngredientId,
        selectedIngredient: selectedIngredient,
        quantityController: _bomQuantityController,
        productionPlan: provider.productionPlan,
        pendingOrders: provider.pendingOrders,
        autoProductionPlan: provider.autoProductionPlan,
        isLoading: provider.isLoading,
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
        onClear: () {
          provider.clearProductionPlan();
          setState(() {
            _selectedIngredientId = null;
            _bomQuantityController.text = '1';
          });
        },
        onRefreshPendingOrders: () {
          final kitchenId = auth.kitchenId ?? 1;
          provider.fetchPendingOrders(kitchenId);
        },
        onCalculateProductBOM: (ingredientId, qty) async {
          final success = await provider.buildProductionPlan(ingredientId, qty);
          if (!context.mounted) return;
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.errorMessage ?? 'Không thể tính BOM.')),
            );
          }
        },
        onExecutePlan: (plan) {
          _showExecuteProductionDialog(context, plan);
        },
        onDispatchOrder: (orderId) async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Xác nhận xuất kho'),
              content: const Text('Bạn có chắc chắn muốn xuất kho cho đơn hàng này? Hệ thống sẽ trừ tồn kho thực tế.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xuất kho')),
              ],
            ),
          );
          if (confirm == true) {
            final success = await provider.dispatchOrder(orderId);
            if (!context.mounted) return;
            if (success) {
              await provider.loadKitchenInventory(kitchenId: auth.kitchenId);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xuất kho thành công.')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Xuất kho thất bại.')));
            }
          }
        },
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
        onTap: (index) {
          setState(() => _selectedSectionIndex = index);
          if (index == 3) {
            final kitchenId = context.read<AuthProvider>().kitchenId ?? 1;
            context.read<InventoryProvider>().fetchPendingOrders(kitchenId);
          }
        },
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

    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    final defaultBatchCode = 'BAT-IMPORT-${DateTime.now().toIso8601String().split("T").first.replaceAll("-", "")}-$timestamp';
    final ingredientIdController = TextEditingController(text: ingredients.first.ingredientId.toString());
    final batchCodeController = TextEditingController(text: defaultBatchCode);
    final quantityController = TextEditingController(text: '1');
    final remainingController = TextEditingController(text: '1');
    final manufactureDateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
    final defaultExpiryDate = DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T').first;
    final expiryDateController = TextEditingController(text: defaultExpiryDate);

    await showDialog(
      context: hostContext,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (dialogContext, setState) {
              Future<void> pickDate(TextEditingController controller) async {
                final initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
                final selected = await showDatePicker(
                  context: dialogContext,
                  initialDate: initialDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (selected != null && dialogContext.mounted) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nhập kho nhanh',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
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
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đủ nguyên liệu, mã lô, số lượng và hạn sử dụng.')),
                            );
                            return;
                          }

                          final success = await dialogContext.read<InventoryProvider>().createBatch({
                            'batchCode': batchCodeController.text.trim(),
                            'ingredientId': ingredientId,
                            'quantity': quantity,
                            'remainingQuantity': remaining,
                            'manufactureDate': manufactureDateController.text.isEmpty ? null : manufactureDateController.text,
                            'expiryDate': expiryDateController.text,
                            'kitchenId': kitchenId,
                          });

                          if (!dialogContext.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                            await hostContext.read<InventoryProvider>().loadKitchenInventory(kitchenId: kitchenId);
                            ScaffoldMessenger.of(hostContext).showSnackBar(
                              const SnackBar(content: Text('Nhập kho thành công!')),
                            );
                          } else {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(dialogContext.read<InventoryProvider>().errorMessage ?? 'Nhập kho thất bại')),
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
        ),
      );
    },
  );
  }

  Future<void> _showExecuteProductionDialog(
    BuildContext hostContext,
    ProductionPlanModel plan,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    final skuPart = (plan.outputSku ?? 'SKU').replaceAll(" ", "-").toUpperCase();
    final defaultBatchCode = 'BAT-$skuPart-${DateTime.now().toIso8601String().split("T").first.replaceAll("-", "")}-$timestamp';
    final batchCodeController = TextEditingController(text: defaultBatchCode);
    final defaultExpiry = DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T').first;
    final expiryDateController = TextEditingController(text: defaultExpiry);

    await showModalBottomSheet(
      context: hostContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(dialogContext).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thực thi sản xuất',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sản xuất ${plan.requestedQuantity} ${plan.outputIngredientName}',
                    style: const TextStyle(color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: batchCodeController,
                    decoration: const InputDecoration(labelText: 'Mã lô thành phẩm', prefixIcon: Icon(Icons.qr_code)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: expiryDateController,
                    decoration: const InputDecoration(labelText: 'Hạn sử dụng (YYYY-MM-DD)', prefixIcon: Icon(Icons.event)),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (batchCodeController.text.trim().isEmpty || expiryDateController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('Vui lòng nhập đủ mã lô và hạn sử dụng.')),
                          );
                          return;
                        }

                        final auth = hostContext.read<AuthProvider>();
                        final kitchenId = auth.kitchenId ?? 1;

                        final success = await dialogContext.read<InventoryProvider>().executeProduction({
                          'outputIngredientId': plan.outputIngredientId,
                          'requestedQuantity': plan.requestedQuantity,
                          'batchCode': batchCodeController.text.trim(),
                          'expiryDate': expiryDateController.text.trim(),
                          'kitchenId': kitchenId,
                        });

                        if (!dialogContext.mounted) return;
                        if (success) {
                          Navigator.pop(dialogContext);
                          hostContext.read<InventoryProvider>().clearProductionPlan();
                          hostContext.read<InventoryProvider>().clearAutoProductionPlan();
                          updateState(() {
                            _selectedIngredientId = null;
                            _bomQuantityController.text = '1';
                          });
                          await hostContext.read<InventoryProvider>().loadKitchenInventory(kitchenId: kitchenId);
                          ScaffoldMessenger.of(hostContext).showSnackBar(
                            const SnackBar(content: Text('Thực thi sản xuất thành công!')),
                          );
                        } else {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(dialogContext.read<InventoryProvider>().errorMessage ?? 'Thực thi sản xuất thất bại')),
                          );
                        }
                      },
                      icon: const Icon(Icons.precision_manufacturing),
                      label: const Text('Xác nhận sản xuất'),
                    ),
                  ),
                ],
              ),
            ),
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
  final List<PendingOrderModel> pendingOrders;
  final ProductionPlanModel? autoProductionPlan;
  final bool isLoading;
  final ValueChanged<int?> onIngredientChanged;
  final VoidCallback onCalculate;
  final VoidCallback onClear;
  final VoidCallback onRefreshPendingOrders;
  final Function(int, double) onCalculateProductBOM;
  final ValueChanged<ProductionPlanModel> onExecutePlan;
  final ValueChanged<int> onDispatchOrder;

  const _BomTab({
    required this.ingredients,
    required this.selectedIngredientId,
    required this.selectedIngredient,
    required this.quantityController,
    required this.productionPlan,
    required this.pendingOrders,
    required this.autoProductionPlan,
    required this.isLoading,
    required this.onIngredientChanged,
    required this.onCalculate,
    required this.onClear,
    required this.onRefreshPendingOrders,
    required this.onCalculateProductBOM,
    required this.onExecutePlan,
    required this.onDispatchOrder,
  });

  @override
  Widget build(BuildContext context) {
    final aggregatedProducts = <int, _RequiredProduct>{};
    for (final order in pendingOrders) {
      for (final detail in order.orderDetails) {
        if (aggregatedProducts.containsKey(detail.ingredientId)) {
          aggregatedProducts[detail.ingredientId]!.quantity += detail.quantityOrdered;
        } else {
          aggregatedProducts[detail.ingredientId] = _RequiredProduct(
            ingredientId: detail.ingredientId,
            name: detail.ingredientName,
            unit: detail.unit,
            quantity: detail.quantityOrdered,
          );
        }
      }
    }
    final requiredProductsList = <_RequiredProduct>[];
    for (final product in aggregatedProducts.values) {
      IngredientModel? matching;
      for (final i in ingredients) {
        if (i.ingredientId == product.ingredientId) {
          matching = i;
          break;
        }
      }
      if (matching != null && matching.availableQuantity < product.quantity) {
        requiredProductsList.add(product);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ====== CARD 1: ĐƠN ĐẶT HÀNG CHỜ ======
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_outlined, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Đơn đặt hàng chờ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                  ),
                  IconButton(
                    onPressed: onRefreshPendingOrders,
                    icon: const Icon(Icons.refresh_outlined, size: 20),
                    tooltip: 'Tải lại đơn hàng chờ',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: pendingOrders.isEmpty ? AppTheme.background : Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: pendingOrders.isEmpty ? AppTheme.outlineVariant : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      pendingOrders.isEmpty ? Icons.check_circle_outline : Icons.pending_actions_outlined,
                      color: pendingOrders.isEmpty ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pendingOrders.isEmpty
                            ? 'Không có đơn hàng chờ xử lý.'
                            : 'Có ${pendingOrders.length} đơn hàng chờ từ chi nhánh.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: pendingOrders.isEmpty ? Colors.green : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (pendingOrders.isNotEmpty) ...[
                const SizedBox(height: 14),
                ...pendingOrders.map(
                  (order) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 20, color: AppTheme.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.storeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(
                                '${order.orderCode} • ${order.orderDetails.length} mặt hàng',
                                style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.orderStatus,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orange.shade800),
                          ),
                        ),
                        if (order.orderStatus.toUpperCase() == 'APPROVED') ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.local_shipping_outlined, color: AppTheme.primary),
                            tooltip: 'Xuất kho giao hàng',
                            onPressed: () => onDispatchOrder(order.orderId),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ====== CARD 2: SẢN PHẨM CẦN SẢN XUẤT ======
        if (pendingOrders.isNotEmpty && requiredProductsList.isNotEmpty) ...[
          const SizedBox(height: 20),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.precision_manufacturing_outlined, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sản phẩm cần chuẩn bị từ các đơn',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hệ thống tự động quy đổi nhu cầu sản phẩm từ các đơn hàng chờ. Nhấn "Tính BOM" để kiểm tra tính khả dụng của nguyên liệu.',
                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                ),
                const SizedBox(height: 14),
                ...requiredProductsList.map(
                  (product) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inventory_2_outlined, size: 18, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                'Tổng nhu cầu: ${product.quantity.toStringAsFixed(1)} ${product.unit}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : () => onCalculateProductBOM(product.ingredientId, product.quantity),
                          icon: const Icon(Icons.calculate_outlined, size: 16),
                          label: const Text('Tính BOM', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange.withOpacity(0.12),
                            foregroundColor: Colors.deepOrange,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // ====== SECTION 2: MANUAL BOM ======
        const SizedBox(height: 24),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calculate_outlined, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tính BOM thủ công',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
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
              padding: EdgeInsets.only(top: 40),
              child: Text('Chưa có kết quả BOM thủ công.'),
            ),
          )
        else
          _BomResultCard(
            plan: productionPlan!,
            onExecute: () => onExecutePlan(productionPlan!),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _BomResultCard extends StatelessWidget {
  final ProductionPlanModel plan;
  final VoidCallback? onExecute;

  const _BomResultCard({required this.plan, this.onExecute});

  @override
  Widget build(BuildContext context) {
    final shortMaterials = plan.materials.where((m) => m.shortageQuantity > 0).toList();

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
          if (shortMaterials.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'Tất cả nguyên liệu đều đủ đáp ứng. Có thể thực thi sản xuất.',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          else
            ...shortMaterials.map(
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
                        const Text(
                          'Thiếu',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Cần: ${item.requiredQuantity.toStringAsFixed(2)} ${item.unit}'),
                    Text('Khả dụng: ${item.availableQuantity.toStringAsFixed(2)} ${item.unit}'),
                    Text('Thiếu: ${item.shortageQuantity.toStringAsFixed(2)} ${item.unit}', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
          if (onExecute != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: plan.materials.any((m) => m.shortageQuantity > 0) ? null : onExecute,
                icon: const Icon(Icons.precision_manufacturing),
                label: const Text('Thực thi sản xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
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

class _RequiredProduct {
  final int ingredientId;
  final String name;
  final String unit;
  double quantity;

  _RequiredProduct({
    required this.ingredientId,
    required this.name,
    required this.unit,
    required this.quantity,
  });
}
