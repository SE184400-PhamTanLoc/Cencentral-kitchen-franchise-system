class ManagerStoreModel {
  final int storeId;
  final String storeName;
  final String address;
  final double creditLimit;
  final double currentDebt;
  final bool isActive;

  ManagerStoreModel({
    required this.storeId,
    required this.storeName,
    required this.address,
    required this.creditLimit,
    required this.currentDebt,
    required this.isActive,
  });

  factory ManagerStoreModel.fromJson(Map<String, dynamic> json) {
    return ManagerStoreModel(
      storeId: json['storeId'] ?? 0,
      storeName: json['storeName'] ?? '',
      address: json['address'] ?? '',
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0,
      currentDebt: (json['currentDebt'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }
}
