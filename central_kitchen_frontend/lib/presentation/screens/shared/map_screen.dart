import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/delivery_chat_provider.dart';
import '../../../business/providers/cart_order_provider.dart';
import 'dart:ui';
import '../../../core/constants/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final auth = context.read<AuthProvider>();
      final cart = context.read<CartOrderProvider>();
      
      // Load orders to select from
      if (auth.userRole == 'KITCHEN_STAFF') {
        // Kitchen staff can view orders that need delivery
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
      _isInit = false;
    }
  }

  void _selectFirstOrder(CartOrderProvider cart) {
    if (cart.orders.isNotEmpty) {
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
    final deliveryChat = context.read<DeliveryChatProvider>();
    deliveryChat.stopLocationPolling();
    deliveryChat.stopTrackingAndSendingLocation();
    _mapController?.dispose();
    super.dispose();
  }

  // Move map camera to driver's position
  void _moveCamera(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
    );
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartOrderProvider>();
    final deliveryChat = context.watch<DeliveryChatProvider>();
    final latestLoc = deliveryChat.latestLocation;

    // Build markers
    final Set<Marker> markers = {};
    if (latestLoc != null) {
      final pos = LatLng(latestLoc.latitude, latestLoc.longitude);
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: pos,
          infoWindow: InfoWindow(
            title: 'Tài xế (${latestLoc.driverName.isNotEmpty ? latestLoc.driverName : "Vận chuyển"})',
            snippet: 'Cập nhật lúc: ${_formatTime(latestLoc.recordedAt)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      // Add destination marker (Franchise Store)
      markers.add(
        Marker(
          markerId: const MarkerId('store'),
          position: const LatLng(10.782622, 106.684172),
          infoWindow: const InfoWindow(
            title: 'Cửa hàng nhượng quyền',
            snippet: 'Điểm nhận hàng',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

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
          // 1. Google Map Fullscreen
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: latestLoc != null
                  ? LatLng(latestLoc.latitude, latestLoc.longitude)
                  : const LatLng(10.762622, 106.660172),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (latestLoc != null) {
                _moveCamera(latestLoc.latitude, latestLoc.longitude);
              }
            },
            markers: markers,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false, // Cleaner UI
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

          // 3. Fallback coordinates display
          if (latestLoc != null)
            Positioned(
              top: 90,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tài xế: ${latestLoc.driverName.isNotEmpty ? latestLoc.driverName : "N/A"}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                              ),
                              Text(
                                'Cập nhật: ${_formatTime(latestLoc.recordedAt)}',
                                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
                              ),
                            ],
                          ),
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
                    color: Colors.white.withOpacity(0.9),
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

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--:--';
    final localDt = dt.toLocal();
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
    final second = localDt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
