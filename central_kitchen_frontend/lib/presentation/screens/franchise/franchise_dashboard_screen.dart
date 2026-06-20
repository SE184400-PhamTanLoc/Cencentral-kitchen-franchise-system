import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/cart_order_provider.dart';
import '../../../business/providers/inventory_provider.dart';
import '../../../business/providers/notification_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/order_model.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'notification_screen.dart';

/// Dashboard chính cho Franchise Store Staff.
/// Gồm 3 tab:
///   - Tab 0: Đặt hàng (danh mục nguyên liệu + giỏ hàng)
///   - Tab 1: Lịch sử đơn hàng
///   - Tab 2: Tồn kho & Ghi nhận tiêu thụ
class FranchiseDashboardScreen extends StatefulWidget {
  const FranchiseDashboardScreen({super.key});

  @override
  State<FranchiseDashboardScreen> createState() =>
      _FranchiseDashboardScreenState();
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

    // Tải dữ liệu ban đầu
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
    // Tải danh mục nguyên liệu để hiển thị trong tab đặt hàng
    await inventory.fetchIngredients();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final cart = context.watch<CartOrderProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Central Kitchen',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            Text(
              auth.currentUser?.fullName ?? 'Cửa hàng nhượng quyền',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        actions: [
          // Badge Thông báo
          Consumer<NotificationProvider>(
            builder: (context, notif, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
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
                              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Badge giỏ hàng
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white),
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          // Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppTheme.surfaceContainerLowest,
        indicatorColor: AppTheme.primary.withOpacity(0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.add_shopping_cart_outlined),
            selectedIcon: const Icon(Icons.add_shopping_cart,
                color: AppTheme.primary),
            label: 'Đặt hàng',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon:
                const Icon(Icons.receipt_long, color: AppTheme.primary),
            label: 'Lịch sử',
          ),
          NavigationDestination(
            icon: const Icon(Icons.warehouse_outlined),
            selectedIcon:
                const Icon(Icons.warehouse, color: AppTheme.primary),
            label: 'Kho & Tiêu thụ',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 0: Đặt hàng — Danh mục nguyên liệu
// ─────────────────────────────────────────────────────────────────────────────

class _OrderTab extends StatelessWidget {
  const _OrderTab();

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final cart = context.watch<CartOrderProvider>();

    if (inventory.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return Column(
      children: [
        // Credit Info Banner
        Consumer<NotificationProvider>(
          builder: (context, notif, child) {
            final credit = notif.creditInfo;
            if (credit == null) return const SizedBox.shrink();
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: credit.canPlaceOrder ? AppTheme.primary.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    credit.canPlaceOrder ? Icons.account_balance_wallet_outlined : Icons.warning_amber_rounded,
                    color: credit.canPlaceOrder ? AppTheme.primary : AppTheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Công nợ: ${_fmt(credit.currentDebt)} / ${credit.creditLimit > 0 ? _fmt(credit.creditLimit) : "Không giới hạn"}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: credit.canPlaceOrder ? AppTheme.onSurface : AppTheme.error,
                          ),
                        ),
                        if (!credit.canPlaceOrder)
                          const Text(
                            'Đã vượt hạn mức! Không thể đặt hàng mới.',
                            style: TextStyle(fontSize: 11, color: AppTheme.error),
                          )
                        else if (credit.creditLimit > 0)
                          Text(
                            'Đã dùng ${credit.usagePercent}% hạn mức',
                            style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Banner tổng giỏ hàng
        if (!cart.isEmpty)
          _CartBanner(
            itemCount: cart.itemCount,
            grandTotal: cart.grandTotal,
          ),

        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nguyên liệu...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
              filled: true,
              fillColor: AppTheme.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
            onChanged: (val) => inventory.setSearchQuery(val),
          ),
        ),

        // Grid nguyên liệu
        Expanded(
          child: inventory.ingredients.isEmpty
              ? const Center(
                  child: Text(
                    'Không tìm thấy nguyên liệu',
                    style: TextStyle(color: AppTheme.onSurfaceVariant),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: inventory.ingredients.length,
                  itemBuilder: (ctx, i) {
                    final ingredient = inventory.ingredients[i];
                    final inCart = cart.cartItems.any(
                        (c) => c.ingredientId == ingredient.ingredientId);

                    return _IngredientCard(
                      ingredientId: ingredient.ingredientId,
                      name: ingredient.name,
                      unit: ingredient.unit,
                      unitPrice: ingredient.unitPrice,
                      availableQty: ingredient.availableQuantity,
                      isInCart: inCart,
                      cartQuantity: inCart
                          ? cart.cartItems
                              .firstWhere((c) =>
                                  c.ingredientId == ingredient.ingredientId)
                              .quantity
                          : 0,
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v == 0) return '0 đ';
    final p = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) b.write('.');
      b.write(p[i]);
    }
    return '${b.toString()} đ';
  }
}

class _CartBanner extends StatelessWidget {
  final int itemCount;
  final double grandTotal;

  const _CartBanner({required this.itemCount, required this.grandTotal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppTheme.primary,
        child: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              '$itemCount loại nguyên liệu trong giỏ',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const Spacer(),
            Text(
              _fmt(grandTotal),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 14),
          ],
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

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isInCart ? AppTheme.primary : AppTheme.outlineVariant,
          width: isInCart ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header xanh
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Center(
              child: Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: AppTheme.primary.withOpacity(0.7),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _fmt(unitPrice) + ' / $unit',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.secondary),
                ),
                const SizedBox(height: 8),
                // Nút thêm / stepper
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
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text(
                        '+ Thêm vào giỏ',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      _StepperBtn(
                        icon: cartQuantity <= 1
                            ? Icons.delete_outline
                            : Icons.remove,
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
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      _StepperBtn(
                        icon: Icons.add,
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

  const _StepperBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.outlineVariant),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: Lịch sử đơn hàng
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartOrderProvider>();

    if (cart.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (cart.orders.isEmpty) {
      return RefreshIndicator(
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
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: AppTheme.outline),
                    SizedBox(height: 16),
                    Text('Chưa có đơn hàng nào',
                        style: TextStyle(
                            fontSize: 16, color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async {
        final auth = context.read<AuthProvider>();
        if (auth.storeId != null) {
          await cart.loadOrdersAsync(auth.storeId!);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cart.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => _OrderCard(order: cart.orders[i]),
      ),
    );
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

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.orderCode,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cfg.$1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cfg.$3,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cfg.$2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.itemCount} loại nguyên liệu  •  ${order.createdAt != null ? _fmtDate(order.createdAt!) : ""}',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng: ${_fmt(order.totalAmount)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ],
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

class _InventoryTab extends StatelessWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartOrderProvider>();
    final auth = context.read<AuthProvider>();

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          color: AppTheme.primary,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: const Text(
            'Tồn kho tại cửa hàng',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ),

        Expanded(
          child: cart.storeInventory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warehouse_outlined,
                          size: 64, color: AppTheme.outline),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có dữ liệu tồn kho',
                        style: TextStyle(color: AppTheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
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
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.storeInventory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) {
                    final inv = cart.storeInventory[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inv.ingredientName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  inv.sku,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.onSurfaceVariant),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: inv.stockQuantity < 5
                                      ? AppTheme.error
                                      : AppTheme.primary,
                                ),
                              ),
                              if (inv.stockQuantity < 5)
                                const Text(
                                  'Sắp hết',
                                  style: TextStyle(
                                      fontSize: 11, color: AppTheme.error),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // FAB ghi nhận tiêu thụ
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () =>
                _showConsumeSheet(context, cart, auth.storeId ?? 0),
            icon: const Icon(Icons.remove_circle_outline),
            label: const Text('Ghi nhận tiêu thụ / Hao hụt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  void _showConsumeSheet(
      BuildContext context, CartOrderProvider cart, int storeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ConsumeBottomSheet(storeId: storeId),
    );
  }
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
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ghi nhận tiêu thụ / Hao hụt',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface),
          ),
          const SizedBox(height: 12),

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
            const SizedBox(height: 10),
            TextField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Lý do *',
                hintText: 'Ghi rõ lý do hao hụt/hủy...',
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            'Số lượng tiêu thụ từng nguyên liệu:',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          // Danh sách tồn kho (compact)
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
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller:
                                    _qtyControllers[inv.ingredientId],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  suffixText: inv.unit,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _submit(context, cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Xác nhận Ghi nhận'),
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
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withOpacity(0.12)
                : AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      );
}
