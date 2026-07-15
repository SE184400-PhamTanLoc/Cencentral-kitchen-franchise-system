import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/manager_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/manager_stats_model.dart';
import '../../widgets/unified_order_card.dart';
import '../../widgets/shared_order_details_modal.dart';
import '../shared/chat_screen.dart';

String _avatarInitial(String? name) {
  if (name == null || name.isEmpty) return '?';
  return name.substring(0, 1).toUpperCase();
}

class CoordinatorDashboardScreen extends StatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  State<CoordinatorDashboardScreen> createState() =>
      _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState extends State<CoordinatorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'Tất cả';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCoordinatorData();
    });
  }

  Future<void> _loadCoordinatorData() async {
    final manager = context.read<ManagerProvider>();
    await Future.wait([
      manager.loadDashboardData(),
      manager.loadOrderHistory(),
    ]);
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
                  title: Text(auth.currentUser?.fullName ?? 'Điều phối viên'),
                  subtitle: Text(auth.currentUser?.roleName ?? 'Coordinator'),
                ),
                const SizedBox(height: 8),
                _MenuTile(
                  icon: Icons.map_rounded,
                  title: 'Bản đồ & Định vị',
                  subtitle: 'Giám sát tài xế giao hàng',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).pushNamed('/map');
                  },
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Nhắn tin nội bộ',
                  subtitle: 'Trao đổi với bếp và cửa hàng',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _selectedIndex = 1);
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
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final manager = context.watch<ManagerProvider>();

    final List<Widget> pages = [
      FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _loadCoordinatorData,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildStatsRow(manager),
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
      const ChatScreen(showBackButton: false),
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
              'Xin chào, ${auth.currentUser?.fullName ?? 'Điều phối viên'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Điều phối giao hàng & vận hành',
              style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _loadCoordinatorData,
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
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.outlineVariant, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_rounded),
              label: 'Giám sát giao hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Kênh Chat',
            ),
          ],
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
              accentColor: AppTheme.secondary,
              statusBgColor: const Color(0xFFEFF6FF),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildStatCard(
              title: 'ĐÃ DUYỆT (CHỜ GIAO)',
              value: '$approvedCount',
              icon: Icons.inventory_2_rounded,
              accentColor: AppTheme.warning,
              statusBgColor: const Color(0xFFFFFBEB),
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
    required Color accentColor,
    required Color statusBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Search Bar (Inputs/Text fields use crisp 8px corner rounding)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo mã đơn hoặc tên cửa hàng...',
                hintStyle: TextStyle(
                  color: AppTheme.outline.withOpacity(0.6),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
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
              const SizedBox(width: 8),
              _buildFilterChip('Đã giao'),
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
      selectedColor: AppTheme.primary.withOpacity(0.08),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : const Color(0xFFE2E8F0),
        ),
      ),
      showCheckmark: false,
      elevation: 0,
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

    final combinedOrders = <int, ManagerPendingOrderModel>{};
    for (final order in manager.pendingOrders) {
      combinedOrders[order.orderId] = order;
    }
    for (final order in manager.orderHistory) {
      combinedOrders[order.orderId] = order;
    }

    // Coordinator sees both active deliveries and delivered history.
    var deliveryOrders =
        combinedOrders.values.where((o) {
          final status = o.orderStatus.toUpperCase();
          return status == 'APPROVED' ||
              status == 'DELIVERING' ||
              status == 'SHIPPING' ||
              status == 'DISPATCHED' ||
              status == 'SHIPPED' ||
              status == 'DELIVERED';
        }).toList()..sort((a, b) {
          final aTime = a.updatedAt ?? a.createdAt;
          final bTime = b.updatedAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      deliveryOrders = deliveryOrders
          .where(
            (o) =>
                o.orderCode.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                o.storeName.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply Filter
    if (_selectedStatusFilter == 'Chờ giao') {
      deliveryOrders = deliveryOrders
          .where((o) => o.orderStatus.toUpperCase() == 'APPROVED')
          .toList();
    } else if (_selectedStatusFilter == 'Đang giao') {
      deliveryOrders = deliveryOrders.where((o) {
        final status = o.orderStatus.toUpperCase();
        return status == 'DELIVERING' ||
            status == 'SHIPPING' ||
            status == 'DISPATCHED' ||
            status == 'SHIPPED';
      }).toList();
    } else if (_selectedStatusFilter == 'Đã giao') {
      deliveryOrders = deliveryOrders
          .where((o) => o.orderStatus.toUpperCase() == 'DELIVERED')
          .toList();
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
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppTheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Không tìm thấy đơn hàng nào.',
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
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
        delegate: SliverChildBuilderDelegate((context, index) {
          final order = deliveryOrders[index];
          return UnifiedOrderCard(
            orderId: order.orderId,
            orderCode: order.orderCode,
            storeName: order.storeName,
            orderStatus: order.orderStatus,
            createdAt: order.orderDate,
            totalAmount: order.totalAmount,
            itemCount: 0,
            onTap: () {
              _showOrderDetailsModal(context, order);
            },
          );
        }, childCount: deliveryOrders.length),
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
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsModal(BuildContext context, dynamic order) {
    SharedOrderDetailsModal.show(
      context,
      orderId: order.orderId,
      orderCode: order.orderCode,
      orderStatus: order.orderStatus,
      onRefresh: () {
        _loadCoordinatorData();
      },
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
    final color = danger ? AppTheme.error : AppTheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
