class Promotion {
  final int id;
  final String name;
  final String description;
  final String offerType;
  final String? triggerItem;
  final double? triggerItemPrice;
  final double? minimumAmount;
  final String rewardType;
  final double? rewardValue;
  final double? rewardPercentage;
  final String? freeProduct;
  final double? freeProductPrice;
  final int? pointsValue;
  final String startDate;
  final String endDate;
  final String frequency;
  final String? conditions;
  final String image;
  final String status;
  final String? responseMessage;
  final String createdAt;
  final String updatedAt;

  Promotion({
    required this.id,
    required this.name,
    required this.description,
    required this.offerType,
    this.triggerItem,
    this.triggerItemPrice,
    this.minimumAmount,
    required this.rewardType,
    this.rewardValue,
    this.rewardPercentage,
    this.freeProduct,
    this.freeProductPrice,
    this.pointsValue,
    required this.startDate,
    required this.endDate,
    required this.frequency,
    this.conditions,
    required this.image,
    required this.status,
    this.responseMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      offerType: json['offer_type'] ?? '',
      triggerItem: json['trigger_item'],
      triggerItemPrice: _parseDouble(json['trigger_item_price']),
      minimumAmount: _parseDouble(json['minimum_amount']),
      rewardType: json['reward_type'] ?? '',
      rewardValue: _parseDouble(json['reward_value']),
      rewardPercentage: _parseDouble(json['reward_percentage']),
      freeProduct: json['free_product'],
      freeProductPrice: _parseDouble(json['free_product_price']),
      pointsValue: _parseInt(json['points_value']),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      frequency: json['frequency'] ?? '',
      conditions: json['conditions'],
      image: json['image'] ?? 'noimage.png',
      status: json['status'] ?? '',
      responseMessage: json['response_message'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // ✅ Méthode helper pour convertir en double de façon sécurisée
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Erreur parsing double: $value -> $e');
        return null;
      }
    }
    return null;
  }

  // ✅ Méthode helper pour convertir en int de façon sécurisée
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        print('Erreur parsing int: $value -> $e');
        return null;
      }
    }
    return null;
  }
}
