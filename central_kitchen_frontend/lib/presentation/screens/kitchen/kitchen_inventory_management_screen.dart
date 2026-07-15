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
import '../../widgets/unified_order_card.dart';
import '../../widgets/shared_order_details_modal.dart';
import '../../widgets/ingredient_image_helper.dart';

class KitchenInventoryManagementScreen extends StatefulWidget {
  const KitchenInventoryManagementScreen({super.key});

  @override
  State<KitchenInventoryManagementScreen> createState() =>
      _KitchenInventoryManagementScreenState();
}

class _KitchenInventoryManagementScreenState
    extends State<KitchenInventoryManagementScreen> {
  final _bomQuantityController = TextEditingController(text: '1');
  int? _selectedIngredientId;
  int _selectedSectionIndex = 0;

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00236F), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  void updateState(VoidCallback fn) => setState(fn);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<InventoryProvider>().loadKitchenInventory(
        kitchenId: auth.kitchenId,
      );
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
                    backgroundColor: AppTheme.primaryContainer,
                    child: Text(
                      _avatarInitial(auth.currentUser?.fullName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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
    final selectedIngredient = _findIngredient(
      provider.ingredients,
      _selectedIngredientId,
    );
    final pages = <Widget>[
      _OverviewTab(
        ingredientCount: provider.ingredients.length,
        batchCount: provider.batches.length,
        lowStockCount: provider.ingredients
            .where((item) => item.availableQuantity <= item.minStockLevel)
            .length,
        expiredBatchCount: provider.batches
            .where((batch) => batch.isExpired)
            .length,
        onImportStock: () =>
            _openQuickBatchSheet(context, auth.kitchenId, provider.ingredients),
        onOpenBom: () => setState(() => _selectedSectionIndex = 3),
      ),
      _IngredientsTab(
        ingredients: ingredients,
        searchQuery: provider.searchQuery,
        rawFilter: provider.rawFilter,
        onSearchChanged: (value) {
          provider.setSearchQuery(value);
        },
        onFilterChanged: (value) {
          provider.setRawFilter(value);
        },
        onTapIngredient: (ingredient) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  InventoryProductDetailScreen(ingredient: ingredient),
            ),
          );
        },
      ),
      _BatchesTab(
        batches: batches,
        searchQuery: provider.batchSearchQuery,
        statusFilter: provider.batchStatusFilter,
        ingredientLookup: {
          for (final ingredient in provider.ingredients)
            ingredient.ingredientId: ingredient,
        },
        onSearchChanged: provider.setBatchSearchQuery,
        onFilterChanged: provider.setBatchStatusFilter,
        onTapBatch: (batch) {
          final ingredient = provider.ingredients.firstWhere(
            (item) => item.ingredientId == batch.ingredientId,
            orElse: () => provider.ingredients.isNotEmpty
                ? provider.ingredients.first
                : _fallbackIngredient(batch),
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  InventoryProductDetailScreen(ingredient: ingredient),
            ),
          );
        },
      ),
      _BomTab(
        allIngredients: provider.ingredients,
        ingredients: provider.ingredients
            .where((item) => !item.isRawMaterial)
            .toList(),
        selectedIngredientId: _selectedIngredientId,
        selectedIngredient: selectedIngredient,
        quantityController: _bomQuantityController,
        productionPlan: provider.productionPlan,
        pendingOrders: provider.pendingOrders,
        autoProductionPlan: provider.autoProductionPlan,
        isLoading: provider.isLoading,
        onIngredientChanged: (value) =>
            setState(() => _selectedIngredientId = value),
        onCalculate: () async {
          final ingredientId = _selectedIngredientId;
          final kitchenId = auth.kitchenId ?? 1;
          if (ingredientId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng chọn nguyên liệu đầu ra.'),
              ),
            );
            return;
          }
          final qty = double.tryParse(_bomQuantityController.text) ?? 0;
          if (qty <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Số lượng phải lớn hơn 0.')),
            );
            return;
          }
          final success = await provider.buildProductionPlan(
            ingredientId,
            qty,
            kitchenId: kitchenId,
          );
          if (!context.mounted) return;
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage ?? 'Không thể tính BOM.'),
              ),
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
          final success = await provider.buildProductionPlan(
            ingredientId,
            qty,
            kitchenId: auth.kitchenId ?? 1,
          );
          if (!context.mounted) return;
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage ?? 'Không thể tính BOM.'),
              ),
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
              content: const Text(
                'Bạn có chắc chắn muốn xuất kho cho đơn hàng này? Hệ thống sẽ trừ tồn kho thực tế.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Xuất kho'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            final success = await provider.dispatchOrder(orderId);
            if (!context.mounted) return;
            if (success) {
              await provider.loadKitchenInventory(kitchenId: auth.kitchenId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Xuất kho thành công.')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.errorMessage ?? 'Xuất kho thất bại.'),
                ),
              );
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
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 78,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, ${auth.currentUser?.fullName ?? 'Nhân viên bếp'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
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
            onPressed: () => context
                .read<InventoryProvider>()
                .loadKitchenInventory(kitchenId: auth.kitchenId),
            icon: const Icon(Icons.refresh_outlined),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _openUserMenu(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryContainer,
                child: Text(
                  _avatarInitial(auth.currentUser?.fullName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
      ),
      body:
          provider.isLoading &&
              provider.ingredients.isEmpty &&
              provider.batches.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedSectionIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.outlineVariant, width: 1),
          ),
        ),
        child: BottomNavigationBar(
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
          unselectedItemColor: const Color(0xFF64748B),
          elevation: 0,
          backgroundColor: Colors.white,
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
              label: 'Lô hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              label: 'BOM',
            ),
          ],
        ),
      ),
    );
  }

  IngredientModel? _findIngredient(
    List<IngredientModel> ingredients,
    int? ingredientId,
  ) {
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00236F), Color(0xFF003FB4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00236F).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.kitchen_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng quan kho bếp',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Hệ thống quản lý Bếp trung tâm',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Quản lý nguyên vật liệu thô, theo dõi chi tiết các lô hàng nhập xuất và tính toán định mức sản xuất (BOM) nhanh chóng.',
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onImportStock,
                        icon: const Icon(
                          Icons.playlist_add_circle_outlined,
                          color: Color(0xFF00236F),
                        ),
                        label: const Text(
                          'Nhập kho nhanh',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00236F),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpenBom,
                        icon: const Icon(
                          Icons.calculate_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Tính BOM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
              Expanded(
                child: _MetricCard(
                  title: 'Tồn thấp',
                  value: lowStockCount.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Batch hết hạn',
                  value: expiredBatchCount.toString(),
                  icon: Icons.event_busy_outlined,
                  color: Colors.red,
                ),
              ),
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
    final rawIngredients = ingredients.where((i) => i.isRawMaterial).toList();
    if (rawIngredients.isEmpty) {
      ScaffoldMessenger.of(hostContext).showSnackBar(
        const SnackBar(
          content: Text('Không có nguyên liệu thô nào để nhập kho.'),
        ),
      );
      return;
    }

    final timestamp =
        DateTime.now().millisecondsSinceEpoch %
        1000000; // Lấy 6 số cuối để giảm thiểu trùng lặp
    final defaultBatchCode =
        'BAT-IMPORT-${DateTime.now().toIso8601String().split("T").first.replaceAll("-", "")}-$timestamp';
    final ingredientIdController = TextEditingController(
      text: rawIngredients.first.ingredientId.toString(),
    );
    final batchCodeController = TextEditingController(text: defaultBatchCode);
    final quantityController = TextEditingController(text: '1');
    final remainingController = TextEditingController();
    final manufactureDateController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first,
    );
    final defaultExpiryDate = DateTime.now()
        .add(const Duration(days: 30))
        .toIso8601String()
        .split('T')
        .first;
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (dialogContext, setState) {
                Future<void> pickDate(TextEditingController controller) async {
                  final initialDate =
                      DateTime.tryParse(controller.text) ?? DateTime.now();
                  final selected = await showDatePicker(
                    context: dialogContext,
                    initialDate: initialDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 3650),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (selected != null && dialogContext.mounted) {
                    controller.text = selected
                        .toIso8601String()
                        .split('T')
                        .first;
                    setState(() {});
                  }
                }

                final selectedIngredientId = int.tryParse(
                  ingredientIdController.text,
                );
                final selectedIngredient = rawIngredients.firstWhere(
                  (item) => item.ingredientId == selectedIngredientId,
                  orElse: () => rawIngredients.first,
                );

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00236F).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Color(0xFF00236F),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nhập kho nhanh',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF00236F),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Ghi nhận lô nguyên liệu thô mới nhập kho',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(dialogContext),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Dropdown Nguyên liệu
                      DropdownButtonFormField<int>(
                        value: selectedIngredient.ingredientId,
                        isExpanded: true,
                        decoration: _buildInputDecoration(
                          'Nguyên liệu thô nhập kho',
                          Icons.eco_outlined,
                        ),
                        items: rawIngredients
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
                      const SizedBox(height: 14),

                      // Mã lô
                      TextFormField(
                        controller: batchCodeController,
                        decoration: _buildInputDecoration(
                          'Mã lô hàng',
                          Icons.qr_code_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Số lượng
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: quantityController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _buildInputDecoration(
                                'Tổng nhập',
                                Icons.scale_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: remainingController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _buildInputDecoration(
                                'Tồn thực tế',
                                Icons.inventory_2_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Hạn ngày
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: manufactureDateController,
                              readOnly: true,
                              onTap: () => pickDate(manufactureDateController),
                              decoration: _buildInputDecoration(
                                'Ngày sản xuất',
                                Icons.date_range_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: expiryDateController,
                              readOnly: true,
                              onTap: () => pickDate(expiryDateController),
                              decoration: _buildInputDecoration(
                                'Hạn sử dụng',
                                Icons.event_available_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final ingredientId = int.tryParse(
                                  ingredientIdController.text,
                                );
                                final quantity =
                                    double.tryParse(quantityController.text) ??
                                    0;
                                final parsedRemaining = double.tryParse(
                                  remainingController.text,
                                );
                                final remaining =
                                    (parsedRemaining == null ||
                                        parsedRemaining <= 0)
                                    ? quantity
                                    : parsedRemaining;

                                if (ingredientId == null ||
                                    batchCodeController.text.trim().isEmpty ||
                                    quantity <= 0 ||
                                    expiryDateController.text.isEmpty) {
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vui lòng nhập đủ nguyên liệu, mã lô, số lượng và hạn sử dụng.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (remaining < 0 || remaining > quantity) {
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tồn thực tế phải từ 0 đến nhỏ hơn hoặc bằng tổng nhập.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final success = await dialogContext
                                    .read<InventoryProvider>()
                                    .createBatch({
                                      'batchCode': batchCodeController.text
                                          .trim(),
                                      'ingredientId': ingredientId,
                                      'quantity': quantity,
                                      'remainingQuantity': remaining,
                                      'manufactureDate':
                                          manufactureDateController.text.isEmpty
                                          ? null
                                          : manufactureDateController.text,
                                      'expiryDate': expiryDateController.text,
                                      'kitchenId': kitchenId,
                                    });

                                if (!dialogContext.mounted) return;
                                if (success) {
                                  Navigator.pop(dialogContext);
                                  await hostContext
                                      .read<InventoryProvider>()
                                      .loadKitchenInventory(
                                        kitchenId: kitchenId,
                                      );
                                  ScaffoldMessenger.of(
                                    hostContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nhập kho thành công!'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        dialogContext
                                                .read<InventoryProvider>()
                                                .errorMessage ??
                                            'Nhập kho thất bại',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00236F),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Lưu nhập kho',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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
    final timestamp =
        DateTime.now().millisecondsSinceEpoch %
        1000000; // Lấy 6 số cuối để giảm thiểu trùng lặp
    final skuPart = (plan.outputSku ?? 'SKU')
        .replaceAll(" ", "-")
        .toUpperCase();
    final defaultBatchCode =
        'BAT-$skuPart-${DateTime.now().toIso8601String().split("T").first.replaceAll("-", "")}-$timestamp';
    final batchCodeController = TextEditingController(text: defaultBatchCode);
    final defaultExpiry = DateTime.now()
        .add(const Duration(days: 7))
        .toIso8601String()
        .split('T')
        .first;
    final expiryDateController = TextEditingController(text: defaultExpiry);
    var isSubmitting = false;
    String? inlineError;

    await showModalBottomSheet(
      context: hostContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              if (isSubmitting) return;

              if (batchCodeController.text.trim().isEmpty ||
                  expiryDateController.text.trim().isEmpty) {
                setModalState(() {
                  inlineError = 'Vui lòng nhập đủ mã lô và hạn sử dụng.';
                });
                return;
              }

              setModalState(() {
                isSubmitting = true;
                inlineError = null;
              });

              final auth = hostContext.read<AuthProvider>();
              final kitchenId = auth.kitchenId ?? 1;

              final success = await dialogContext
                  .read<InventoryProvider>()
                  .executeProduction({
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
                await hostContext
                    .read<InventoryProvider>()
                    .loadKitchenInventory(kitchenId: kitchenId);
                ScaffoldMessenger.of(hostContext).showSnackBar(
                  const SnackBar(
                    content: Text('Thực thi sản xuất thành công!'),
                  ),
                );
              } else {
                setModalState(() {
                  isSubmitting = false;
                  inlineError =
                      dialogContext.read<InventoryProvider>().errorMessage ??
                      'Thực thi sản xuất thất bại.';
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
              ),
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
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogContext),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sản xuất ${plan.requestedQuantity} ${plan.outputIngredientName}',
                        style: const TextStyle(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      if (isSubmitting) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Hệ thống đang thực thi sản xuất. Vui lòng chờ để tránh tạo lô trùng.',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (inlineError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.error_outline_rounded,
                                  color: AppTheme.error,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  inlineError!,
                                  style: const TextStyle(
                                    color: AppTheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: batchCodeController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Mã lô thành phẩm',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: expiryDateController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Hạn sử dụng (YYYY-MM-DD)',
                          prefixIcon: Icon(Icons.event),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: isSubmitting ? null : submit,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.precision_manufacturing),
                          label: Text(
                            isSubmitting
                                ? 'Đang thực thi sản xuất...'
                                : 'Xác nhận sản xuất',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
    Color statusBgColor = const Color(0xFFF1F5F9);
    Color statusTextColor = const Color(0xFF64748B);

    final lowerTitle = title.toLowerCase();
    final isLowStock =
        lowerTitle.contains('thấp') || lowerTitle.contains('tồn');
    final isExpired =
        lowerTitle.contains('hạn') || lowerTitle.contains('expired');
    final count = int.tryParse(value) ?? 0;

    if (isLowStock) {
      if (count > 0) {
        statusBgColor = const Color(0xFFFFFBEB); // light warning (#F59E0B)
        statusTextColor = const Color(0xFFF59E0B);
      } else {
        statusBgColor = const Color(0xFFECFDF5); // light success (#10B981)
        statusTextColor = const Color(0xFF10B981);
      }
    } else if (isExpired) {
      if (count > 0) {
        statusBgColor = const Color(0xFFFEF2F2); // light error (#EF4444)
        statusTextColor = const Color(0xFFEF4444);
      } else {
        statusBgColor = const Color(0xFFECFDF5); // light success (#10B981)
        statusTextColor = const Color(0xFF10B981);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusTextColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: Color(0xFF00236F),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00236F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            final parts = item.split('. ');
            final index = parts.isNotEmpty ? parts[0] : '';
            final text = parts.length > 1 ? parts[1] : item;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        index,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
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
    final kitchenId = context.read<AuthProvider>().kitchenId;
    return RefreshIndicator(
      onRefresh: () => context.read<InventoryProvider>().fetchIngredients(
        kitchenId: kitchenId,
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SearchField(value: searchQuery, onChanged: onSearchChanged),
          const SizedBox(height: 12),
          _FilterChips(selected: rawFilter, onChanged: onFilterChanged),
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
                  showCheckmark: false,
                  label: Text(item.label),
                  selected: item.value == selected,
                  onSelected: (_) => onChanged(item.value),
                  selectedColor: AppTheme.primary.withOpacity(0.12),
                  labelStyle: TextStyle(
                    color: item.value == selected
                        ? AppTheme.primary
                        : AppTheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: item.value == selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: item.value == selected
                        ? AppTheme.primary
                        : const Color(0xFFE2E8F0),
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            (() {
              final imagePath = getIngredientImage(
                ingredient.sku,
                ingredient.name,
              );
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.primary.withOpacity(0.08),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(imagePath, fit: BoxFit.cover),
                      )
                    : Icon(
                        ingredient.isRawMaterial
                            ? Icons.grain_outlined
                            : Icons.bakery_dining_outlined,
                        color: AppTheme.primary,
                      ),
              );
            })(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ingredient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      if (lowStock)
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.warning,
                          size: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${ingredient.sku}',
                    style: const TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Tag(
                        label: ingredient.isRawMaterial
                            ? 'Nguyên liệu thô'
                            : 'Bán thành phẩm',
                      ),
                      _Tag(
                        label:
                            '${ingredient.availableQuantity.toStringAsFixed(1)} ${ingredient.unit}',
                      ),
                      _Tag(label: '${ingredient.batchCount} lô'),
                      if (ingredient.latestExpiryDate != null)
                        _Tag(
                          label:
                              'HSD: ${ingredient.latestExpiryDate!.day.toString().padLeft(2, '0')}/${ingredient.latestExpiryDate!.month.toString().padLeft(2, '0')}/${ingredient.latestExpiryDate!.year}',
                        ),
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
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
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
        _SearchField(value: searchQuery, onChanged: onSearchChanged),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((item) {
              final selected = item.$1 == statusFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  showCheckmark: false,
                  label: Text(item.$2),
                  selected: selected,
                  onSelected: (_) => onFilterChanged(item.$1),
                  selectedColor: AppTheme.primary.withOpacity(0.12),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppTheme.primary
                        : AppTheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppTheme.primary
                        : const Color(0xFFE2E8F0),
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
          ...batches.map((batch) {
            final ingredient = ingredientLookup[batch.ingredientId];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BatchCard(
                batch: batch,
                onTap: () => onTapBatch(batch),
                subtitle: ingredient?.name ?? batch.ingredientName,
              ),
            );
          }),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: expired ? const Color(0xFFFEF2F2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: expired ? Colors.red.shade100 : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Image Preview
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: expired
                      ? Colors.red.shade100
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: buildIngredientPreview(
                  null,
                  subtitle,
                  size: 52,
                  borderRadius: 10,
                  fallback: Icon(
                    Icons.inventory_2_outlined,
                    color: expired ? Colors.red : const Color(0xFF00236F),
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle: Batch details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch.batchCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.history_toggle_off_outlined,
                        size: 12,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'HSD: ${batch.expiryDate.day.toString().padLeft(2, '0')}/${batch.expiryDate.month.toString().padLeft(2, '0')}/${batch.expiryDate.year}',
                        style: TextStyle(
                          fontSize: 11,
                          color: expired ? Colors.red : const Color(0xFF64748B),
                          fontWeight: expired
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right: Expiry badge and stock numbers
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: expired
                        ? Colors.red.withOpacity(0.08)
                        : Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    expired ? 'Hết hạn' : 'Còn hạn',
                    style: TextStyle(
                      color: expired
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${batch.remainingQuantity.toStringAsFixed(1)} / ${batch.quantity.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: expired
                        ? Colors.red.shade700
                        : const Color(0xFF0F172A),
                  ),
                ),
                const Text(
                  'Tồn thực tế',
                  style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BomTab extends StatelessWidget {
  final List<IngredientModel> allIngredients;
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
    required this.allIngredients,
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00236F), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aggregatedProducts = <int, _RequiredProduct>{};
    for (final order in pendingOrders) {
      for (final detail in order.orderDetails) {
        if (aggregatedProducts.containsKey(detail.ingredientId)) {
          aggregatedProducts[detail.ingredientId]!.quantity +=
              detail.quantityOrdered;
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
      for (final i in allIngredients) {
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
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Đơn đặt hàng chờ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
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
                  color: pendingOrders.isEmpty
                      ? AppTheme.background
                      : Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: pendingOrders.isEmpty
                        ? AppTheme.outlineVariant
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      pendingOrders.isEmpty
                          ? Icons.check_circle_outline
                          : Icons.pending_actions_outlined,
                      color: pendingOrders.isEmpty
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pendingOrders.isEmpty
                            ? 'Không có đơn hàng chờ xử lý.'
                            : 'Có ${pendingOrders.length} đơn hàng chờ từ chi nhánh.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: pendingOrders.isEmpty
                              ? Colors.green
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (pendingOrders.isNotEmpty) ...[
                const SizedBox(height: 14),
                ...pendingOrders.map(
                  (order) => UnifiedOrderCard(
                    orderId: order.orderId,
                    orderCode: order.orderCode,
                    storeName: order.storeName,
                    orderStatus: order.orderStatus,
                    createdAt: order.createdAt,
                    totalAmount: order.totalAmount,
                    itemCount: order.orderDetails.length,
                    onTap: () {
                      SharedOrderDetailsModal.show(
                        context,
                        orderId: order.orderId,
                        orderCode: order.orderCode,
                        orderStatus: order.orderStatus,
                        onRefresh: onRefreshPendingOrders,
                      );
                    },
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
                      child: const Icon(
                        Icons.precision_manufacturing_outlined,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sản phẩm cần chuẩn bị từ các đơn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hệ thống tự động quy đổi nhu cầu sản phẩm từ các đơn hàng chờ. Nhấn "Tính BOM" để kiểm tra tính khả dụng của nguyên liệu.',
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                ...requiredProductsList.map((product) {
                  IngredientModel? matching;
                  for (final i in allIngredients) {
                    if (i.ingredientId == product.ingredientId) {
                      matching = i;
                      break;
                    }
                  }
                  final double availableQty =
                      matching?.availableQuantity ?? 0.0;
                  final bool isShort = availableQty < product.quantity;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tổng nhu cầu: ${product.quantity.toStringAsFixed(1)} ${product.unit}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isShort) ...[
                          ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => onCalculateProductBOM(
                                    product.ingredientId,
                                    product.quantity,
                                  ),
                            icon: const Icon(
                              Icons.calculate_outlined,
                              size: 16,
                            ),
                            label: const Text(
                              'Tính BOM',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange.withOpacity(
                                0.12,
                              ),
                              foregroundColor: Colors.deepOrange,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size.zero,
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Đủ hàng',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
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
                    child: const Icon(
                      Icons.calculate_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tính BOM thủ công',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
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
                decoration: _buildInputDecoration(
                  'Sản phẩm cần sản xuất',
                  Icons.flatware_outlined,
                ),
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
              const SizedBox(height: 14),
              TextFormField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _buildInputDecoration(
                  'Số lượng thành phẩm',
                  Icons.calculate_outlined,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCalculate,
                      icon: const Icon(
                        Icons.auto_awesome_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Tính BOM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00236F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: onClear,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Xóa',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    final shortMaterials = plan.materials
        .where((m) => m.shortageQuantity > 0)
        .toList();

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
          Text(
            plan.outputIngredientName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Số lượng yêu cầu: ${plan.requestedQuantity}',
            style: const TextStyle(color: AppTheme.onSurfaceVariant),
          ),
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
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
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
                          child: Text(
                            item.ingredientName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
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
                    Text(
                      'Cần: ${item.requiredQuantity.toStringAsFixed(2)} ${item.unit}',
                    ),
                    Text(
                      'Khả dụng: ${item.availableQuantity.toStringAsFixed(2)} ${item.unit}',
                    ),
                    Text(
                      'Thiếu: ${item.shortageQuantity.toStringAsFixed(2)} ${item.unit}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          if (onExecute != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: plan.materials.any((m) => m.shortageQuantity > 0)
                    ? null
                    : onExecute,
                icon: const Icon(Icons.precision_manufacturing),
                label: const Text('Thực thi sản xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
          color: danger
              ? Colors.redAccent.withOpacity(0.06)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: danger
                ? Colors.redAccent.withOpacity(0.15)
                : AppTheme.outlineVariant,
          ),
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
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w700, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
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
