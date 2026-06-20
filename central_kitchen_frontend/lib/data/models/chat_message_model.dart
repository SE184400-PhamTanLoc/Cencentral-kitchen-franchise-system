class ChatMessageModel {
  final int messageId;
  final int senderId;
  final String senderName;
  final String senderRole;
  final int? storeId;
  final int? kitchenId;
  final String messageText;
  final DateTime? createdAt;

  ChatMessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.storeId,
    this.kitchenId,
    required this.messageText,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        messageId: json['messageId'] ?? 0,
        senderId: json['senderId'] ?? 0,
        senderName: json['senderName'] ?? '',
        senderRole: json['senderRole'] ?? '',
        storeId: json['storeId'],
        kitchenId: json['kitchenId'],
        messageText: json['messageText'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'storeId': storeId,
        'kitchenId': kitchenId,
        'messageText': messageText,
        'createdAt': createdAt?.toIso8601String(),
      };
}
