import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../business/providers/manager_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/manager_stats_model.dart';
import '../../widgets/shared_order_details_modal.dart';
import '../../widgets/unified_order_card.dart';

class ManagerOrderHistoryScreen extends StatefulWidget {
  const ManagerOrderHistoryScreen({super.key});

  @override
  State<ManagerOrderHistoryScreen> createState() =>
      _ManagerOrderHistoryScreenState();
}

class _ManagerOrderHistoryScreenState extends State<ManagerOrderHistoryScreen> {
  static const List<_HistoryFilter> _filters = [
    _HistoryFilter(label: 'Tất cả', value: 'ALL'),
    _HistoryFilter(label: 'Đã duyệt', value: 'APPROVED'),
    _HistoryFilter(label: 'Đã từ chối', value: 'REJECTED'),
    _HistoryFilter(label: 'Đang giao', value: 'DELIVERING'),
    _HistoryFilter(label: 'Đã tới nơi', value: 'SHIPPED'),
    _HistoryFilter(label: 'Đã nhận', value: 'DELIVERED'),
    _HistoryFilter(label: 'Đã hủy', value: 'CANCELLED'),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'ALL';
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().loadOrderHistory();
    });
    _searchController.addListener(() {
      setState(() => _searchTerm = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await context.read<ManagerProvider>().loadOrderHistory(
      status: _selectedStatus == 'ALL' ? null : _selectedStatus,
    );
  }

  Future<void> _changeStatus(String status) async {
    setState(() => _selectedStatus = status);
    await context.read<ManagerProvider>().loadOrderHistory(
      status: status == 'ALL' ? null : status,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Lịch sử duyệt đơn',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.primary),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, child) {
          final filteredOrders = provider.orderHistory.where((order) {
            if (_searchTerm.isEmpty) return true;
            return order.orderCode.toLowerCase().contains(_searchTerm) ||
                order.storeName.toLowerCase().contains(_searchTerm);
          }).toList();

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildHeroSummary(provider.orderHistory, formatCurrency),
                const SizedBox(height: 16),
                _buildSearchBox(),
                const SizedBox(height: 12),
                _buildStatusFilters(provider),
                const SizedBox(height: 16),
                if (provider.isLoadingHistory && provider.orderHistory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else if (provider.errorMessage != null &&
                    provider.orderHistory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'Không tải được lịch sử đơn.\n${provider.errorMessage}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else if (filteredOrders.isEmpty)
                  _buildEmptyState()
                else
                  ...filteredOrders.map(
                    (order) => UnifiedOrderCard(
                      orderId: order.orderId,
                      orderCode: order.orderCode,
                      storeName: order.storeName,
                      orderStatus: order.orderStatus,
                      createdAt: order.updatedAt ?? order.createdAt,
                      totalAmount: order.totalAmount,
                      itemCount: order.itemCount,
                      onTap: () {
                        SharedOrderDetailsModal.show(
                          context,
                          orderId: order.orderId,
                          orderCode: order.orderCode,
                          orderStatus: order.orderStatus,
                          onRefresh: _reload,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSummary(
    List<ManagerPendingOrderModel> orders,
    NumberFormat formatCurrency,
  ) {
    final totalOrders = orders.length;
    final approvedOrDone = orders
        .where(
          (o) => const [
            'APPROVED',
            'SHIPPED',
            'DELIVERED',
          ].contains(o.orderStatus.toUpperCase()),
        )
        .length;
    final totalValue = orders.fold<double>(
      0,
      (sum, item) => sum + item.totalAmount,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2D6B), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theo dõi toàn bộ đơn đã qua bước duyệt',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Lịch sử xử lý đơn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _buildMetricTile('Tổng đơn', '$totalOrders')),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile('Đã duyệt/hoàn tất', '$approvedOrDone'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Tổng giá trị',
                  formatCurrency.format(totalValue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Tìm theo mã đơn hoặc cửa hàng',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchTerm.isEmpty
            ? null
            : IconButton(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStatusFilters(ManagerProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filters.map((filter) {
        final isSelected = filter.value == _selectedStatus;
        return ChoiceChip(
          label: Text(filter.label),
          selected: isSelected,
          onSelected: provider.isLoadingHistory
              ? null
              : (_) => _changeStatus(filter.value),
          selectedColor: const Color(0xFFDCEAFE),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primary : const Color(0xFF475569),
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : const Color(0xFFE2E8F0),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 12),
          Text(
            'Chưa có đơn phù hợp với bộ lọc hiện tại.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Thử đổi trạng thái hoặc từ khóa tìm kiếm để xem thêm lịch sử.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _HistoryFilter {
  final String label;
  final String value;

  const _HistoryFilter({required this.label, required this.value});
}
