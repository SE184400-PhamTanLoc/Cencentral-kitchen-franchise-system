import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/cart_order_provider.dart';
import '../../../business/providers/inventory_provider.dart';
import '../../../business/providers/notification_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/order_model.dart';
import 'cart_screen.dart';
import 'notification_screen.dart';

class FranchiseDashboardScreen extends StatefulWidget {
  const FranchiseDashboardScreen({super.key});

  @override
  State<FranchiseDashboardScreen> createState() => _FranchiseDashboardScreenState();
}

class _FranchiseDashboardScreenState extends State<FranchiseDashboardScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const _OrderTab(),
      const _HistoryTab(),
      const _InventoryTab(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLoad());
  }

  Future<void> _initLoad() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartOrderProvider>();
    final inventory = context.read<InventoryProvider>();
    final notif = context.read<NotificationProvider>();

    final storeId = auth.storeId;
    if (storeId != null) {
      await cart.loadOrdersAsync(storeId);
      await cart.loadStoreInventoryAsync(storeId);
      await notif.loadNotificationsAsync();
      await notif.loadCreditInfoAsync(storeId);
    }
    await inventory.fetchIngredients();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final cart = context.watch<CartOrderProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: AppTheme.background.withOpacity(0.7),
              elevation: 0,
              iconTheme: const IconThemeData(color: AppTheme.primary),
              title: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        auth.currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'F',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.fullName ?? 'Nhân viên Cửa hàng',
                        style: const TextStyle(
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        auth.currentUser?.storeName ?? 'Cửa hàng nhượng quyền',
                        style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.local_shipping_rounded, color: AppTheme.primary),
                  tooltip: 'Định vị đơn hàng',
                  onPressed: () => Navigator.pushNamed(context, '/map'),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primary),
                  tooltip: 'Nhắn tin nội bộ',
                  onPressed: () => Navigator.pushNamed(context, '/chat'),
                ),
                Consumer<NotificationProvider>(
                  builder: (context, notif, child) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_rounded, color: AppTheme.primary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificationScreen()),
                            );
                          },
                        ),
                        if (notif.hasUnread)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF3B30),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${notif.unreadCount}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_rounded, color: AppTheme.primary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                  tooltip: 'Đăng xuất',
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background neon bubbles
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primary.withOpacity(0.25), AppTheme.secondary.withOpacity(0.01)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.secondary.withOpacity(0.2), AppTheme.primary.withOpacity(0.01)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            right: 80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFFC084FC).withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: AppTheme.background.withOpacity(0.7),
              ),
            ),
          ),
          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: _tabs,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            backgroundColor: AppTheme.background.withOpacity(0.8),
            indicatorColor: AppTheme.primary.withOpacity(0.12),
            height: 64,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.add_shopping_cart_outlined, color: AppTheme.primary.withOpacity(0.6)),
                selectedIcon: const Icon(Icons.add_shopping_cart, color: AppTheme.primary),
                label: 'Đặt hàng',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined, color: AppTheme.primary.withOpacity(0.6)),
                selectedIcon: const Icon(Icons.receipt_long, color: AppTheme.primary),
                label: 'Lịch sử',
              ),
              NavigationDestination(
                icon: Icon(Icons.warehouse_outlined, color: AppTheme.primary.withOpacity(0.6)),
                selectedIcon: const Icon(Icons.warehouse, color: AppTheme.primary),
                label: 'Kho & Tiêu thụ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 0: Đặt hàng — Danh mục nguyên liệu
// ─────────────────────────────────────────────────────────────────────────────

class _OrderTab extends StatefulWidget {
  const _OrderTab();

  @override
  State<_OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends State<_OrderTab> {
  String _selectedCategory = 'Tất cả';

  final List<Map<String, String>> _categories = [
    {'name': 'Tất cả', 'icon': '🔥'},
    {'name': 'Rau củ', 'icon': '🥬'},
    {'name': 'Thịt cá', 'icon': '🥩'},
    {'name': 'Gia vị', 'icon': '🌶'},
    {'name': 'Đóng gói', 'icon': '📦'},
  ];

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final cart = context.watch<CartOrderProvider>();
    final notif = context.watch<NotificationProvider>();

    if (inventory.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    // Filter items locally by category
    final items = inventory.ingredients.where((item) {
      if (_selectedCategory == 'Tất cả') return true;
      if (_selectedCategory == 'Rau củ') {
        return item.name.toLowerCase().contains('rau') ||
            item.name.toLowerCase().contains('cải') ||
            item.name.toLowerCase().contains('hành');
      }
      if (_selectedCategory == 'Thịt cá') {
        return item.name.toLowerCase().contains('thịt') ||
            item.name.toLowerCase().contains('bò') ||
            item.name.toLowerCase().contains('heo') ||
            item.name.toLowerCase().contains('gà');
      }
      if (_selectedCategory == 'Gia vị') {
        return item.name.toLowerCase().contains('sốt') ||
            item.name.toLowerCase().contains('tương') ||
            item.name.toLowerCase().contains('muối') ||
            item.name.toLowerCase().contains('bột');
      }
      return true; // default
    }).toList();

    final lowStockCount = cart.storeInventory.where((i) => i.stockQuantity < 5).length;

    return Column(
      children: [
        // 1. Quick Stats Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // Remaining debt card
              Expanded(
                child: _buildMetricCard(
                  title: 'Hạn mức khả dụng',
                  value: notif.creditInfo != null
                      ? _fmt(notif.creditInfo!.creditLimit - notif.creditInfo!.currentDebt)
                      : 'Đang tải...',
                  color: AppTheme.primary,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
              const SizedBox(width: 8),
              // Cart items count
              Expanded(
                child: _buildMetricCard(
                  title: 'Trong giỏ hàng',
                  value: '${cart.itemCount} loại (${cart.totalUnits} SP)',
                  color: AppTheme.secondary,
                  icon: Icons.shopping_basket_rounded,
                ),
              ),
              const SizedBox(width: 8),
              // Low stock alert card
              Expanded(
                child: _buildMetricCard(
                  title: 'Cần nhập gấp',
                  value: '$lowStockCount nguyên liệu',
                  color: lowStockCount > 0 ? AppTheme.error : const Color(0xFF16A34A),
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
        ),

        // 2. Credit Info Banner
        if (notif.creditInfo != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notif.creditInfo!.canPlaceOrder
                        ? AppTheme.primary.withOpacity(0.06)
                        : AppTheme.error.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notif.creditInfo!.canPlaceOrder
                          ? AppTheme.primary.withOpacity(0.3)
                          : AppTheme.error.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (notif.creditInfo!.canPlaceOrder ? AppTheme.primary : AppTheme.error).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          notif.creditInfo!.canPlaceOrder ? Icons.security_rounded : Icons.lock_rounded,
                          color: notif.creditInfo!.canPlaceOrder ? AppTheme.primary : AppTheme.error,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tổng công nợ hiện tại: ${_fmt(notif.creditInfo!.currentDebt)} / ${_fmt(notif.creditInfo!.creditLimit)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: notif.creditInfo!.canPlaceOrder ? AppTheme.onSurface : AppTheme.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              notif.creditInfo!.canPlaceOrder
                                  ? 'Bạn đã sử dụng ${notif.creditInfo!.usagePercent}% hạn mức công nợ được cấp.'
                                  : 'Hạn mức công nợ đã vượt quá quy định! Hãy thanh toán trước khi đặt đơn mới.',
                              style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 3. Horizontal Categories list
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (context, idx) {
              final cat = _categories[idx];
              final isSel = _selectedCategory == cat['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    children: [
                      Text(cat['icon']!),
                      const SizedBox(width: 4),
                      Text(cat['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  selected: isSel,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = cat['name']!);
                  },
                  selectedColor: AppTheme.primary.withOpacity(0.2),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isSel ? AppTheme.primary : Colors.white.withOpacity(0.4)),
                  ),
                ),
              );
            },
          ),
        ),

        // 4. Cart Banner
        if (!cart.isEmpty)
          _CartBanner(
            itemCount: cart.itemCount,
            grandTotal: cart.grandTotal,
          ),

        // 5. Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nhanh nguyên liệu...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
              filled: true,
              fillColor: Colors.white.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            onChanged: (val) => inventory.setSearchQuery(val),
          ),
        ),

        // 6. Ingredients Grid
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('Không tìm thấy nguyên liệu nào trong danh mục này.',
                      style: TextStyle(color: AppTheme.onSurfaceVariant)))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final ingredient = items[i];
                    final inCart = cart.cartItems.any((c) => c.ingredientId == ingredient.ingredientId);

                    return _IngredientCard(
                      ingredientId: ingredient.ingredientId,
                      name: ingredient.name,
                      unit: ingredient.unit,
                      unitPrice: ingredient.unitPrice,
                      availableQty: ingredient.availableQuantity,
                      isInCart: inCart,
                      cartQuantity: inCart
                          ? cart.cartItems
                              .firstWhere((c) => c.ingredientId == ingredient.ingredientId)
                              .quantity
                          : 0,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  )
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant.withOpacity(0.7), fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    final p = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) b.write('.');
      b.write(p[i]);
    }
    return '${b.toString()} đ';
  }
}

