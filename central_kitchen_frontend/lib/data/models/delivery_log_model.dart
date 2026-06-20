class DeliveryLogModel {
  final int logId;
  final int orderId;
  final int driverId;
  final String driverName;
  final double latitude;
  final double longitude;
  final DateTime? recordedAt;

  DeliveryLogModel({
    required this.logId,
    required this.orderId,
    required this.driverId,
    required this.driverName,
    required this.latitude,
    required this.longitude,
    this.recordedAt,
  });

  factory DeliveryLogModel.fromJson(Map<String, dynamic> json) =>
      DeliveryLogModel(
        logId: json['logId'] ?? 0,
        orderId: json['orderId'] ?? 0,
        driverId: json['driverId'] ?? 0,
        driverName: json['driverName'] ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        recordedAt: json['recordedAt'] != null
            ? DateTime.tryParse(json['recordedAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'logId': logId,
        'orderId': orderId,
        'driverId': driverId,
        'driverName': driverName,
        'latitude': latitude,
        'longitude': longitude,
        'recordedAt': recordedAt?.toIso8601String(),
      };
}
