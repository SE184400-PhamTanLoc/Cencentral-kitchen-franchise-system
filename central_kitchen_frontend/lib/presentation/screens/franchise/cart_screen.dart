import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/cart_order_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/order_model.dart';
import 'checkout_screen.dart';

/// THAI_FLUT_02 — Màn hình Giỏ Hàng
/// Hiển thị danh sách nguyên liệu đã chọn, cho phép điều chỉnh số lượng,
/// xem tổng tiền tạm tính và điều hướng sang màn hình Xác nhận đặt hàng.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartOrderProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: _buildAppBar(context, cart),
          body: cart.isEmpty ? _buildEmptyState() : _buildCartContent(context, cart),
          bottomNavigationBar: cart.isEmpty ? null : _buildBottomBar(context, cart),
        );
      },
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context, CartOrderProvider cart) {
    return AppBar(
      title: const Text(
        'Giỏ Hàng',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppTheme.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (!cart.isEmpty)
          TextButton.icon(
            onPressed: () => _confirmClearCart(context, cart),
            icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 20),
            label: const Text(
              'Xóa tất cả',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
      ],
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: AppTheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm nguyên liệu từ danh mục để bắt đầu đặt hàng',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: null, // Điều hướng về tab danh mục (xử lý từ Dashboard)
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Chọn nguyên liệu'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Cart Content ──────────────────────────────────────────────────────────

  Widget _buildCartContent(BuildContext context, CartOrderProvider cart) {
    return Column(
      children: [
        // Header: số lượng item
        Container(
          width: double.infinity,
          color: AppTheme.surfaceContainerLowest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            '${cart.itemCount} loại nguyên liệu  •  ${cart.totalUnits} đơn vị',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Divider(height: 1, color: AppTheme.outlineVariant),

        // Danh sách items
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: cart.cartItems.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 72,
              color: AppTheme.outlineVariant,
            ),
            itemBuilder: (context, index) =>
                _CartItemTile(item: cart.cartItems[index]),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Summary Bar ────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, CartOrderProvider cart) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tóm tắt chi phí
              _SummaryRow(
                label: 'Tạm tính',
                value: _formatCurrency(cart.subtotal),
                isHighlighted: false,
              ),
              const SizedBox(height: 6),
              _SummaryRow(
                label: 'Thuế VAT (10%)',
                value: _formatCurrency(cart.taxAmount),
                isHighlighted: false,
              ),
              const SizedBox(height: 6),
              _SummaryRow(
                label: cart.shippingAmount == 0
                    ? 'Phí vận chuyển  🎉 Miễn phí'
                    : 'Phí vận chuyển',
                value: cart.shippingAmount == 0
                    ? 'Miễn phí'
                    : _formatCurrency(cart.shippingAmount),
                isHighlighted: false,
                valueColor: cart.shippingAmount == 0
                    ? const Color(0xFF16A34A)
                    : null,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: AppTheme.outlineVariant),
              ),
              _SummaryRow(
                label: 'Tổng cộng',
                value: _formatCurrency(cart.grandTotal),
                isHighlighted: true,
              ),
              const SizedBox(height: 14),

              // CTA Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Xác nhận đặt hàng',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  Future<void> _confirmClearCart(
      BuildContext context, CartOrderProvider cart) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text(
            'Bạn có chắc muốn xóa tất cả nguyên liệu khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa tất cả',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) cart.clearCart();
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  String _formatCurrency(double value) {
    // Format: 1.234.567 đ
    final parts = value.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return '${buffer.toString()} đ';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart Item Tile Widget
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartOrderProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon nguyên liệu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Tên và giá
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatCurrency(item.unitPrice)} / ${item.unit}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thành tiền: ${_formatCurrency(item.subtotal)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Stepper tăng/giảm số lượng
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút giảm
                InkWell(
                  onTap: () => cart.decreaseItem(item.ingredientId),
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(7)),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Icon(
                      item.quantity <= 1
                          ? Icons.delete_outline
                          : Icons.remove,
                      size: 18,
                      color: item.quantity <= 1
                          ? AppTheme.error
                          : AppTheme.primary,
                    ),
                  ),
                ),

                // Số lượng
                Container(
                  width: 36,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(color: AppTheme.outlineVariant),
                    ),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ),

                // Nút tăng
                InkWell(
                  onTap: () => cart.addItem(
                    ingredientId: item.ingredientId,
                    name: item.name,
                    unit: item.unit,
                    unitPrice: item.unitPrice,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(7)),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return '${buffer.toString()} đ';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Row Widget
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isHighlighted,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlighted ? 16 : 14,
            fontWeight:
                isHighlighted ? FontWeight.w700 : FontWeight.w400,
            color: isHighlighted
                ? AppTheme.onSurface
                : AppTheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 14,
            fontWeight:
                isHighlighted ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ??
                (isHighlighted
                    ? AppTheme.primary
                    : AppTheme.onSurface),
          ),
        ),
      ],
    );
  }
}
