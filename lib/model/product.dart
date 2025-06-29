
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odrive_restaurant/common/util.dart';

class ResponseFoods {
  String error;
  String id;
  List<ImageData> images;
  List<FoodsData> foods;
  List<RestaurantData> restaurants;
  List<ExtrasGroupData> extrasGroupData;
  List<NutritionGroupData> nutritionGroupData;
  int numberOfDigits;

  ResponseFoods(
      {required this.error,
      required this.images,
      required this.foods,
      required this.id,
      required this.restaurants,
      required this.extrasGroupData,
      required this.nutritionGroupData,
      required this.numberOfDigits});

  factory ResponseFoods.fromJson(Map<String, dynamic> json) {
    var t = json['foods'].map((f) => FoodsData.fromJson(f)).toList();
    var _foods = t.cast<FoodsData>().toList();

    t = json['images'].map((f) => ImageData.fromJson(f)).toList();
    var _images = t.cast<ImageData>().toList();

    t = json['restaurants'].map((f) => RestaurantData.fromJson(f)).toList();
    var _restaurants = t.cast<RestaurantData>().toList();

    var _extrasGroupData;
    if (json['extrasGroup'] != null) {
      t = json['extrasGroup'].map((f) => ExtrasGroupData.fromJson(f)).toList();
      _extrasGroupData = t.cast<ExtrasGroupData>().toList();
    }

    var _nutritionGroupData;
    if (json['nutritionGroup'] != null) {
      t = json['nutritionGroup']
          .map((f) => NutritionGroupData.fromJson(f))
          .toList();
      _nutritionGroupData = t.cast<NutritionGroupData>().toList();
    }

    return ResponseFoods(
      error: json['error'].toString(),
      id: json['id'].toString(),
      images: _images,
      foods: _foods,
      restaurants: _restaurants,
      extrasGroupData: _extrasGroupData,
      nutritionGroupData: _nutritionGroupData,
      numberOfDigits: toInt(json['numberOfDigits'].toString()),
    );
  }
}

class FoodsData {
  String id;
  String updatedAt;
  String name;
  int imageid;
  String price;
  String discountprice;
  String desc;
  int restaurant;
  int category;
  String ingredients;
  String visible;
  int extras;
  int nutrition;
  List<String> imagesFilesIds;
  List<VariantsData> variants;
  String? image;

  FoodsData(
      {required this.id,
      required this.name,
      required this.updatedAt,
      required this.desc,
      required this.imageid,
      required this.price,
      required this.ingredients,
      required this.visible,
      required this.extras,
      required this.nutrition,
      required this.restaurant,
      required this.category,
      required this.discountprice,
      required this.imagesFilesIds,
      required this.variants,
      this.image});
  factory FoodsData.fromJson(Map<String, dynamic> json) {
    List<String> _imagesFilesIds = [];
    if (json['images'] != null)
      _imagesFilesIds = json['images'].toString().split(',');

    var t = json['variants'].map((f) => VariantsData.fromJson(f)).toList();
    var _variants = t.cast<VariantsData>().toList();

    return FoodsData(
        id: json['id'].toString(),
        updatedAt: json['updated_at'].toString(),
        name: json['name'].toString(),
        imageid: toInt(json['imageid'].toString()),
        price: json['price'].toString(),
        discountprice: json['discountprice'].toString(),
        desc: json['desc'].toString(),
        ingredients: json['ingredients'].toString(),
        visible: json['published'].toString(),
        extras: toInt(json['extras'].toString()),
        nutrition: toInt(json['nutritions'].toString()),
        restaurant: toInt(json['restaurant'].toString()),
        category: toInt(json['category'].toString()),
        imagesFilesIds: _imagesFilesIds,
        variants: _variants,
        image: json['image'].toString());
  }
}

class VariantsData {
  int id;
  String name;
  int imageId;
  double price;
  double dprice;