class _IngredientCard extends StatelessWidget {
  final int ingredientId;
  final String name;
  final String unit;
  final double unitPrice;
  final double availableQty;
  final bool isInCart;
  final int cartQuantity;

  const _IngredientCard({
    required this.ingredientId,
    required this.name,
    required this.unit,
    required this.unitPrice,
    required this.availableQty,
    required this.isInCart,
    required this.cartQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartOrderProvider>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: isInCart ? AppTheme.primary.withOpacity(0.08) : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isInCart ? AppTheme.primary.withOpacity(0.6) : Colors.white.withOpacity(0.6),
              width: isInCart ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              if (isInCart)
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image container
              Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isInCart ? AppTheme.primary : AppTheme.secondary).withOpacity(0.12),
                      (isInCart ? AppTheme.primary : AppTheme.secondary).withOpacity(0.02),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                  child: Icon(
                    Icons.inventory_2_rounded,
                    size: 32,
                    color: (isInCart ? AppTheme.primary : AppTheme.secondary).withOpacity(0.8),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_fmt(unitPrice)} / $unit',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isInCart)
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => cart.addItem(
                            ingredientId: ingredientId,
                            name: name,
                            unit: unit,
                            unitPrice: unitPrice,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text(
                            '+ Thêm giỏ hàng',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          _StepperBtn(
                            icon: cartQuantity <= 1
                                ? Icons.delete_outline_rounded
                                : Icons.remove_rounded,
                            color: cartQuantity <= 1
                                ? AppTheme.error
                                : AppTheme.primary,
                            onTap: () => cart.decreaseItem(ingredientId),
                          ),
                          Expanded(
                            child: Text(
                              '$cartQuantity',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.onSurface),
                            ),
                          ),
                          _StepperBtn(
                            icon: Icons.add_rounded,
                            color: AppTheme.primary,
                            onTap: () => cart.addItem(
                              ingredientId: ingredientId,
                              name: name,
                              unit: unit,
                              unitPrice: unitPrice,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    final p = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) b.write('.');
      b.write(p[i]);
    }
    return '${b.toString()} đ';
  }
}

class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StepperBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: Lịch sử đơn hàng
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTab extends StatefulWidget {
  const _HistoryTab();

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  String _selectedStatus = 'Tất cả';

  final List<String> _statusFilters = ['Tất cả', 'Pending', 'Approved', 'Delivering', 'Delivered', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartOrderProvider>();

    if (cart.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final filteredOrders = cart.orders.where((o) {
      if (_selectedStatus == 'Tất cả') return true;
      return o.orderStatus == _selectedStatus;
    }).toList();

    // Summing values
    final totalSpent = cart.orders.where((o) => o.orderStatus != 'Cancelled').fold(0.0, (sum, item) => sum + item.totalAmount);

    return Column(
      children: [
        // Analytics Summary Header Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng chi tiêu tích lũy', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_fmt(totalSpent), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
                )
              ],
            ),
          ),
        ),

