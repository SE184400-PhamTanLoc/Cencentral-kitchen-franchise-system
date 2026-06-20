/// Lớp dữ liệu KitchenModel biểu diễn thông tin một Bếp Trung Tâm (Central Kitchen).
/// Ánh xạ từ KitchenResponseDto của Backend API.
class KitchenModel {
  final int kitchenId;
  final String kitchenName;
  final String address;
  final String? phoneNumber;
  final bool isActive;
  final int staffCount;

  KitchenModel({
    required this.kitchenId,
    required this.kitchenName,
    required this.address,
    this.phoneNumber,
    required this.isActive,
    required this.staffCount,
  });

  /// Chuyển đổi dữ liệu JSON từ API thành đối tượng KitchenModel.
  /// TODO 1.4.1: Triển khai ánh xạ từ JSON của API.
  /// Gợi ý:
  /// factory KitchenModel.fromJson(Map<String, dynamic> json) {
  ///   return KitchenModel(
  ///     kitchenId: json['kitchenId'] ?? 0,
  ///     kitchenName: json['kitchenName'] ?? '',
  ///     address: json['address'] ?? '',
  ///     phoneNumber: json['phoneNumber'],
  ///     isActive: json['isActive'] ?? true,
  ///     staffCount: json['staffCount'] ?? 0,
  ///   );
  /// }
  factory KitchenModel.fromJson(Map<String, dynamic> json) {
    return KitchenModel(
      kitchenId: json['kitchenId'] ?? 0,
      kitchenName: json['kitchenName'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'],
      isActive: json['isActive'] ?? true,
      staffCount: json['staffCount'] ?? 0,
    );
  }

  /// Chuyển đổi đối tượng thành dữ liệu JSON làm payload truyền đi.
  /// TODO 1.4.2: Triển khai toJson gửi dữ liệu tạo mới/cập nhật bếp trung tâm.
  /// Gợi ý:
  /// Map<String, dynamic> toJson() {
  ///   return {
  ///     'kitchenName': kitchenName,
  ///     'address': address,
  ///     'phoneNumber': phoneNumber,
  ///     'isActive': isActive,
  ///   };
  /// }
  Map<String, dynamic> toJson() {
    return {
      'kitchenName': kitchenName,
      'address': address,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
    };
  }
}
