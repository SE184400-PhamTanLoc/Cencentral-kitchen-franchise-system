import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_theme.dart';

class UnifiedOrderCard extends StatelessWidget {
  final int orderId;
  final String orderCode;
  final String storeName;
  final String orderStatus;
  final DateTime? createdAt;
  final double totalAmount;
  final int itemCount;
  final VoidCallback onTap;

  const UnifiedOrderCard({
    super.key,
    required this.orderId,
    required this.orderCode,
    required this.storeName,
    required this.orderStatus,
    this.createdAt,
    required this.totalAmount,
    required this.itemCount,
    required this.onTap,
  });

  static const _statusConfig = {
    'PENDING': (bg: Color(0xFFFFFBEB), fg: Color(0xFFF59E0B), text: 'Chờ duyệt'),
    'APPROVED': (bg: Color(0xFFEFF6FF), fg: Color(0xFF0058BE), text: 'Đã duyệt'),
    'DELIVERING': (bg: Color(0xFFEFF6FF), fg: Color(0xFF0058BE), text: 'Đang giao'),
    'SHIPPING': (bg: Color(0xFFEFF6FF), fg: Color(0xFF0058BE), text: 'Đang giao'),
    'DISPATCHED': (bg: Color(0xFFEFF6FF), fg: Color(0xFF0058BE), text: 'Đang giao'),
    'SHIPPED': (bg: Color(0xFFEFF6FF), fg: Color(0xFF0058BE), text: 'Đã tới nơi'),
    'DELIVERED': (bg: Color(0xFFECFDF5), fg: Color(0xFF10B981), text: 'Đã nhận'),
    'COMPLETED': (bg: Color(0xFFECFDF5), fg: Color(0xFF10B981), text: 'Đã nhận'),
    'CANCELLED': (bg: Color(0xFFFEF2F2), fg: Color(0xFFEF4444), text: 'Đã hủy'),
    'REJECTED': (bg: Color(0xFFFEF2F2), fg: Color(0xFFEF4444), text: 'Đã hủy'),
  };

  @override
  Widget build(BuildContext context) {
    final statusUpper = orderStatus.toUpperCase();
    final cfg = _statusConfig[statusUpper] ??
        (bg: AppTheme.surfaceContainer, fg: AppTheme.onSurfaceVariant, text: orderStatus);

    final dateStr = createdAt != null
        ? DateFormat('dd/MM/yyyy - HH:mm').format(createdAt!.toLocal())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Code + Status Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cfg.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cfg.text,
                        style: TextStyle(
                          color: cfg.fg,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recipient Store / Destination
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.storefront_rounded, size: 16, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        storeName.isNotEmpty ? storeName : 'Cửa hàng nhượng quyền',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppTheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Date Time row
                if (dateStr.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.onSurfaceVariant.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                const Divider(height: 1, thickness: 0.8),
                const SizedBox(height: 12),

                // Bottom row: items count & total spent
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$itemCount loại nguyên liệu',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _fmt(totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
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