  VariantsData(
      {required this.id,
      required this.name,
      required this.imageId,
      required this.price,
      required this.dprice});
  factory VariantsData.fromJson(Map<String, dynamic> json) {
    return VariantsData(
      id: toInt(json['id'].toString()),
      name: json['name'].toString(),
      imageId: toInt(json['imageid'].toString()),
      price: toDouble(json['price'].toString()),
      dprice: toDouble(json['dprice'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "imageid": this.imageId,
      "price": this.price,
      "dprice": this.dprice,
    };
  }
}

// class RestaurantData {
//   int id;
//   String updatedAt;
//   String name;
//   String imageId;
//   String published;

//   RestaurantData(
//       {required this.id,
//       required this.name,
//       required this.updatedAt,
//       required this.imageId,
//       required this.published});
//   factory RestaurantData.fromJson(Map<String, dynamic> json) {
//     return RestaurantData(
//       id: toInt(json['id'].toString()),
//       updatedAt: json['updatedAt'].toString(),
//       name: json['name'].toString(),
//       imageId: json['imageId'].toString(),
//       published: json['published'].toString(),
//     );
//   }
// }

class RestaurantData {
  int id;
  String createdAt;
  String updatedAt;
  int user;
  int restaurant;
  String name;
  int published;
  int delivered;
  String phone;
  String mobilePhone;
  String address;
  double lat;
  double lng;
  int imageId;
  String? image;
  String desc;
  String fee;
  int percent;
  String openTimeMonday;
  String closeTimeMonday;
  String openTimeTuesday;
  String closeTimeTuesday;

  RestaurantData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.restaurant,
    required this.name,
    required this.published,
    required this.delivered,
    required this.phone,
    required this.mobilePhone,
    required this.address,
    required this.lat,
    required this.lng,
    required this.imageId,
    required this.image,
    required this.desc,
    required this.fee,
    required this.percent,
    required this.openTimeMonday,
    required this.closeTimeMonday,
    required this.openTimeTuesday,
    required this.closeTimeTuesday,
  });

  factory RestaurantData.fromJson(Map<String, dynamic> json) {
    return RestaurantData(
      id: int.parse(json['id'].toString()),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      user: int.parse(json['user'].toString()),
      restaurant: int.parse(json['restaurant'].toString()),
      name: json['name'].toString(),
      published: int.parse(json['published'].toString()),
      delivered: int.parse(json['delivered'].toString()),
      phone: json['phone'].toString(),
      mobilePhone: json['mobilephone'].toString(),
      address: json['address'].toString(),
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
      imageId: int.parse(json['imageid'].toString()),
      image: json['image'].toString(),
      desc: json['desc'].toString(),
      fee: json['fee'].toString(),
      percent: int.parse(json['percent'].toString()),
      openTimeMonday: json['openTimeMonday'].toString(),
      closeTimeMonday: json['closeTimeMonday'].toString(),
      openTimeTuesday: json['openTimeTuesday'].toString(),
      closeTimeTuesday: json['closeTimeTuesday'].toString(),
    );
  }
}


class ExtrasGroupData {
  int id;
  String updatedAt;
  String name;
  int restaurant;

  ExtrasGroupData(
      {required this.id,
      required this.name,
      required this.updatedAt,
      required this.restaurant});
  factory ExtrasGroupData.fromJson(Map<String, dynamic> json) {
    return ExtrasGroupData(
      id: toInt(json['id'].toString()),
      updatedAt: json['updated_at'].toString(),
      name: json['name'].toString(),
      restaurant: toInt(json['restaurant'].toString()),
    );
  }
}

class NutritionGroupData {
  int id;
  String updatedAt;
  String name;

  NutritionGroupData(
      {required this.id, required this.name, required this.updatedAt});
  factory NutritionGroupData.fromJson(Map<String, dynamic> json) {
    return NutritionGroupData(
      id: toInt(json['id'].toString()),
      updatedAt: json['updatedAt'].toString(),
      name: json['name'].toString(),
    );
  }
}
class ImageData {
  int id;
  String filename;
  ImageData({required this.id, required this.filename});
  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: toInt(json['id'].toString()),
      filename: json['filename'].toString(),
    );
  }
}
