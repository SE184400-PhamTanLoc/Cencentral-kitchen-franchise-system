import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../business/providers/auth_provider.dart';
import '../../business/providers/cart_order_provider.dart';
import '../../business/providers/manager_provider.dart';
import '../../business/providers/inventory_provider.dart';
import '../../business/providers/delivery_chat_provider.dart';
import '../../core/constants/app_theme.dart';
import '../../data/models/order_model.dart';

class SharedOrderDetailsModal extends StatefulWidget {
  final int orderId;
  final String orderCode;
  final String orderStatus;
  final VoidCallback? onRefresh;

  const SharedOrderDetailsModal({
    super.key,
    required this.orderId,
    required this.orderCode,
    required this.orderStatus,
    this.onRefresh,
  });

  static void show(BuildContext context, {
    required int orderId,
    required String orderCode,
    required String orderStatus,
    VoidCallback? onRefresh,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SharedOrderDetailsModal(
        orderId: orderId,
        orderCode: orderCode,
        orderStatus: orderStatus,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  State<SharedOrderDetailsModal> createState() => _SharedOrderDetailsModalState();
}

class _SharedOrderDetailsModalState extends State<SharedOrderDetailsModal> {
  final Map<int, TextEditingController> _controllers = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartOrderProvider>().loadOrderDetailAsync(widget.orderId);
      context.read<DeliveryChatProvider>().loadLatestLocationAsync(widget.orderId);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _notesController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartOrderProvider>();
    final auth = context.watch<AuthProvider>();
    final details = cart.selectedOrder;
    final role = auth.userRole ?? 'FRANCHISE_STAFF';

    // Populate controllers once details are available
    if (details != null && _controllers.isEmpty) {
      for (final item in details.items) {
        _controllers[item.ingredientId] = TextEditingController(
          text: (item.quantityDelivered ?? item.quantityOrdered).toStringAsFixed(1),
        );
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Top handle drag indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng ${widget.orderCode}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: cart.isLoading && details == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : details == null
                    ? const Center(
                        child: Text(
                          'Không thể tải chi tiết đơn hàng.',
                          style: TextStyle(color: AppTheme.onSurfaceVariant),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 5-step progress timeline
                            _buildTimeline(details.orderStatus),
                            const SizedBox(height: 16),

                            // General details card
                            _buildGeneralInfoCard(details),
                            const SizedBox(height: 16),

                            // Items Header
                            const Text(
                              'Danh sách nguyên liệu',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Items List
                            _buildItemsList(details, role),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),

          // Bottom Action Panel
          if (details != null) _buildActionPanel(context, details, role),
        ],
      ),
    );
  }

  Widget _buildTimeline(String status) {
    final statusUpper = status.toUpperCase();
    int activeStep = 0;
    bool isCancelled = false;

    if (statusUpper == 'PENDING') {
      activeStep = 0;
    } else if (statusUpper == 'APPROVED') {
      activeStep = 1;
    } else if (statusUpper == 'DELIVERING' || statusUpper == 'SHIPPING' || statusUpper == 'DISPATCHED') {
      activeStep = 2;
    } else if (statusUpper == 'SHIPPED') {
      activeStep = 3;
    } else if (statusUpper == 'DELIVERED' || statusUpper == 'COMPLETED') {
      activeStep = 4;
    } else if (statusUpper == 'CANCELLED' || statusUpper == 'REJECTED') {
      isCancelled = true;
      activeStep = -1;
    }

    final steps = ['Khởi tạo', 'Đã duyệt', 'Đang giao', 'Tới nơi', 'Đã nhận'];

    return Column(
      children: [
        if (isCancelled)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 20),
                const SizedBox(width: 8),
                Text(
                  statusUpper == 'REJECTED' ? 'Đơn hàng bị từ chối' : 'Đơn hàng đã hủy',
                  style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final isCompleted = index <= activeStep && activeStep != -1;
              final isCurrent = index == activeStep;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Line leading
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index == 0
                                ? Colors.transparent
                                : (index <= activeStep ? AppTheme.primary : AppTheme.outlineVariant.withOpacity(0.5)),
                          ),
                        ),
                        // Dot
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? AppTheme.primary
                                : (isCompleted ? AppTheme.primary.withOpacity(0.2) : Colors.white),
                            border: Border.all(
                              color: isCompleted ? AppTheme.primary : AppTheme.outlineVariant,
                              width: isCurrent ? 6 : 2,
                            ),
                          ),
                          child: isCompleted && !isCurrent
                              ? const Icon(Icons.check, size: 12, color: AppTheme.primary)
                              : null,
                        ),
                        // Line trailing
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index == steps.length - 1
                                ? Colors.transparent
                                : (index < activeStep ? AppTheme.primary : AppTheme.outlineVariant.withOpacity(0.5)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent
                            ? AppTheme.primary
                            : (isCompleted ? AppTheme.onSurface : AppTheme.onSurfaceVariant.withOpacity(0.6)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoCard(OrderDetailModel details) {
    final dateStr = details.createdAt != null
        ? DateFormat('dd/MM/yyyy - HH:mm').format(details.createdAt!.toLocal())
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today_rounded, 'Thời gian khởi tạo', dateStr),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.kitchen_rounded, 'Bếp cấp hàng', details.kitchenName),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.storefront_rounded, 'Cửa hàng nhận', details.storeName),
          if (details.notes != null && details.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(Icons.notes_rounded, 'Ghi chú đặt', details.notes!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12.5,
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(OrderDetailModel details, String role) {
    final statusUpper = details.orderStatus.toUpperCase();
    final isFranchiseConfirmState = role != 'MANAGER' &&
        role != 'ADMIN' &&
        role != 'KITCHEN_STAFF' &&
        role != 'SUPPLY_COORDINATOR' &&
        (statusUpper == 'SHIPPED' || statusUpper == 'DELIVERING' || statusUpper == 'APPROVED');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.items.length,
      separatorBuilder: (context, index) => const Divider(height: 12),
      itemBuilder: (context, index) {
        final item = details.items[index];
        final amountText = _fmt(item.quantityOrdered * item.unitPrice);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.ingredientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    amountText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đơn giá: ${_fmt(item.unitPrice)} / ${item.unit}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                  ),
                  Text(
                    'Đặt: ${item.quantityOrdered} ${item.unit}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              if (item.quantityDelivered != null && !isFranchiseConfirmState) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Thực nhận: ${item.quantityDelivered} ${item.unit}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
              if (isFranchiseConfirmState) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Thực nhận: ',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 90,
                      height: 38,
                      child: TextField(
                        controller: _controllers[item.ingredientId],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(item.unit, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionPanel(BuildContext context, OrderDetailModel details, String role) {
    final statusUpper = details.orderStatus.toUpperCase();
    final List<Widget> buttons = [];

    // --- FRANCHISE ACTIONS ---
    if (role != 'MANAGER' && role != 'ADMIN' && role != 'KITCHEN_STAFF' && role != 'SUPPLY_COORDINATOR') {
      if (statusUpper == 'PENDING') {
        buttons.add(
          Expanded(
            child: ElevatedButton(
              onPressed: _isActionLoading ? null : () => _showCancelDialog(context, details),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('HỦY ĐƠN HÀNG', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        );
      } else if (statusUpper == 'SHIPPED' || statusUpper == 'DELIVERING' || statusUpper == 'APPROVED') {
        buttons.add(
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Notes Input Area for Receipt
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú khi nhận hàng (nếu có)',
                    labelStyle: const TextStyle(fontSize: 12.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isActionLoading ? null : () => _confirmReceipt(context, details),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isActionLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('XÁC NHẬN NHẬN HÀNG', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      }
    }

    // --- DRIVER (SUPPLY COORDINATOR) ACTIONS ---
    if (role == 'SUPPLY_COORDINATOR') {
      if (statusUpper == 'DELIVERING' || statusUpper == 'SHIPPING' || statusUpper == 'DISPATCHED' || statusUpper == 'APPROVED') {
        buttons.add(
          Expanded(
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/map',
                      arguments: {'orderId': details.orderId},
                    );
                  },
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('MỞ BẢN ĐỒ GPS', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 10),
                Consumer<DeliveryChatProvider>(
                  builder: (context, deliveryChat, child) {
                    final loc = deliveryChat.latestLocation;
                    final hasArrived = loc != null &&
                        (loc.latitude - 10.782622).abs() < 0.001 &&
                        (loc.longitude - 106.684172).abs() < 0.001;

                    return ElevatedButton.icon(
                      onPressed: _isActionLoading
                          ? null
                          : () => _confirmArrived(context, details, hasArrived),
                      icon: const Icon(Icons.done_all_rounded),
                      label: Text(
                        hasArrived ? 'XÁC NHẬN ĐÃ ĐẾN CỬA HÀNG' : 'CHƯA TỚI CỬA HÀNG (YÊU CẦU GPS)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasArrived ? Colors.orange.shade800 : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }
    }

    // --- KITCHEN ACTIONS ---
    if (role == 'KITCHEN_STAFF') {
      if (statusUpper == 'APPROVED') {
        buttons.add(
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isActionLoading ? null : () => _dispatchOrder(context, details.orderId),
              icon: const Icon(Icons.local_shipping_rounded),
              label: const Text('XUẤT KHO GIAO HÀNG', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        );
      }
    }

    // --- MANAGER / ADMIN ACTIONS ---
    if (role == 'MANAGER' || role == 'ADMIN') {
      if (statusUpper == 'PENDING') {
        buttons.addAll([
          Expanded(
            child: OutlinedButton(
              onPressed: _isActionLoading ? null : () => _approveOrRejectManager(context, details.orderId, false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
                foregroundColor: AppTheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('TỪ CHỐI ĐƠN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isActionLoading ? null : () => _approveOrRejectManager(context, details.orderId, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('DUYỆT ĐƠN HÀNG', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ]);
      }
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.5))),
      ),
      child: Row(children: buttons),
    );
  }

  // --- ACTIONS LOGIC IMPLEMENTATIONS ---

  Future<void> _showCancelDialog(BuildContext context, OrderDetailModel details) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vui lòng nhập lý do hủy đơn hàng (tối thiểu 5 ký tự):'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do tại đây...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('HỦY BỎ'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().length >= 5) {
                Navigator.pop(ctx, true);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Lý do phải từ 5 ký tự trở lên!'), backgroundColor: Colors.amber),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('XÁC NHẬN HỦY', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isActionLoading = true);
      final success = await context.read<CartOrderProvider>().cancelOrderAsync(
            orderId: details.orderId,
            storeId: details.storeId,
            reason: reasonController.text.trim(),
          );
      setState(() => _isActionLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã hủy đơn hàng thành công!'), backgroundColor: Colors.green),
          );
          if (widget.onRefresh != null) widget.onRefresh!();
          Navigator.pop(context);
        } else {
          final errorMsg = context.read<CartOrderProvider>().errorMessage ?? 'Hủy đơn hàng thất bại.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    }
    reasonController.dispose();
  }

  Future<void> _confirmReceipt(BuildContext context, OrderDetailModel details) async {
    setState(() => _isActionLoading = true);

    final receivedItems = details.items.map((item) {
      final textVal = _controllers[item.ingredientId]?.text ?? '';
      final parsedVal = double.tryParse(textVal) ?? item.quantityOrdered;
      return {
        'ingredientId': item.ingredientId,
        'quantityDelivered': parsedVal,
      };
    }).toList();

    final success = await context.read<CartOrderProvider>().receiveOrderAsync(
          orderId: details.orderId,
          storeId: details.storeId,
          receivedItems: receivedItems,
          notes: _notesController.text.trim(),
        );

    setState(() => _isActionLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nhận hàng và cập nhật tồn kho thành công!'), backgroundColor: Colors.green),
        );
        if (widget.onRefresh != null) widget.onRefresh!();
        Navigator.pop(context);
      } else {
        final errorMsg = context.read<CartOrderProvider>().errorMessage ?? 'Xác nhận thất bại.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _confirmArrived(BuildContext context, OrderDetailModel details, bool hasArrived) async {
    if (!hasArrived) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng mở Bản đồ GPS và di chuyển xe đến cột mốc Cửa hàng (CH) trước khi xác nhận!'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() => _isActionLoading = true);
    final success = await context.read<CartOrderProvider>().arriveOrderAsync(
          orderId: details.orderId,
          storeId: details.storeId,
        );
    setState(() => _isActionLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xác nhận đã đến cửa hàng thành công!'), backgroundColor: Colors.green),
        );
        if (widget.onRefresh != null) widget.onRefresh!();
        Navigator.pop(context);
      } else {
        final errorMsg = context.read<CartOrderProvider>().errorMessage ?? 'Xác nhận thất bại.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _dispatchOrder(BuildContext context, int orderId) async {
    setState(() => _isActionLoading = true);
    final success = await context.read<InventoryProvider>().dispatchOrder(orderId);
    setState(() => _isActionLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xuất kho giao hàng thành công!'), backgroundColor: Colors.green),
        );
        if (widget.onRefresh != null) widget.onRefresh!();
        Navigator.pop(context);
      } else {
        final errorMsg = context.read<InventoryProvider>().errorMessage ?? 'Xuất kho thất bại.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _approveOrRejectManager(BuildContext context, int orderId, bool isApprove) async {
    final noteController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isApprove ? 'Duyệt đơn hàng' : 'Từ chối đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isApprove ? 'Thêm ghi chú duyệt đơn (tùy chọn):' : 'Vui lòng nhập ghi chú từ chối đơn:'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'Nhập ghi chú...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('HỦY BỎ'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isApprove || noteController.text.trim().isNotEmpty) {
                Navigator.pop(ctx, true);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Vui lòng ghi lý do từ chối!'), backgroundColor: Colors.amber),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: isApprove ? AppTheme.primary : AppTheme.error),
            child: Text(isApprove ? 'DUYỆT ĐƠN' : 'TỪ CHỐI', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isActionLoading = true);
      String? error;
      if (isApprove) {
        error = await context.read<ManagerProvider>().approveOrder(orderId, noteController.text.trim());
      } else {
        error = await context.read<ManagerProvider>().rejectOrder(orderId, noteController.text.trim());
      }
      setState(() => _isActionLoading = false);

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isApprove ? 'Đã duyệt đơn hàng thành công!' : 'Đã từ chối đơn hàng!'),
              backgroundColor: Colors.green,
            ),
          );
          if (widget.onRefresh != null) widget.onRefresh!();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppTheme.error),
          );
        }
      }
    }
    noteController.dispose();
  }
}
