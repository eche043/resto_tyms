import 'package:odrive_restaurant/common/util.dart';
import 'package:odrive_restaurant/model/orderData.dart';

class Order {
  int id;
  String createdAt;
  String updatedAt;
  int user;
  int driver;
  int status;
  String pstatus;
  int tax;
  String hint;
  int active;
  int restaurant;
  String method;
  String total;
  String fee;
  int send;
  String address;
  String phone;
  String lat;
  String lng;
  int percent;
  String curbsidePickup;
  String? arrived;
  String couponName;
  int perkm;
  String view;
  String? notes;
  dynamic allergies;
  String? friendName;
  String? friendPhone;
  int friend;
  int qrScan;
  dynamic qrCode;
  String userName;
  String userType;
  List<OrderData> ordersData;
  String addressDest;
  String latRest;
  String lngRest;
  int? haveDelivery;
  int is_accept;

  Order(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.user,
      required this.driver,
      required this.status,
      required this.pstatus,
      required this.tax,
      required this.hint,
      required this.active,
      required this.restaurant,
      required this.method,
      required this.total,
      required this.fee,
      required this.send,
      required this.address,
      required this.phone,
      required this.lat,
      required this.lng,
      required this.percent,
      required this.curbsidePickup,
      this.arrived,
      required this.couponName,
      required this.perkm,
      required this.view,
      this.notes,
      required this.allergies,
      this.friendName,
      this.friendPhone,
      required this.friend,
      required this.qrScan,
      required this.qrCode,
      required this.userName,
      required this.userType,
      required this.ordersData,
      required this.addressDest,
      required this.latRest,
      required this.lngRest,
      required this.haveDelivery,
      required this.is_accept});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        user: json['user'],
        driver: json['driver'],
        status: json['status'],
        pstatus: json['pstatus'],
        tax: json['tax'],
        hint: json['hint'],
        active: json['active'],
        restaurant: json['restaurant'],
        method: json['method'],
        total: json['total'],
        fee: json['fee'],
        send: json['send'],
        address: json['address'],
        phone: json['phone'],
        lat: json['lat'],
        lng: json['lng'],
        percent: json['percent'],
        curbsidePickup: json['curbsidePickup'],
        arrived: json['arrived'],
        couponName: json['couponName'],
        perkm: json['perkm'],
        view: json['view'],
        notes: json['notes'],
        allergies: json['allergies'],
        friendName: json['friend_name'],
        friendPhone: json['friend_phone'],
        friend: json['friend'],
        qrScan: json['qr_scan'],
        qrCode: json['qr_code'],
        userName: json['userName'],
        userType: json['userType'],
        ordersData: (json['ordersData'] as List)
            .map((e) => OrderData.fromJson(e))
            .toList(),
        addressDest: json['addressDest'],
        latRest: json['latRest'],
        lngRest: json['lngRest'],
        haveDelivery: json['HaveDelivery'],
        is_accept: json['is_accept']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user,
      'driver': driver,
      'status': status,
      'pstatus': pstatus,
      'tax': tax,
      'hint': hint,
      'active': active,
      'restaurant': restaurant,
      'method': method,
      'total': total,
      'fee': fee,
      'send': send,
      'address': address,
      'phone': phone,
      'lat': lat,
      'lng': lng,
      'percent': percent,
      'curbsidePickup': curbsidePickup,
      'arrived': arrived,
      'couponName': couponName,
      'perkm': perkm,
      'view': view,
      'notes': notes,
      'allergies': allergies,
      'friend_name': friendName,
      'friend_phone': friendPhone,
      'friend': friend,
      'qr_scan': qrScan,
      'qr_code': qrCode,
      'userName': userName,
      'ordersData': ordersData.map((e) => e.toJson()).toList(),
      'addressDest': addressDest,
      'latRest': latRest,
      'lngRest': lngRest,
      'haveDelivery': haveDelivery,
      'is_accept': is_accept,
    };
  }
}

class DriversData {
  String id;
  String name;
  int imageid;
  String phone;
  String active;

  DriversData(
      {required this.id,
      required this.name,
      required this.imageid,
      required this.phone,
      required this.active});
  factory DriversData.fromJson(Map<String, dynamic> json) {
    return DriversData(
      id: json['id'].toString(),
      name: json['name'].toString(),
      imageid: toInt(json['imageid'].toString()),
      phone: json['phone'].toString(),
      active: json['active'].toString(),
    );
  }

  String toString_() {
    return 'DriversData{id: $id, name: $name, imageid: $imageid, phone: $phone, active: $active}';
  }
}
