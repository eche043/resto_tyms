import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantsProvider with ChangeNotifier {
  int _selectedTabIndex = 0;
  List<RestaurantData> _restaurantData = [];
  bool _loading = true;

  int get selectedTabIndex => _selectedTabIndex;
  List<RestaurantData> get restaurantData => _restaurantData;
  bool get loading => _loading;
  Map<String, bool> _deleting = {};

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
  Map<String, bool> get deletingStatus => _deleting;


  void setDeleting(String productId, bool isLoading) {
    deletingStatus[productId] = isLoading;
    notifyListeners();
  }
  bool isDeleting(String productId) {
    return deletingStatus[productId] ?? false; // Retourne false si non défini
  }

  Future<void> fetchRestaurants() async {
    _loading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";
    // var url = '${serverPath}foodsList';
    var url = '${serverPath}restaurantsList';
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };
    var body = json.encoder.convert({});
    try {
      var response = await http
          .post(Uri.parse(url), headers: requestHeaders, body: body)
          .timeout(const Duration(seconds: 30));
      print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        print(jsonResult['restaurants']);
        if (jsonResult["error"] != "0") throw Exception(jsonResult["error"]);
        _restaurantData = (jsonResult["restaurants"] as List)
            .map((e) => RestaurantData.fromJson(e))
            .toList();
        print(_restaurantData);
        _loading = false;
        notifyListeners();
      }
    } catch (ex) {}
    _loading = false;
    notifyListeners();
  }
  restaurantDelete(String id, Function(String status) callbackError) async {
    setDeleting(id, true);
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";
    var url = '${serverPath}restaurantDelete';
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer ${uid}",
    };
    var body = json.encoder.convert({
      "id": id,
    });
    try {
      var response =
          await http.post(Uri.parse(url), headers: requestHeaders, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        if (jsonResult["error"] != "0") {
          callbackError("error");
          return;
        }
        callbackError("success");
      } else {
        callbackError("error");
      }
    } catch (ex) {
      callbackError('error');
    }
    setDeleting(id, false);
    notifyListeners();
  }

  List<RestaurantData> getFilteredRestaurants(int status) {
    return _restaurantData.where((restaurant) {
      return status == 1 ? restaurant.published == 1 : restaurant.published == 0;
    }).toList();
  }
}
