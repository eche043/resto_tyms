import 'package:odrive_restaurant/model/oder_item.dart';

class PaymentHistoryItem {
  final String id;
  final DateTime date;
  final String time;
  final List<OrderItem> items;
  final double total;

  PaymentHistoryItem({
    required this.id,
    required this.date,
    required this.time,
    required this.items,
    required this.total,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
    );
  }

  String get formattedDate {
    final months = [
      '',
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
    return '${date.day.toString().padLeft(2, '0')}-${months[date.month]}-${date.year}';
  }
}
