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
  bool _isFetchingConversation = false;
  bool _isFetchingLocation = false;
  bool _isDisposed = false;
  int? _activeStoreId;
  int? _activeKitchenId;
  int? _activeOrderId;

  List<ChatMessageModel> get messages => _messages;
  bool get isChatLoading => _isChatLoading;
  List<Map<String, dynamic>> get storesList => _storesList;
  List<Map<String, dynamic>> get kitchensList => _kitchensList;

  Future<void> fetchStoresAndKitchens() async {
    try {
      final stores = await _datasource.getStores();
      final kitchens = await _datasource.getKitchens();
      final hasChanged =
          !_sameLookupList(_storesList, stores) ||
          !_sameLookupList(_kitchensList, kitchens);
      _storesList = stores;
      _kitchensList = kitchens;
      if (hasChanged) {
        _safeNotifyListeners();
      }
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

  Future<void> loadConversationAsync(
    int? storeId,
    int? kitchenId, {
    bool silently = false,
  }) async {
    if (_isFetchingConversation) return;
    _isFetchingConversation = true;
    if (!silently && !_isChatLoading) {
      _isChatLoading = true;
      _safeNotifyListeners();
    }
    try {
      final fetchedMessages = await _datasource.getConversation(storeId, kitchenId);
      if (!_sameMessages(_messages, fetchedMessages)) {
        _messages = fetchedMessages;
        _safeNotifyListeners();
      }
    } catch (_) {}
    _isFetchingConversation = false;
    if (_isChatLoading) {
      _isChatLoading = false;
      _safeNotifyListeners();
    }
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
      _safeNotifyListeners();
    } catch (_) {}
  }

  void startChatPolling(int? storeId, int? kitchenId) {
    if (_activeStoreId == storeId &&
        _activeKitchenId == kitchenId &&
        _chatTimer != null) {
      return;
    }
    _chatTimer?.cancel();
    _activeStoreId = storeId;
    _activeKitchenId = kitchenId;
    _chatTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        await loadConversationAsync(storeId, kitchenId, silently: true);
      } catch (_) {}
    });
  }

  void stopChatPolling() {
    _chatTimer?.cancel();
    _chatTimer = null;
    _activeStoreId = null;
    _activeKitchenId = null;
  }

  // ─── Location Actions ──────────────────────────────────────────

  Future<void> loadLatestLocationAsync(int orderId, {bool silently = false}) async {
    if (_isFetchingLocation) return;
    _isFetchingLocation = true;
    if (!silently && !_isLocationLoading) {
      _isLocationLoading = true;
      _safeNotifyListeners();
    }
    try {
      final loc = await _datasource.getLatestLocation(orderId);
      if (!_sameLocation(_latestLocation, loc)) {
        _latestLocation = loc;
        _safeNotifyListeners();
      }
    } catch (_) {}
    _isFetchingLocation = false;
    if (_isLocationLoading) {
      _isLocationLoading = false;
      _safeNotifyListeners();
    }
  }

  void startLocationPolling(int orderId) {
    if (_activeOrderId == orderId && _locationTimer != null) {
      return;
    }
    _locationTimer?.cancel();
    _activeOrderId = orderId;
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        await loadLatestLocationAsync(orderId, silently: true);
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
      if (!_sameRoute(_activeRoute, route)) {
        _activeRoute = route;
      }
    } catch (_) {
      _activeRoute = [];
    }
    _isRouteLoading = false;
    _safeNotifyListeners();
  }

  void clearRoute() {
    _activeRoute = [];
    _isRouteLoading = false;
    _safeNotifyListeners();
  }

  void stopLocationPolling() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _activeOrderId = null;
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
            _safeNotifyListeners();
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
      _safeNotifyListeners();
    } catch (_) {}
  }

  void stopTrackingAndSendingLocation() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopChatPolling();
    stopLocationPolling();
    stopTrackingAndSendingLocation();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  bool _sameLookupList(
    List<Map<String, dynamic>> current,
    List<Map<String, dynamic>> next,
  ) {
    if (identical(current, next)) return true;
    if (current.length != next.length) return false;
    for (var i = 0; i < current.length; i++) {
      final currentItem = current[i];
      final nextItem = next[i];
      if (currentItem.length != nextItem.length) return false;
      for (final entry in currentItem.entries) {
        if (nextItem[entry.key] != entry.value) return false;
      }
    }
    return true;
  }

  bool _sameMessages(List<ChatMessageModel> current, List<ChatMessageModel> next) {
    if (identical(current, next)) return true;
    if (current.length != next.length) return false;
    for (var i = 0; i < current.length; i++) {
      final a = current[i];
      final b = next[i];
      if (a.messageId != b.messageId ||
          a.senderId != b.senderId ||
          a.messageText != b.messageText ||
          a.createdAt != b.createdAt) {
        return false;
      }
    }
    return true;
  }

  bool _sameLocation(DeliveryLogModel? current, DeliveryLogModel? next) {
    if (current == null || next == null) {
      return current == next;
    }
    return current.logId == next.logId &&
        current.orderId == next.orderId &&
        current.driverId == next.driverId &&
        current.latitude == next.latitude &&
        current.longitude == next.longitude &&
        current.recordedAt == next.recordedAt;
  }

  bool _sameRoute(List<LatLng> current, List<LatLng> next) {
    if (identical(current, next)) return true;
    if (current.length != next.length) return false;
    for (var i = 0; i < current.length; i++) {
      final a = current[i];
      final b = next[i];
      if (a.latitude != b.latitude || a.longitude != b.longitude) {
        return false;
      }
    }
    return true;
  }
}
