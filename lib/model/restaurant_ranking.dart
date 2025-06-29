// lib/models/restaurant_ranking.dart

import 'package:flutter/material.dart';

class RestaurantRanking {
  final int id;
  final String name;
  final int published;
  final int ordersCount;
  final double totalRevenue;

  RestaurantRanking({
    required this.id,
    required this.name,
    required this.published,
    required this.ordersCount,
    required this.totalRevenue,
  });

  factory RestaurantRanking.fromJson(Map<String, dynamic> json) {
    return RestaurantRanking(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      published: json['published'] ?? 0,
      ordersCount: json['orders_count'] ?? 0,
      totalRevenue: double.tryParse(json['total_revenue'].toString()) ?? 0.0,
    );
  }

  /// Convertir en format RankingData pour l'affichage
  RankingData toRankingData({required String currency, required int rank}) {
    return RankingData(
      name: name,
      orders: ordersCount,
      revenue: totalRevenue,
      currency: currency,
      position: rank,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'published': published,
      'orders_count': ordersCount,
      'total_revenue': totalRevenue,
    };
  }

  @override
  String toString() {
    return 'RestaurantRanking{id: $id, name: $name, orders: $ordersCount, revenue: $totalRevenue}';
  }
}

/// Modèle pour l'affichage dans le ranking list
class RankingData {
  final String name;
  final int orders;
  final double revenue;
  final String currency;
  final int position;

  RankingData({
    required this.name,
    required this.orders,
    required this.revenue,
    required this.currency,
    required this.position,
  });

  factory RankingData.fromJson(Map<String, dynamic> json) {
    return RankingData(
      name: json['name'] ?? '',
      orders: json['orders'] ?? 0,
      revenue: double.tryParse(json['revenue'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'FCFA',
      position: json['position'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'orders': orders,
      'revenue': revenue,
      'currency': currency,
      'position': position,
    };
  }

  /// Formater le revenu avec la devise
  String get formattedRevenue {
    if (revenue >= 1000000) {
      return '${(revenue / 1000000).toStringAsFixed(1)}M $currency';
    } else if (revenue >= 1000) {
      return '${(revenue / 1000).toStringAsFixed(1)}k $currency';
    } else {
      return '${revenue.toStringAsFixed(0)} $currency';
    }
  }

  /// Obtenir l'icône selon la position
  String get positionIcon {
    switch (position) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '${position}°';
    }
  }

  /// Couleur selon la position
  Color get positionColor {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Or
      case 2:
        return const Color(0xFFC0C0C0); // Argent
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }
}
