// lib/models/orders_evolution.dart

class OrdersEvolution {
  final String period;
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final int deliveredOrders;
  final int cancelledOrders;

  OrdersEvolution({
    required this.period,
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.deliveredOrders,
    required this.cancelledOrders,
  });

  factory OrdersEvolution.fromJson(Map<String, dynamic> json) {
    return OrdersEvolution(
      period: json['period'] ?? '',
      totalOrders: json['total_orders'] ?? 0,
      totalRevenue: double.tryParse(json['total_revenue'].toString()) ?? 0.0,
      averageOrderValue:
          double.tryParse(json['average_order_value'].toString()) ?? 0.0,
      deliveredOrders: json['delivered_orders'] ?? 0,
      cancelledOrders: json['cancelled_orders'] ?? 0,
    );
  }

  /// Formater la période pour l'affichage
  String get formattedPeriod {
    try {
      // Gérer les formats de période : "2024-11", "2024-W45", "2024-11-15"
      if (period.contains('-W')) {
        // Format semaine : "2024-W45"
        final parts = period.split('-W');
        if (parts.length == 2) {
          return 'S${parts[1]}';
        }
      } else if (period.length == 7 && period.contains('-')) {
        // Format mois : "2024-11"
        final parts = period.split('-');
        if (parts.length == 2) {
          final monthNum = int.tryParse(parts[1]);
          if (monthNum != null) {
            final months = [
              'Jan',
              'Fév',
              'Mar',
              'Avr',
              'Mai',
              'Jun',
              'Jul',
              'Aoû',
              'Sep',
              'Oct',
              'Nov',
              'Déc'
            ];
            if (monthNum >= 1 && monthNum <= 12) {
              return months[monthNum - 1];
            }
          }
        }
      } else if (period.length == 10 && period.split('-').length == 3) {
        // Format jour : "2024-11-15"
        final parts = period.split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}';
        }
      }
    } catch (e) {
      print('Error formatting period: $e');
    }

    return period; // Retourner la période originale si le formatage échoue
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'average_order_value': averageOrderValue,
      'delivered_orders': deliveredOrders,
      'cancelled_orders': cancelledOrders,
    };
  }

  @override
  String toString() {
    return 'OrdersEvolution{period: $period, totalOrders: $totalOrders, totalRevenue: $totalRevenue}';
  }
}
