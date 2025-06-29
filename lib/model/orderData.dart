class OrderData {
  final int id;
  final String createdAt;
  final String updatedAt;
  final int order;
  final String food;
  final int count;
  final String foodPrice;
  final dynamic extras;
  final int extrasCount;
  final String extrasPrice;
  final int foodId;
  final int extrasId;
  final String image;
  final dynamic desc;
  final dynamic boissons;
  final int boissonsCount;
  final String boissonsPrice;
  final int boissonsId;

  OrderData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
    required this.food,
    required this.count,
    required this.foodPrice,
    required this.extras,
    required this.extrasCount,
    required this.extrasPrice,
    required this.foodId,
    required this.extrasId,
    required this.image,
    required this.desc,
    required this.boissons,
    required this.boissonsCount,
    required this.boissonsPrice,
    required this.boissonsId,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      order: json['order'],
      food: json['food'],
      count: json['count'],
      foodPrice: json['foodprice'],
      extras: json['extras'],
      extrasCount: json['extrascount'],
      extrasPrice: json['extrasprice'],
      foodId: json['foodid'],
      extrasId: json['extrasid'],
      image: json['image'],
      desc: json['desc'],
      boissons: json['boissons'],
      boissonsCount: json['boissonscount'],
      boissonsPrice: json['boissonsprice'],
      boissonsId: json['boissonsid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order': order,
      'food': food,
      'count': count,
      'foodprice': foodPrice,
      'extras': extras,
      'extrascount': extrasCount,
      'extrasprice': extrasPrice,
      'foodid': foodId,
      'extrasid': extrasId,
      'image': image,
      'desc': desc,
      'boissons': boissons,
      'boissonscount': boissonsCount,
      'boissonsprice': boissonsPrice,
      'boissonsid': boissonsId,
    };
  }
}
