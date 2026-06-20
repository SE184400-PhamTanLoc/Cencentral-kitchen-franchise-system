/// Lớp dữ liệu StoreModel biểu diễn thông tin một Cửa hàng Franchise Nhượng Quyền.
/// Ánh xạ từ StoreResponseDto của Backend API.
class StoreModel {
  final int storeId;
  final String storeName;
  final String address;
  final String? phoneNumber;
  final double? creditLimit;
  final double? currentDebt;
  final bool isActive;
  final int staffCount;

  StoreModel({
    required this.storeId,
    required this.storeName,
    required this.address,
    this.phoneNumber,
    this.creditLimit,
    this.currentDebt,
    required this.isActive,
    required this.staffCount,
  });

  /// Chuyển đổi dữ liệu JSON từ API thành đối tượng StoreModel.
  /// TODO 1.3.1: Triển khai ánh xạ từ JSON của API.
  /// Gợi ý:
  /// factory StoreModel.fromJson(Map<String, dynamic> json) {
  ///   return StoreModel(
  ///     storeId: json['storeId'] ?? 0,
  ///     storeName: json['storeName'] ?? '',
  ///     address: json['address'] ?? '',
  ///     phoneNumber: json['phoneNumber'],
  ///     creditLimit: json['creditLimit'] != null ? (json['creditLimit'] as num).toDouble() : null,
  ///     currentDebt: json['currentDebt'] != null ? (json['currentDebt'] as num).toDouble() : null,
  ///     isActive: json['isActive'] ?? true,
  ///     staffCount: json['staffCount'] ?? 0,
  ///   );
  /// }
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      storeId: json['storeId'] ?? 0,
      storeName: json['storeName'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'],
      creditLimit: json['creditLimit'] != null ? (json['creditLimit'] as num).toDouble() : null,
      currentDebt: json['currentDebt'] != null ? (json['currentDebt'] as num).toDouble() : null,
      isActive: json['isActive'] ?? true,
      staffCount: json['staffCount'] ?? 0,
    );
  }

  /// Chuyển đổi đối tượng thành dữ liệu JSON làm payload truyền đi.
  /// TODO 1.3.2: Triển khai toJson gửi dữ liệu tạo mới/cập nhật cửa hàng.
  /// Gợi ý:
  /// Map<String, dynamic> toJson() {
  ///   return {
  ///     'storeName': storeName,
  ///     'address': address,
  ///     'phoneNumber': phoneNumber,
  ///     'creditLimit': creditLimit,
  ///     'isActive': isActive,
  ///   };
  /// }
  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'address': address,
      'phoneNumber': phoneNumber,
      'creditLimit': creditLimit,
      'isActive': isActive,
    };
  }
}
