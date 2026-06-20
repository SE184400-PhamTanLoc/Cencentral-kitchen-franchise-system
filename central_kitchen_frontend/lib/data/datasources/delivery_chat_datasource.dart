import '../../core/network/api_client.dart';
import '../models/chat_message_model.dart';
import '../models/delivery_log_model.dart';

class DeliveryChatDatasource {
  final ApiClient _apiClient;

  DeliveryChatDatasource(this._apiClient);

  // Chat API calls
  Future<List<Map<String, dynamic>>> getStores() async {
    final response = await _apiClient.get('/api/chat/stores');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> getKitchens() async {
    final response = await _apiClient.get('/api/chat/kitchens');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<ChatMessageModel>> getConversation(int? storeId, int? kitchenId) async {
    final response = await _apiClient.get(
      '/api/chat/conversation',
      queryParameters: {
        'storeId': storeId,
        'kitchenId': kitchenId,
      },
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChatMessageModel> sendMessage({
    required int senderId,
    int? storeId,
    int? kitchenId,
    required String messageText,
  }) async {
    final response = await _apiClient.post(
      '/api/chat',
      data: {
        'senderId': senderId,
        'storeId': storeId,
        'kitchenId': kitchenId,
        'messageText': messageText,
      },
    );
    return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Delivery API calls
  Future<DeliveryLogModel> updateLocation({
    required int orderId,
    required int driverId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.post(
      '/api/delivery/location',
      data: {
        'orderId': orderId,
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return DeliveryLogModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DeliveryLogModel?> getLatestLocation(int orderId) async {
    try {
      final response = await _apiClient.get('/api/delivery/location/$orderId');
      return DeliveryLogModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
