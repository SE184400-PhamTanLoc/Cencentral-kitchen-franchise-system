import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/manager_provider.dart';
import '../../../business/providers/cart_order_provider.dart';
import '../../../core/constants/app_theme.dart';
import 'package:intl/intl.dart';

class CoordinatorDashboardScreen extends StatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  State<CoordinatorDashboardScreen> createState() => _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState extends State<CoordinatorDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().loadDashboardData();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final manager = context.watch<ManagerProvider>();
    final userName = auth.currentUser?.fullName ?? 'Điều phối viên';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Gradient Bubbles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primary.withOpacity(0.25), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.secondary.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: () => manager.loadDashboardData(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(userName, auth),
                          const SizedBox(height: 16),
                          _buildStatsRow(manager),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Công cụ điều phối'),
                          const SizedBox(height: 12),
                          _buildActionGrid(context),
                          const SizedBox(height: 28),
                          _buildSearchAndFilters(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    _buildOrdersList(manager),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(child: _buildFooter()),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Premium Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào buổi sáng,',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Điều phối viên vận hành',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
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
          // Logout Button
          InkWell(
            onTap: () async {
              await auth.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
                ],
                border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
              ),
              child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 22),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildStatsRow(ManagerProvider manager) {
    int dispatchedCount = 0;
    int approvedCount = 0;
    if (manager.stats != null) {
      dispatchedCount = manager.stats!.dispatchedOrders;
      approvedCount = manager.stats!.approvedOrders;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'ĐANG VẬN CHUYỂN',
              value: '$dispatchedCount',
              icon: Icons.local_shipping_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              textColor: const Color(0xFF0369A1),
              iconColor: const Color(0xFF0284C7),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildStatCard(
              title: 'ĐÃ DUYỆT (CHỜ GIAO)',
              value: '$approvedCount',
              icon: Icons.inventory_2_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              textColor: const Color(0xFFB45309),
              iconColor: const Color(0xFFD97706),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.1,
                ),
              ),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withOpacity(0.85),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              context: context,
              title: 'Bản đồ GPS',
              subtitle: 'Định vị tài xế',
              icon: Icons.map_rounded,
              gradientColors: [const Color(0xFF1E3A8A), const Color(0xFF1D4ED8)],
              route: '/map',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              context: context,
              title: 'Kênh Chat',
              subtitle: 'Hỗ trợ nội bộ',
              icon: Icons.chat_bubble_rounded,
              gradientColors: [const Color(0xFF0F766E), const Color(0xFF0D9488)],
              route: '/chat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.4)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo mã đơn hoặc tên cửa hàng...',
                hintStyle: TextStyle(color: AppTheme.outline.withOpacity(0.6), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Custom Filter Chips
          Row(
            children: [
              _buildFilterChip('Tất cả'),
              const SizedBox(width: 8),
              _buildFilterChip('Chờ giao'),
              const SizedBox(width: 8),
              _buildFilterChip('Đang giao'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedStatusFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatusFilter = label;
          });
        }
      },
      selectedColor: AppTheme.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppTheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      showCheckmark: false,
      elevation: isSelected ? 3 : 0,
    );
  }

  Widget _buildOrdersList(ManagerProvider manager) {
    if (manager.isLoadingOrders) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        ),
      );
    }

    // Filter to show only Dispatched and Approved
    var deliveryOrders = manager.pendingOrders.where((o) => o.orderStatus == 'Dispatched' || o.orderStatus == 'Approved').toList();

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      deliveryOrders = deliveryOrders.where((o) =>
          o.orderCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.storeName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply Filter
    if (_selectedStatusFilter == 'Chờ giao') {
      deliveryOrders = deliveryOrders.where((o) => o.orderStatus == 'Approved').toList();
    } else if (_selectedStatusFilter == 'Đang giao') {
      deliveryOrders = deliveryOrders.where((o) => o.orderStatus == 'Dispatched').toList();
    }

    if (deliveryOrders.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.outline.withOpacity(0.5)),
                const SizedBox(height: 12),
                const Text(
                  'Không tìm thấy đơn hàng nào.',
                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final order = deliveryOrders[index];
            final isDispatched = order.orderStatus == 'Dispatched';

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.35)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    _showOrderDetailsModal(context, order);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Code + Status Chip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDispatched
                                    ? const Color(0xFFE0F2FE)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isDispatched) ...[
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0284C7),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                  Text(
                                    isDispatched ? 'ĐANG GIAO' : 'CHỜ GIAO',
                                    style: TextStyle(
                                      color: isDispatched
                                          ? const Color(0xFF0369A1)
                                          : const Color(0xFFB45309),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Store info
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.storefront_rounded, size: 16, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                order.storeName.isNotEmpty ? order.storeName : 'Cửa hàng #${order.storeId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Date and Time
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.onSurfaceVariant.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.onSurfaceVariant),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('dd/MM/yyyy - HH:mm').format(order.orderDate.toLocal()),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Bottom row: Value + CTA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${NumberFormat('#,###').format(order.totalAmount)} ₫',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Xem chi tiết',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondary.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.secondary.withOpacity(0.9)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: deliveryOrders.length,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hệ Thống Bếp Trung Tâm • Vận Hành Giao Hàng',
            style: TextStyle(fontSize: 11, color: AppTheme.outline, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsModal(BuildContext context, dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _OrderDetailsModal(order: order);
      },
    );
  }
}