        // Status Filter Chips
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            itemCount: _statusFilters.length,
            itemBuilder: (context, idx) {
              final status = _statusFilters[idx];
              final isSel = _selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_translateStatus(status), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  selected: isSel,
                  onSelected: (selected) {
                    setState(() => _selectedStatus = status);
                  },
                  selectedColor: AppTheme.primary.withOpacity(0.2),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isSel ? AppTheme.primary : Colors.white.withOpacity(0.4)),
                  ),
                ),
              );
            },
          ),
        ),

        // List View
        Expanded(
          child: filteredOrders.isEmpty
              ? RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async {
                    final auth = context.read<AuthProvider>();
                    if (auth.storeId != null) {
                      await cart.loadOrdersAsync(auth.storeId!);
                    }
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.outline),
                              SizedBox(height: 16),
                              Text('Không tìm thấy đơn hàng nào.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async {
                    final auth = context.read<AuthProvider>();
                    if (auth.storeId != null) {
                      await cart.loadOrdersAsync(auth.storeId!);
                    }
                  },
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(14),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _OrderCard(order: filteredOrders[i]),
                  ),
                ),
        ),
      ],
    );
  }

  String _translateStatus(String s) {
    switch (s) {
      case 'Tất cả': return 'Tất cả';
      case 'Pending': return '⏳ Chờ duyệt';
      case 'Approved': return '✅ Đã duyệt';
      case 'Delivering': return '🚚 Đang giao';
      case 'Delivered': return '📦 Đã nhận';
      case 'Cancelled': return '❌ Đã hủy';
      default: return s;
    }
  }

  String _fmt(double v) {
    final p = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) b.write('.');
      b.write(p[i]);
    }
    return '${b.toString()} đ';
  }
}

