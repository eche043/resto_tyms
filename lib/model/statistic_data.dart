class StatisticData {
  final String month;
  final int orders;
  final int restaurants;

  StatisticData({
    required this.month,
    required this.orders,
    required this.restaurants,
  });

  factory StatisticData.fromJson(Map<String, dynamic> json) {
    return StatisticData(
      month: json['month'] ?? '',
      orders: json['orders'] ?? 0,
      restaurants: json['restaurants'] ?? 0,
    );
  }
}