class _OrderDetailsModal extends StatefulWidget {
  final dynamic order;
  const _OrderDetailsModal({required this.order});

  @override
  State<_OrderDetailsModal> createState() => _OrderDetailsModalState();
}

class _OrderDetailsModalState extends State<_OrderDetailsModal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartOrderProvider>().loadOrderDetailAsync(widget.order.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartOrderProvider>();
    final isDispatched = widget.order.orderStatus == 'Dispatched';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.outlineVariant.withOpacity(0.8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CHI TIẾT VẬN ĐƠN',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.outline, letterSpacing: 1),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.order.orderCode,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDispatched
                        ? const Color(0xFFE0F2FE)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDispatched ? 'ĐANG GIAO' : 'CHỜ GIAO',
                    style: TextStyle(
                      color: isDispatched
                          ? const Color(0xFF0369A1)
                          : const Color(0xFFB45309),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content Area
          Expanded(
            child: cart.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : cart.selectedOrder == null
                    ? const Center(child: Text('Không thể tải chi tiết đơn hàng.'))
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // Step Progress Timeline
                          _buildTimeline(isDispatched),
                          const SizedBox(height: 24),

                          // Store Info Card
                          _buildStoreInfoCard(),
                          const SizedBox(height: 24),

                          // Items List Title
                          const Row(
                            children: [
                              Icon(Icons.inventory_2_rounded, color: AppTheme.primary, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Danh sách nguyên liệu (BOM)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Items List
                          ...cart.selectedOrder!.items.map((item) => _buildItemTile(item)),
                          const SizedBox(height: 20),

                          // Price Invoice Summary Card
                          _buildSummaryCard(),
                          const SizedBox(height: 12),
                        ],
                      ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Đóng'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.8)),
                      foregroundColor: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close modal
                      Navigator.pushNamed(context, '/map', arguments: {'orderId': widget.order.orderId}); // Open map
                    },
                    icon: const Icon(Icons.gps_fixed_rounded, size: 18),
                    label: const Text('MỞ BẢN ĐỒ GPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppTheme.primary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _buildTimeline(bool isDispatched) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          _buildTimelineStep('Khởi tạo', true, true),
          _buildLine(true),
          _buildTimelineStep('Đã duyệt', true, true),
          _buildLine(isDispatched),
          _buildTimelineStep('Đang giao', isDispatched, false),
          _buildLine(false),
          _buildTimelineStep('Đã nhận', false, false),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isDone, bool showCheck) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDone ? AppTheme.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? AppTheme.primary : AppTheme.outlineVariant,
                width: 2,
              ),
            ),
            child: Icon(
              showCheck ? Icons.check : Icons.circle,
              size: showCheck ? 12 : 6,
              color: isDone ? Colors.white : AppTheme.outlineVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              color: isDone ? AppTheme.primary : AppTheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(bool active) {
    return Container(
      width: 24,
      height: 2,
      color: active ? AppTheme.primary : AppTheme.outlineVariant,
    );
  }

  Widget _buildStoreInfoCard() {
    // Generate static mockup address & phone based on storeId to look premium
    final storePhone = '098${(widget.order.storeId * 317) % 900 + 100} 789';
    final storeAddress = 'Khu đô thị FPT, Ngũ Hành Sơn, Đà Nẵng (Cửa hàng #${widget.order.storeId})';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
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
                  color: AppTheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store_rounded, color: AppTheme.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.storeName.isNotEmpty ? widget.order.storeName : 'Cửa hàng số ${widget.order.storeId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SĐT: $storePhone',
                      style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, color: AppTheme.outline, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  storeAddress,
                  style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant, height: 1.3),
                ),
              ),
            ],
          ),
          if (widget.order.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sticky_note_2_rounded, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ghi chú: ${widget.order.notes}',
                    style: const TextStyle(fontSize: 13, color: Colors.orange, fontStyle: FontStyle.italic, height: 1.3),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemTile(dynamic item) {
    final subtotalFormatted = '${NumberFormat('#,###').format(item.subtotal)} ₫';
    final priceFormatted = '${NumberFormat('#,###').format(item.unitPrice)} ₫';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_rounded, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.ingredientName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.onSurface),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.quantityDelivered ?? item.quantityOrdered} ${item.unit} × $priceFormatted',
                  style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            subtotalFormatted,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final amountFormatted = '${NumberFormat('#,###').format(widget.order.totalAmount)} ₫';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng giá trị hàng:', style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
              Text(amountFormatted, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Thuế VAT (0%):', style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
              Text('0 ₫', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phí vận chuyển:', style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
              Text('Miễn phí', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TỔNG THÀNH TIỀN:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              Text(
                amountFormatted,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