class _OrderCard extends StatelessWidget {
  final OrderSummaryModel order;

  const _OrderCard({required this.order});

  static const _statusConfig = {
    'Pending': (Color(0xFFFFF3E0), Color(0xFFE65100), 'Chờ duyệt'),
    'Approved': (Color(0xFFE3F2FD), Color(0xFF1565C0), 'Đã duyệt'),
    'Delivering': (Color(0xFFF3E5F5), Color(0xFF6A1B9A), 'Đang giao'),
    'Delivered': (Color(0xFFE8F5E9), Color(0xFF2E7D32), 'Đã nhận'),
    'Cancelled': (Color(0xFFFFEBEE), Color(0xFFC62828), 'Đã hủy'),
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _statusConfig[order.orderStatus] ??
        (AppTheme.surfaceContainer, AppTheme.onSurfaceVariant, order.orderStatus);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.orderCode,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cfg.$1.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: cfg.$2.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      cfg.$3,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: cfg.$2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${order.itemCount} loại nguyên liệu  •  ${order.createdAt != null ? _fmtDate(order.createdAt!) : ""}',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.onSurfaceVariant.withOpacity(0.8), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Colors.white24),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng tiền:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _fmt(order.totalAmount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    final p = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) b.write('.');
      b.write(p[i]);
    }
    return '${b.toString()} đ';
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: Tồn kho & Ghi nhận tiêu thụ
// ─────────────────────────────────────────────────────────────────────────────

class _InventoryTab extends StatefulWidget {
  const _InventoryTab();

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab> {
  String _stockFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartOrderProvider>();
    final auth = context.read<AuthProvider>();

    // Stock details calculations
    final lowStockItems = cart.storeInventory.where((i) => i.stockQuantity < 5).toList();
    final healthyStockItems = cart.storeInventory.where((i) => i.stockQuantity >= 5).toList();

    final filteredInventory = _stockFilter == 'Tất cả'
        ? cart.storeInventory
        : _stockFilter == 'Sắp hết'
            ? lowStockItems
            : healthyStockItems;

    return Column(
      children: [
        // Stock Health Chart Panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tình trạng tồn kho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('Tổng số mặt hàng: ${cart.storeInventory.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Ổn định: ${healthyStockItems.length}', style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 14),
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Sắp hết: ${lowStockItems.length}', style: const TextStyle(fontSize: 11, color: AppTheme.error, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: cart.storeInventory.isEmpty
                            ? 1.0
                            : healthyStockItems.length / cart.storeInventory.length,
                        backgroundColor: AppTheme.error.withOpacity(0.2),
                        color: const Color(0xFF16A34A),
                        strokeWidth: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Filter chips for stock
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              _buildStockFilterChip('Tất cả'),
              const SizedBox(width: 8),
              _buildStockFilterChip('Sắp hết'),
              const SizedBox(width: 8),
              _buildStockFilterChip('Ổn định'),
            ],
          ),
        ),

        Expanded(
          child: filteredInventory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warehouse_outlined, size: 64, color: AppTheme.outline),
                      const SizedBox(height: 16),
                      const Text('Không có dữ liệu tồn kho phù hợp.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (auth.storeId != null) {
                            cart.loadStoreInventoryAsync(auth.storeId!);
                          }
                        },
                        child: const Text('Tải lại'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: filteredInventory.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final inv = filteredInventory[i];
                    final isLowStock = inv.stockQuantity < 5;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isLowStock ? AppTheme.error.withOpacity(0.05) : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isLowStock ? AppTheme.error.withOpacity(0.3) : Colors.white.withOpacity(0.6),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isLowStock ? AppTheme.error : AppTheme.primary).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.inventory_2_rounded,
                                  color: isLowStock ? AppTheme.error : AppTheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inv.ingredientName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SKU: ${inv.sku}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.onSurfaceVariant.withOpacity(0.7)),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${inv.stockQuantity.toStringAsFixed(1)} ${inv.unit}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isLowStock ? AppTheme.error : AppTheme.primary,
                                    ),
                                  ),
                                  if (isLowStock)
                                    const Text(
                                      'Sắp hết hàng',
                                      style: TextStyle(
                                          fontSize: 9, color: AppTheme.error, fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // FAB Ghi nhận tiêu thụ
        Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF1744).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showConsumeSheet(context, cart, auth.storeId ?? 0),
              icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white),
              label: const Text('Ghi nhận tiêu thụ / Hao hụt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockFilterChip(String label) {
    final isSel = _stockFilter == label;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      selected: isSel,
      onSelected: (val) {
        setState(() => _stockFilter = label);
      },
      selectedColor: AppTheme.primary.withOpacity(0.2),
      backgroundColor: Colors.white.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSel ? AppTheme.primary : Colors.white.withOpacity(0.4)),
      ),
    );
  }
}

