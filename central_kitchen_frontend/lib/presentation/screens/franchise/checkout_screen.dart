import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/cart_order_provider.dart';
import '../../../core/constants/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _noteController = TextEditingController();
  final _promoController = TextEditingController();
  bool _acceptTerms = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartOrderProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        title: const Text(
          'Xác nhận đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background neon bubbles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primary.withOpacity(0.15), AppTheme.secondary.withOpacity(0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.secondary.withOpacity(0.12), AppTheme.primary.withOpacity(0.05)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Interactive Shipping Timeline Tracker Section
                  _buildTimelineTracker(),
                  const SizedBox(height: 14),

                  // 2. Store & Shipping Info Card
                  _buildSectionHeader('Thông tin nhận hàng'),
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              auth.currentUser?.storeName ?? 'Chi nhánh Cửa hàng',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppTheme.outline, size: 18),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Địa chỉ cửa hàng nhượng quyền hệ thống',
                                style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Order Checklist Summary
                  _buildSectionHeader('Danh sách nguyên liệu (${cart.itemCount})'),
                  _buildGlassCard(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.cartItems.length,
                      separatorBuilder: (ctx, idx) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Colors.white24, height: 1),
                      ),
                      itemBuilder: (ctx, i) {
                        final item = cart.cartItems[i];
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.cookie_outlined, size: 18, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Số lượng: ${item.quantity} ${item.unit}  •  ${_fmt(item.unitPrice)}',
                                    style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _fmt(item.subtotal),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Promo Code / Voucher Section
                  _buildSectionHeader('Ưu đãi & Khuyến mãi'),
                  _buildGlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Nhập mã giảm giá...',
                              prefixIcon: const Icon(Icons.card_giftcard_rounded, color: AppTheme.secondary, size: 20),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.3),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mã giảm giá không hợp lệ hoặc đã hết hạn.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(80, 36),
                            elevation: 0,
                          ),
                          child: const Text('Áp dụng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Delivery Note & Comments
                  _buildSectionHeader('Ghi chú vận chuyển'),
                  _buildGlassCard(
                    child: TextField(
                      controller: _noteController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'VD: Giao trước 10h sáng, nguyên liệu bảo quản lạnh...',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 6. Pricing Invoice Details (Digital Receipt design)
                  _buildSectionHeader('Hóa đơn tạm tính'),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildPriceRow('Tạm tính nguyên liệu', _fmt(cart.subtotal)),
                        const SizedBox(height: 8),
                        _buildPriceRow('Thuế VAT (10%)', _fmt(cart.taxAmount)),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Phí vận chuyển',
                          cart.shippingAmount == 0 ? 'Miễn phí' : _fmt(cart.shippingAmount),
                          valColor: cart.shippingAmount == 0 ? const Color(0xFF16A34A) : null,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Colors.white24, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng chi phí', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(_fmt(cart.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 7. Terms Agreement & Warnings
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 1),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Đơn hàng sẽ được kiểm tra hạn mức công nợ tự động. Hệ thống sẽ từ chối nếu vượt hạn mức.',
                                style: TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        activeColor: AppTheme.primary,
                        onChanged: (v) {
                          if (v != null) setState(() => _acceptTerms = v);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Tôi cam kết nhận hàng và tuân thủ các quy định thanh toán công nợ của hệ thống.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 8. Submit button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: _acceptTerms
                            ? [AppTheme.primary, AppTheme.secondary]
                            : [Colors.grey.shade400, Colors.grey.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        if (_acceptTerms)
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || !_acceptTerms) ? null : () => _submitOrder(context, cart, auth),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Gửi Đơn Đặt Hàng',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTracker() {
    return _buildGlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimelineStep('Đặt hàng', true, true),
          _buildTimelineLine(true),
          _buildTimelineStep('Duyệt đơn', false, false),
          _buildTimelineLine(false),
          _buildTimelineStep('Giao hàng', false, false),
          _buildTimelineLine(false),
          _buildTimelineStep('Nhận hàng', false, false),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, bool isDone, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone
                ? AppTheme.primary
                : isActive
                    ? AppTheme.secondary
                    : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.white : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              size: 12,
              color: isDone || isActive ? Colors.white : AppTheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 9, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }

  Widget _buildTimelineLine(bool isPassed) {
    return Expanded(
      child: Container(
        height: 2,
        color: isPassed ? AppTheme.primary : Colors.white24,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
          child: child,
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String val, {Color? valColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
        Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valColor ?? AppTheme.onSurface)),
      ],
    );
  }

  Future<void> _submitOrder(BuildContext context, CartOrderProvider cart, AuthProvider auth) async {
    setState(() => _isSubmitting = true);

    final storeId = auth.storeId ?? 0;
    final kitchenId = auth.kitchenId ?? 1;

    try {
      final success = await cart.placeOrderAsync(
        storeId: storeId,
        kitchenId: kitchenId,
        notes: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        // Success
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mã đơn: ${cart.lastPlacedOrder?.orderCode ?? ""}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đơn hàng đang chờ bếp trung tâm xác nhận.\nBạn có thể theo dõi trong mục Lịch sử đơn hàng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Back to Cart
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('Đã hiểu'),
              ),
            ],
          ),
        );
      } else {
        // Error
        _showErrorDialog(context, cart.errorMessage ?? 'Đặt hàng thất bại. Vui lòng thử lại.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showErrorDialog(context, 'Có lỗi xảy ra: $e');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đặt hàng thất bại', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error)),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: AppTheme.primary)),
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
