// lib/models/top_food.dart

class TopFood {
  final int foodId;
  final String foodName;
  final int restaurantId;
  final String restaurantName;
  final FoodCategory category;
  final double price;
  final double discountPrice;
  final double currentPrice;
  final String image;
  final int totalOrdered;
  final double totalRevenue;
  final double averagePrice;
  final double percentage;
  final int ranking;

  TopFood({
    required this.foodId,
    required this.foodName,
    required this.restaurantId,
    required this.restaurantName,
    required this.category,
    required this.price,
    required this.discountPrice,
    required this.currentPrice,
    required this.image,
    required this.totalOrdered,
    required this.totalRevenue,
    required this.averagePrice,
    required this.percentage,
    required this.ranking,
  });

  factory TopFood.fromJson(Map<String, dynamic> json) {
    return TopFood(
      foodId: json['food_id'] ?? 0,
      foodName: json['food_name'] ?? '',
      restaurantId: json['restaurant_id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? '',
      category: FoodCategory.fromJson(json['category'] ?? {}),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      discountPrice: double.tryParse(json['discount_price'].toString()) ?? 0.0,
      currentPrice: double.tryParse(json['current_price'].toString()) ?? 0.0,
      image: json['image'] ?? '',
      totalOrdered: json['total_ordered'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      averagePrice: (json['average_price'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      ranking: json['ranking'] ?? 0,
    );
  }

  /// Convertir en BestSellingProduct pour l'affichage dans le graphique
  BestSellingProduct toBestSellingProduct(String currency) {
    return BestSellingProduct(
      name: foodName,
      percentage: percentage,
      color: getColorByRanking(ranking),
      orders: totalOrdered,
      revenue: totalRevenue,
      currency: currency,
    );
  }

  /// Obtenir une couleur selon le classement
  String getColorByRanking(int rank) {
    final colors = [
      '4A7C59', // Vert principal
      '6B9F7F', // Vert clair
      '8BC4A5', // Vert très clair
      'A5D4C1', // Vert pastel
      'C1E4D3', // Vert très pastel
    ];

    if (rank <= colors.length) {
      return colors[rank - 1];
    }
    return 'CCCCCC'; // Gris par défaut
  }

  /// URL complète de l'image
  String get imageUrl {
    if (image.isEmpty) return '';
    // Ajustez cette URL selon votre configuration
    return 'https://odriveportail.com/uploads/foods/$image';
  }

  /// Prix formaté avec devise
  String formatPrice(String currency) {
    return '${currentPrice.toStringAsFixed(0)} $currency';
  }

  /// Revenus formatés
  String formatRevenue(String currency) {
    if (totalRevenue >= 1000000) {
      return '${(totalRevenue / 1000000).toStringAsFixed(1)}M $currency';
    } else if (totalRevenue >= 1000) {
      return '${(totalRevenue / 1000).toStringAsFixed(1)}k $currency';
    } else {
      return '${totalRevenue.toStringAsFixed(0)} $currency';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'category': category.toJson(),
      'price': price,
      'discount_price': discountPrice,
      'current_price': currentPrice,
      'image': image,
      'total_ordered': totalOrdered,
      'total_revenue': totalRevenue,
      'average_price': averagePrice,
      'percentage': percentage,
      'ranking': ranking,
    };
  }

  @override
  String toString() {
    return 'TopFood{name: $foodName, orders: $totalOrdered, percentage: $percentage%}';
  }
}

class FoodCategory {
  final int id;
  final String name;

  FoodCategory({
    required this.id,
    required this.name,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TopFoodSummary {
  final int totalFoodsOrdered;
  final int topFoodsCount;
  final double topFoodsPercentage;
  final double otherFoodsPercentage;

  TopFoodSummary({
    required this.totalFoodsOrdered,
    required this.topFoodsCount,
    required this.topFoodsPercentage,
    required this.otherFoodsPercentage,
  });

  factory TopFoodSummary.fromJson(Map<String, dynamic> json) {
    return TopFoodSummary(
      totalFoodsOrdered:
          int.tryParse(json['total_foods_ordered'].toString()) ?? 0,
      topFoodsCount: json['top_foods_count'] ?? 0,
      topFoodsPercentage: (json['top_foods_percentage'] ?? 0).toDouble(),
      otherFoodsPercentage: (json['other_foods_percentage'] ?? 0).toDouble(),
    );
  }
}

/// Modèle pour l'affichage dans le graphique en secteurs
class BestSellingProduct {
  final String name;
  final double percentage;
  final String color;
  final int orders;
  final double revenue;
  final String currency;

  BestSellingProduct({
    required this.name,
    required this.percentage,
    required this.color,
    required this.orders,
    required this.revenue,
    required this.currency,
  });

  factory BestSellingProduct.fromJson(Map<String, dynamic> json) {
    return BestSellingProduct(
      name: json['name'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
      color: json['color'] ?? '4A7C59',
      orders: json['orders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'FCFA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'percentage': percentage,
      'color': color,
      'orders': orders,
      'revenue': revenue,
      'currency': currency,
    };
  }
}
