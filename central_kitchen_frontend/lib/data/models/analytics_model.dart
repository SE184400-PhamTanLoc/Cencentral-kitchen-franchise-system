class AnalyticsModel {
  final double totalRevenue;
  final int totalOrders;
  final int cancelledOrders;
  final List<DailyRevenueModel> dailyRevenues;

  AnalyticsModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.cancelledOrders,
    required this.dailyRevenues,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
      dailyRevenues: (json['dailyRevenues'] as List<dynamic>? ?? [])
          .map((e) => DailyRevenueModel.fromJson(e))
          .toList(),
    );
  }
}

class DailyRevenueModel {
  final String date;
  final double revenue;

  DailyRevenueModel({required this.date, required this.revenue});

  factory DailyRevenueModel.fromJson(Map<String, dynamic> json) {
    return DailyRevenueModel(
      date: json['date'] ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}
