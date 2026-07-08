import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/datasources/delivery_chat_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/delivery_log_model.dart';

class DeliveryChatProvider with ChangeNotifier {
  final DeliveryChatDatasource _datasource;

  DeliveryChatProvider(this._datasource);

  // Chat State
  List<ChatMessageModel> _messages = [];
  bool _isChatLoading = false;
  Timer? _chatTimer;
  List<Map<String, dynamic>> _storesList = [];
  List<Map<String, dynamic>> _kitchensList = [];

  List<ChatMessageModel> get messages => _messages;
  bool get isChatLoading => _isChatLoading;
  List<Map<String, dynamic>> get storesList => _storesList;
  List<Map<String, dynamic>> get kitchensList => _kitchensList;

  Future<void> fetchStoresAndKitchens() async {
    try {
      _storesList = await _datasource.getStores();
      _kitchensList = await _datasource.getKitchens();
      notifyListeners();
    } catch (_) {}
  }

  // Delivery State
  DeliveryLogModel? _latestLocation;
  bool _isLocationLoading = false;
  bool _isRouteLoading = false;
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionSubscription;
  List<LatLng> _activeRoute = [];

  DeliveryLogModel? get latestLocation => _latestLocation;
  bool get isLocationLoading => _isLocationLoading;
  bool get isRouteLoading => _isRouteLoading;
  List<LatLng> get activeRoute => List.unmodifiable(_activeRoute);

  // ─── Chat Actions ─────────────────────────────────────────────

  Future<void> loadConversationAsync(int? storeId, int? kitchenId) async {
    _isChatLoading = true;
    notifyListeners();
    try {
      _messages = await _datasource.getConversation(storeId, kitchenId);
    } catch (_) {}
    _isChatLoading = false;
    notifyListeners();
  }

  Future<void> sendMessageAsync({
    required int senderId,
    int? storeId,
    int? kitchenId,
    required String messageText,
  }) async {
    try {
      final newMsg = await _datasource.sendMessage(
        senderId: senderId,
        storeId: storeId,
        kitchenId: kitchenId,
        messageText: messageText,
      );
      _messages.add(newMsg);
      notifyListeners();
    } catch (_) {}
  }

  void startChatPolling(int? storeId, int? kitchenId) {
    _chatTimer?.cancel();
    _chatTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        _messages = await _datasource.getConversation(storeId, kitchenId);
        notifyListeners();
      } catch (_) {}
    });
  }

  void stopChatPolling() {
    _chatTimer?.cancel();
    _chatTimer = null;
  }

  // ─── Location Actions ──────────────────────────────────────────

  Future<void> loadLatestLocationAsync(int orderId) async {
    _isLocationLoading = true;
    notifyListeners();
    try {
      _latestLocation = await _datasource.getLatestLocation(orderId);
    } catch (_) {}
    _isLocationLoading = false;
    notifyListeners();
  }

  void startLocationPolling(int orderId) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final loc = await _datasource.getLatestLocation(orderId);
        if (loc != null) {
          _latestLocation = loc;
          notifyListeners();
        }
      } catch (_) {}
    });
  }

  Future<void> resolveRouteAsync({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    _isRouteLoading = true;
    notifyListeners();
    try {
      final route = await _datasource.getDrivingRoute(
        originLatitude: originLatitude,
        originLongitude: originLongitude,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
      );
      _activeRoute = route;
    } catch (_) {
      _activeRoute = [];
    }
    _isRouteLoading = false;
    notifyListeners();
  }

  void clearRoute() {
    _activeRoute = [];
    _isRouteLoading = false;
    notifyListeners();
  }

  void stopLocationPolling() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  // Driver sending GPS location
  Future<void> startTrackingAndSendingLocation({
    required int orderId,
    required int driverId,
  }) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // update every 10 meters
          ),
        ).listen((Position position) async {
          try {
            final newLoc = await _datasource.updateLocation(
              orderId: orderId,
              driverId: driverId,
              latitude: position.latitude,
              longitude: position.longitude,
            );
            _latestLocation = newLoc;
            notifyListeners();
          } catch (_) {}
        });
  }

  // Manual trigger for mock/test GPS updates on emulator if geolocator stream isn't triggered
  Future<void> sendLocationManually({
    required int orderId,
    required int driverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final newLoc = await _datasource.updateLocation(
        orderId: orderId,
        driverId: driverId,
        latitude: latitude,
        longitude: longitude,
      );
      _latestLocation = newLoc;
      notifyListeners();
    } catch (_) {}
  }

  void stopTrackingAndSendingLocation() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void dispose() {
    stopChatPolling();
    stopLocationPolling();
    stopTrackingAndSendingLocation();
    super.dispose();
  }
}
