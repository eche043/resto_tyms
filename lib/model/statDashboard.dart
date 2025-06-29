import 'package:odrive_restaurant/model/oder_item.dart';
import 'package:odrive_restaurant/model/payment_history.dart';
import 'package:odrive_restaurant/model/restaurant_ranking.dart';
import 'package:odrive_restaurant/model/statistic_data.dart';
import 'package:odrive_restaurant/model/top_food.dart';

class DashboardStats {
  final int totalOrders;
  final int totalRestaurants;
  final double totalEarnings;
  final String currency;
  final List<StatisticData> chartData;
  final List<RankingData> ranking;
  final List<BestSellingProduct> bestSellingProducts;
  final List<PaymentHistoryItem> paymentHistory;

  DashboardStats({
    required this.totalOrders,
    required this.totalRestaurants,
    required this.totalEarnings,
    required this.currency,
    required this.chartData,
    required this.ranking,
    required this.bestSellingProducts,
    required this.paymentHistory,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalOrders: json['total_orders'] ?? 0,
      totalRestaurants: json['total_restaurants'] ?? 0,
      totalEarnings:
          double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'FCFA',
      chartData: (json['chart_data'] as List<dynamic>?)
              ?.map((item) => StatisticData.fromJson(item))
              .toList() ??
          [],
      ranking: (json['ranking'] as List<dynamic>?)
              ?.map((item) => RankingData.fromJson(item))
              .toList() ??
          [],
      bestSellingProducts: (json['best_selling_products'] as List<dynamic>?)
              ?.map((item) => BestSellingProduct.fromJson(item))
              .toList() ??
          [],
      paymentHistory: (json['payment_history'] as List<dynamic>?)
              ?.map((item) => PaymentHistoryItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  // Données statiques pour le développement
  static DashboardStats getMockData() {
    return DashboardStats(
      totalOrders: 1246,
      totalRestaurants: 250,
      totalEarnings: 13254,
      currency: 'FCFA',
      chartData: [
        StatisticData(month: 'Jan', orders: 25, restaurants: 30),
        StatisticData(month: 'Fév', orders: 50, restaurants: 31),
        StatisticData(month: 'Mar', orders: 60, restaurants: 25),
        StatisticData(month: 'Avr', orders: 35, restaurants: 30),
        StatisticData(month: 'Mai', orders: 20, restaurants: 33),
        StatisticData(month: 'Jun', orders: 32, restaurants: 20),
        StatisticData(month: 'Jul', orders: 52, restaurants: 18),
        StatisticData(month: 'Aoû', orders: 32, restaurants: 32),
        StatisticData(month: 'Sep', orders: 44, restaurants: 25),
        StatisticData(month: 'Oct', orders: 25, restaurants: 24),
        StatisticData(month: 'Nov', orders: 60, restaurants: 18),
      ],
      ranking: [
        RankingData(
            name: 'TMY556',
            orders: 646,
            revenue: 1000,
            position: 1,
            currency: 'F'),
        RankingData(
            name: 'TMY556',
            orders: 646,
            revenue: 1000,
            position: 2,
            currency: 'F'),
        RankingData(
            name: 'TMY556',
            orders: 646,
            revenue: 1000,
            position: 3,
            currency: 'F'),
        RankingData(
            name: 'TMY556',
            orders: 646,
            revenue: 1000,
            position: 4,
            currency: 'F'),
      ],
      bestSellingProducts: [
        BestSellingProduct(
            name: 'Pizza',
            percentage: 35,
            color: '#4CAF50',
            orders: 20,
            revenue: 1000,
            currency: 'F'),
        BestSellingProduct(
            name: 'Pizza',
            percentage: 35,
            color: '#81C784',
            orders: 20,
            revenue: 1000,
            currency: 'F'),
        BestSellingProduct(
            name: 'Pizza',
            percentage: 35,
            color: '#2196F3',
            orders: 20,
            revenue: 1000,
            currency: 'F'),
        BestSellingProduct(
            name: 'Pizza',
            percentage: 35,
            color: '#C8E6C9',
            orders: 20,
            revenue: 1000,
            currency: 'F'),
        BestSellingProduct(
            name: 'Pizza',
            percentage: 35,
            color: '#A5D6A7',
            orders: 20,
            revenue: 1000,
            currency: 'F'),
      ],
      paymentHistory: [
        PaymentHistoryItem(
          id: 'df355',
          date: DateTime(2024, 9, 15),
          time: '13:55',
          items: [
            OrderItem(name: 'Item 1', quantity: 3, price: 10),
            OrderItem(name: 'Item 2', quantity: 1, price: 20),
            OrderItem(name: 'Item 3', quantity: 1, price: 10),
          ],
          total: 60,
        ),
      ],
    );
  }
}