// ─── Shared UI Components ───────────────────────────────────────────────────

class _CartBanner extends StatelessWidget {
  final int itemCount;
  final double grandTotal;

  const _CartBanner({required this.itemCount, required this.grandTotal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã chọn $itemCount loại nguyên liệu',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        'Tổng tạm tính: ${_fmt(grandTotal)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Xem Giỏ hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    final p = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) b.write('.');
      b.write(p[i]);
    }
    return '${b.toString()} đ';
  }
}

void _showConsumeSheet(BuildContext context, CartOrderProvider cart, int storeId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: _ConsumeBottomSheet(storeId: storeId),
        ),
      ),
    ),
  );
}

class _ConsumeBottomSheet extends StatefulWidget {
  final int storeId;

  const _ConsumeBottomSheet({required this.storeId});

  @override
  State<_ConsumeBottomSheet> createState() => _ConsumeBottomSheetState();
}

class _ConsumeBottomSheetState extends State<_ConsumeBottomSheet> {
  String _consumeType = 'SOLD';
  final _reasonCtrl = TextEditingController();
  final Map<int, TextEditingController> _qtyControllers = {};

  @override
  void dispose() {
    _reasonCtrl.dispose();
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartOrderProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outlineVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ghi nhận tiêu thụ / Hao hụt',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface),
          ),
          const SizedBox(height: 16),

          // Loại tiêu thụ
          Row(
            children: [
              _TypeChip(
                label: '🛒 Đã bán',
                value: 'SOLD',
                selected: _consumeType == 'SOLD',
                onTap: () => setState(() => _consumeType = 'SOLD'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: '🗑 Hao hụt',
                value: 'WASTE',
                selected: _consumeType == 'WASTE',
                onTap: () => setState(() => _consumeType = 'WASTE'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: '❌ Hủy',
                value: 'DISCARD',
                selected: _consumeType == 'DISCARD',
                onTap: () => setState(() => _consumeType = 'DISCARD'),
              ),
            ],
          ),
          if (_consumeType != 'SOLD') ...[
            const SizedBox(height: 14),
            TextField(
              controller: _reasonCtrl,
              decoration: InputDecoration(
                labelText: 'Lý do *',
                hintText: 'Ghi rõ lý do hao hụt/hủy...',
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Số lượng tiêu thụ từng nguyên liệu:',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: cart.storeInventory.isEmpty
                ? const Center(
                    child: Text('Không có tồn kho để ghi nhận.'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: cart.storeInventory.length,
                    itemBuilder: (_, i) {
                      final inv = cart.storeInventory[i];
                      _qtyControllers.putIfAbsent(
                          inv.ingredientId, () => TextEditingController());
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                inv.ingredientName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 90,
                              child: TextField(
                                controller:
                                    _qtyControllers[inv.ingredientId],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  suffixText: inv.unit,
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.3),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [Color(0xFFFF5252), Color(0xFFFF1744)]),
            ),
            child: ElevatedButton(
              onPressed: () => _submit(context, cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Xác nhận Ghi nhận', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, CartOrderProvider cart) async {
    final items = <ConsumeItemPayload>[];
    for (final entry in _qtyControllers.entries) {
      final qty = double.tryParse(entry.value.text.trim()) ?? 0;
      if (qty > 0) {
        items.add(ConsumeItemPayload(
            ingredientId: entry.key, quantity: qty));
      }
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số lượng tiêu thụ.')),
      );
      return;
    }

    Navigator.pop(context);
    await cart.consumeInventoryAsync(
      storeId: widget.storeId,
      consumeType: _consumeType,
      items: items,
      reason: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
    );

    if (!context.mounted) return;
    if (cart.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ghi nhận tiêu thụ thành công!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withOpacity(0.15)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppTheme.primary : Colors.white.withOpacity(0.5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      );
}
