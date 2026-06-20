import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/cart_order_provider.dart';
import '../../../core/constants/app_theme.dart';

/// THAI_FLUT_03 — Màn hình Xác nhận & Gửi Đơn Hàng (Checkout)
/// Hiển thị tóm tắt đơn hàng, cho phép nhập ghi chú
/// và gửi đơn đặt hàng lên Backend.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartOrderProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Xác nhận Đơn Hàng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── 1. Thông tin cửa hàng ──────────────────────────────────────
            _buildSection(
              title: 'Thông tin đặt hàng',
              icon: Icons.store_outlined,
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Cửa hàng',
                    value: auth.currentUser?.storeName ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Người đặt',
                    value: auth.currentUser?.fullName ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Thời gian',
                    value: _formatDateTime(DateTime.now()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 2. Danh sách nguyên liệu đặt ──────────────────────────────
            _buildSection(
              title: 'Danh sách nguyên liệu (${cart.itemCount} loại)',
              icon: Icons.inventory_2_outlined,
              child: Column(
                children: [
                  ...cart.cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            // Số thứ tự
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${cart.cartItems.indexOf(item) + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Tên nguyên liệu
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                            ),
                            // Số lượng & đơn vị
                            Text(
                              '${item.quantity} ${item.unit}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Thành tiền
                            Text(
                              _formatCurrency(item.subtotal),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 3. Tổng chi phí ────────────────────────────────────────────
            _buildSection(
              title: 'Chi phí',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _CostRow(label: 'Tạm tính', value: cart.subtotal),
                  const SizedBox(height: 6),
                  _CostRow(label: 'Thuế VAT (10%)', value: cart.taxAmount),
                  const SizedBox(height: 6),
                  _CostRow(
                    label: cart.shippingAmount == 0
                        ? 'Vận chuyển (Miễn phí)'
                        : 'Vận chuyển',
                    value: cart.shippingAmount,
                    valueColor: cart.shippingAmount == 0
                        ? const Color(0xFF16A34A)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: AppTheme.outlineVariant),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Text(
                        _formatCurrency(cart.grandTotal),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 4. Ghi chú đơn hàng ────────────────────────────────────────
            _buildSection(
              title: 'Ghi chú đơn hàng',
              icon: Icons.edit_note_outlined,
              child: TextFormField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText:
                      'Nhập ghi chú cho đơn hàng (thời gian giao, yêu cầu đặc biệt...)',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 5. Cảnh báo hạn mức công nợ ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFD700)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Color(0xFF856404), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đơn hàng sẽ được kiểm tra hạn mức công nợ tự động. '
                      'Hệ thống sẽ từ chối nếu vượt hạn mức.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF856404)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 6. Nút gửi đơn ────────────────────────────────────────────
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _onSubmitOrder(context, cart, auth),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Gửi Đơn Đặt Hàng',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),

            // Nút hủy / quay lại giỏ
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppTheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Quay lại Giỏ hàng',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Submit Logic ──────────────────────────────────────────────────────────

  Future<void> _onSubmitOrder(
    BuildContext context,
    CartOrderProvider cart,
    AuthProvider auth,
  ) async {
    final storeId = auth.storeId;
    final kitchenId = auth.kitchenId ?? 1;

    if (storeId == null) {
      _showErrorSnackbar(context,
          'Không xác định được thông tin cửa hàng. Vui lòng đăng nhập lại.');
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await cart.placeOrderAsync(
      storeId: storeId,
      kitchenId: kitchenId,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      await _showSuccessDialog(context, cart.lastPlacedOrder?.orderCode ?? '');
      if (!mounted) return;
      // Về màn hình trước (cart) rồi pop tiếp về dashboard
      Navigator.pop(context); // Pop CheckoutScreen
      Navigator.pop(context); // Pop CartScreen
    } else {
      _showErrorSnackbar(
          context, cart.errorMessage ?? 'Gửi đơn hàng thất bại.');
    }
  }

  // ─── Dialogs & Snackbars ───────────────────────────────────────────────────

  Future<void> _showSuccessDialog(
      BuildContext context, String orderCode) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon check xanh
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đặt hàng thành công!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (orderCode.isNotEmpty)
              Text(
                'Mã đơn: $orderCode',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Đơn hàng đang chờ bếp trung tâm xác nhận.\nBạn có thể theo dõi trong mục Lịch sử đơn hàng.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─── Builder Helpers ───────────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ),
        const Text(':', style: TextStyle(color: AppTheme.onSurfaceVariant)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;

  const _CostRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == 0
        ? 'Miễn phí'
        : _formatCurrency(value);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppTheme.onSurface,
          ),
        ),
      ],
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
