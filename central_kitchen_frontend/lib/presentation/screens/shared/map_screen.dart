import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/delivery_chat_provider.dart';
import '../../../business/providers/cart_order_provider.dart';
import '../../../data/models/order_model.dart';
import 'dart:ui';

import '../../../core/constants/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  int? _selectedOrderId;
  bool _isTracking = false;
  bool _isInit = true;

  // Mock routes coordinates for testing (Kitchen -> Store)
  final List<LatLng> _mockRoute = const [
    LatLng(10.762622, 106.660172), // Central Kitchen (Start)
    LatLng(10.767622, 106.666172), // Step 1
    LatLng(10.772622, 106.672172), // Step 2
    LatLng(10.777622, 106.678172), // Step 3
    LatLng(10.782622, 106.684172), // Franchise Store (End)
  ];
  int _currentMockStep = 0;

  late DeliveryChatProvider _deliveryChatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Save reference for dispose
    _deliveryChatProvider = context.read<DeliveryChatProvider>();

    if (_isInit) {
      final auth = context.read<AuthProvider>();
      final cart = context.read<CartOrderProvider>();
      
      // Lấy tham số truyền vào (nếu có)
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final int? initialOrderId = args?['orderId'];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (initialOrderId != null) {
          // Nếu được truyền sẵn orderId từ Dashboard (Delivery)
          setState(() {
            _selectedOrderId = initialOrderId;
          });
          // Tải danh sách đơn hàng cho store 1 (fallback) hoặc storeId liên quan
          // Ở đây tạm dùng storeId=1 nếu không có để fill dropdown (hoặc có thể để trống)
          cart.loadOrdersAsync(1).then((_) {
            _startMonitoring();
          });
        } else {
          // Load orders to select from
          if (auth.userRole == 'KITCHEN_STAFF' || auth.userRole == 'SUPPLY_COORDINATOR') {
            cart.loadOrdersAsync(1).then((_) {
              _selectFirstOrder(cart);
            });
          } else {
            // Store staff
            final storeId = auth.storeId ?? 1;
            cart.loadOrdersAsync(storeId).then((_) {
              _selectFirstOrder(cart);
            });
          }
        }
      });
      _isInit = false;
    }
  }

  void _selectFirstOrder(CartOrderProvider cart) {
    if (cart.orders.isNotEmpty && mounted) {
      setState(() {
        _selectedOrderId = cart.orders.first.orderId;
      });
      _startMonitoring();
    }
  }

  void _startMonitoring() {
    if (_selectedOrderId == null) return;
    final deliveryChat = context.read<DeliveryChatProvider>();
    deliveryChat.loadLatestLocationAsync(_selectedOrderId!);
    deliveryChat.startLocationPolling(_selectedOrderId!);
  }

  @override
  void dispose() {
    _deliveryChatProvider.stopLocationPolling();
    _deliveryChatProvider.stopTrackingAndSendingLocation();
    _mapController.dispose();
    super.dispose();
  }

  // Move map camera to driver's position
  void _moveCamera(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 15.0);
  }

  Future<void> _startGpsTracking() async {
    final auth = context.read<AuthProvider>();
    final deliveryChat = context.read<DeliveryChatProvider>();
    final driverId = auth.currentUser?.userId;

    if (_selectedOrderId == null || driverId == null) return;

    setState(() {
      _isTracking = true;
    });

    await deliveryChat.startTrackingAndSendingLocation(
      orderId: _selectedOrderId!,
      driverId: driverId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang cập nhật vị trí GPS thực tế...')),
    );
  }

  void _stopGpsTracking() {
    final deliveryChat = context.read<DeliveryChatProvider>();
    deliveryChat.stopTrackingAndSendingLocation();
    setState(() {
      _isTracking = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã dừng cập nhật vị trí GPS.')),
    );
  }

  Future<void> _sendMockStep(int stepIndex) async {
    final auth = context.read<AuthProvider>();
    final deliveryChat = context.read<DeliveryChatProvider>();
    final driverId = auth.currentUser?.userId ?? 1;

    if (_selectedOrderId == null) return;

    final targetCoords = _mockRoute[stepIndex];
    setState(() {
      _currentMockStep = stepIndex;
    });

    await deliveryChat.sendLocationManually(
      orderId: _selectedOrderId!,
      driverId: driverId,
      latitude: targetCoords.latitude,
      longitude: targetCoords.longitude,
    );

    _moveCamera(targetCoords.latitude, targetCoords.longitude);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Giả lập vị trí: Bước ${stepIndex + 1}/${_mockRoute.length}')),
    );
  }

  // Cấu hình màu sắc & nhãn trạng thái đơn hàng (giống Grab/Shopee)
  static const Map<String, ({Color color, IconData icon, String label})> _statusConfig = {
    'PENDING': (color: Color(0xFFF59E0B), icon: Icons.hourglass_top_rounded, label: 'Chờ duyệt'),
    'APPROVED': (color: Color(0xFF0058BE), icon: Icons.check_circle_outline_rounded, label: 'Đã duyệt'),
    'DISPATCHED': (color: Color(0xFF0058BE), icon: Icons.local_shipping_rounded, label: 'Đang giao'),
    'DELIVERING': (color: Color(0xFF0058BE), icon: Icons.local_shipping_rounded, label: 'Đang giao'),
    'SHIPPING': (color: Color(0xFF0058BE), icon: Icons.local_shipping_rounded, label: 'Đang giao'),
    'SHIPPED': (color: Color(0xFF047857), icon: Icons.done_all_rounded, label: 'Đã tới nơi'),
    'COMPLETED': (color: Color(0xFF10B981), icon: Icons.task_alt_rounded, label: 'Đã nhận'),
    'DELIVERED': (color: Color(0xFF10B981), icon: Icons.task_alt_rounded, label: 'Đã nhận'),
    'CANCELLED': (color: Color(0xFFEF4444), icon: Icons.cancel_rounded, label: 'Đã hủy'),
  };

  ({Color color, IconData icon, String label}) _statusInfo(String status) {
    return _statusConfig[status.toUpperCase()] ??
        (color: AppTheme.onSurfaceVariant, icon: Icons.info_outline_rounded, label: status);
  }

  /// Sinh địa chỉ người nhận hiển thị (đơn hàng không kèm address nên dùng tên cửa hàng).
  String _recipientAddress(OrderSummaryModel? order) {
    if (order == null) return 'Chưa chọn đơn hàng';
    final name = order.storeName.isNotEmpty ? order.storeName : 'Cửa hàng #${order.storeId}';
    return '$name (Mã CH #${order.storeId})';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartOrderProvider>();
    final deliveryChat = context.watch<DeliveryChatProvider>();
    final latestLoc = deliveryChat.latestLocation;

    // Tìm đơn hàng đang được chọn để lấy trạng thái & địa chỉ người nhận
    OrderSummaryModel? selectedOrder;
    for (final o in cart.orders) {
      if (o.orderId == _selectedOrderId) {
        selectedOrder = o;
        break;
      }
    }
    final statusInfo = _statusInfo(selectedOrder?.orderStatus ?? 'PENDING');
    final statusUpper = selectedOrder?.orderStatus.toUpperCase() ?? '';
    final isDelivering = statusUpper == 'DELIVERING' || statusUpper == 'SHIPPING' || statusUpper == 'DISPATCHED';
    final isDriver = auth.userRole == 'SUPPLY_COORDINATOR' || auth.userRole == 'KITCHEN_STAFF' || auth.userRole == 'MANAGER' || auth.userRole == 'ADMIN';
    final hasArrived = (_currentMockStep == _mockRoute.length - 1) ||
        (latestLoc != null &&
            (latestLoc.latitude - _mockRoute.last.latitude).abs() < 0.001 &&
            (latestLoc.longitude - _mockRoute.last.longitude).abs() < 0.001);


    // Build markers for flutter_map
    final List<Marker> mapMarkers = [];
    if (latestLoc != null) {
      final pos = LatLng(latestLoc.latitude, latestLoc.longitude);
      mapMarkers.add(
        Marker(
          point: pos,
          width: 120,
          height: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Text(
                  latestLoc.driverName.isNotEmpty ? latestLoc.driverName : 'Tài xế',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.local_shipping_rounded, color: Colors.blue, size: 36),
            ],
          ),
        ),
      );
    }

    // Add destination marker (Franchise Store)
    mapMarkers.add(
      Marker(
        point: const LatLng(10.782622, 106.684172),
        width: 120,
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: const Text(
                'Cửa hàng',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.storefront_rounded, color: Colors.red, size: 36),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bản đồ & Định vị',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Vai trò: ${auth.userRole ?? "N/A"} - Giám sát vị trí giao hàng',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. FlutterMap OpenStreetMap Fullscreen
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: latestLoc != null
                  ? LatLng(latestLoc.latitude, latestLoc.longitude)
                  : const LatLng(10.762622, 106.660172),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.central_kitchen_frontend',
              ),
              PolylineLayer(
                polylines: <Polyline<Object>>[
                  Polyline<Object>(
                    points: _mockRoute,
                    color: Colors.blue.withOpacity(0.5),
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: mapMarkers,
              ),
            ],
          ),

          // 2. Order Selector Overlay (Top)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: cart.orders.isEmpty
                            ? const Text('Chưa có đơn hàng nào', style: TextStyle(fontWeight: FontWeight.w600))
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
                                  value: _selectedOrderId,
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.onSurface, fontSize: 15),
                                  items: cart.orders.map((order) {
                                    return DropdownMenuItem<int>(
                                      value: order.orderId,
                                      child: Text('${order.orderCode} - ${order.orderStatus}'),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedOrderId = val;
                                        _currentMockStep = 0;
                                      });
                                      _startMonitoring();
                                    }
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Thẻ thông tin đơn hàng (Trạng thái - Người nhận - Vị trí xe)
          Positioned(
            top: 86,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng 1: Trạng thái đơn hàng (chip màu)
                      Row(
                        children: [
                          const Text(
                            'Trạng thái đơn:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusInfo.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusInfo.icon, size: 14, color: statusInfo.color),
                                const SizedBox(width: 4),
                                Text(
                                  statusInfo.label,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusInfo.color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      // Hàng 2: Địa chỉ người nhận
                      _buildInfoRow(
                        icon: Icons.storefront_rounded,
                        iconColor: const Color(0xFFEF4444),
                        title: 'Người nhận',
                        content: _recipientAddress(selectedOrder),
                      ),
                      const SizedBox(height: 10),
                      // Hàng 3: Vị trí hiện tại của xe giao hàng
                      _buildInfoRow(
                        icon: Icons.local_shipping_rounded,
                        iconColor: AppTheme.secondary,
                        title: 'Vị trí xe hiện tại',
                        content: latestLoc != null
                            ? '${latestLoc.latitude.toStringAsFixed(5)}, ${latestLoc.longitude.toStringAsFixed(5)}'
                                '  •  ${_formatTime(latestLoc.recordedAt)}'
                            : 'Chưa có dữ liệu GPS',
                        subtitle: latestLoc != null && latestLoc.driverName.isNotEmpty
                            ? 'Tài xế: ${latestLoc.driverName}'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),


          // 4. Loader Overlay
          if (deliveryChat.isLocationLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              ),
            ),
            
          // 5. Simulation / Driver Controller Panel (Floating Bottom)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 15))
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.settings_remote_rounded, color: AppTheme.primary, size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ĐIỀU PHỐI & GIẢ LẬP GPS',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.primary, letterSpacing: 1.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Real GPS update buttons
                      ElevatedButton.icon(
                        onPressed: _isTracking ? _stopGpsTracking : _startGpsTracking,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: _isTracking ? AppTheme.error : AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        icon: Icon(_isTracking ? Icons.gps_off_rounded : Icons.gps_fixed_rounded, color: Colors.white),
                        label: Text(_isTracking ? 'DỪNG PHÁT GPS' : 'PHÁT GPS THỰC TẾ', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                      if (isDriver && isDelivering) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: cart.isLoading
                              ? null
                              : () async {
                                  if (!hasArrived) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Vui lòng di chuyển xe đến cột mốc Cửa hàng (CH) trên bản đồ trước khi xác nhận!'),
                                        backgroundColor: Colors.amber,
                                      ),
                                    );
                                    return;
                                  }
                                  final success = await cart.arriveOrderAsync(
                                    orderId: _selectedOrderId!,
                                    storeId: selectedOrder!.storeId,
                                  );
                                  if (mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Xác nhận giao hàng tới nơi thành công! Trạng thái: SHIPPED.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(cart.errorMessage ?? 'Cập nhật thất bại.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: hasArrived ? Colors.orange.shade800 : Colors.grey.shade500,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          icon: Icon(hasArrived ? Icons.done_all_rounded : Icons.location_off_rounded, color: Colors.white),
                          label: Text(
                            hasArrived ? 'XÁC NHẬN ĐÃ ĐẾN CỬA HÀNG' : 'VUI LÒNG DI CHUYỂN TỚI CỬA HÀNG',
                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Manual Step-by-Step simulator
                      Text(
                        'Cột mốc lộ trình (Dành cho Tester):',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_mockRoute.length, (index) {
                            final isCurrent = latestLoc != null &&
                                latestLoc.latitude == _mockRoute[index].latitude &&
                                latestLoc.longitude == _mockRoute[index].longitude;
                            
                            String stepName = 'B ${index + 1}';
                            if (index == 0) stepName = 'Bếp';
                            if (index == _mockRoute.length - 1) stepName = 'CH';

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: ChoiceChip(
                                  label: Text(stepName),
                                  selected: isCurrent || _currentMockStep == index,
                                  onSelected: (_) => _sendMockStep(index),
                                  selectedColor: AppTheme.primary,
                                  backgroundColor: AppTheme.surfaceContainerLowest,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  showCheckmark: false,
                                  labelStyle: TextStyle(
                                    color: (isCurrent || _currentMockStep == index) ? Colors.white : AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị một dòng thông tin (icon + tiêu đề + nội dung).
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.onSurface),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant.withOpacity(0.8)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? dt) {

    if (dt == null) return '--:--:--';
    final localDt = dt.toLocal();
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
    final second = localDt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
