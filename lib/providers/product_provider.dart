import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsProvider with ChangeNotifier {
  int _selectedTabIndex = 0;
  List<FoodsData> _productData = [];
  bool _loading = true;
  // bool _deleting = false;
  Map<String, bool> _deleting = {};

  int get selectedTabIndex => _selectedTabIndex;
  List<FoodsData> get productData => _productData;
  bool get loading => _loading;
  Map<String, bool> get deletingStatus => _deleting;

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setDeleting(String productId, bool isLoading) {
    deletingStatus[productId] = isLoading;
    notifyListeners();
  }

  bool isDeleting(String productId) {
    return deletingStatus[productId] ?? false; // Retourne false si non défini
  }

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";
    var url = '${serverPath}foodsList';
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
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        if (jsonResult["error"] != "0") throw Exception(jsonResult["error"]);
        ResponseFoods ret = ResponseFoods.fromJson(jsonResult);
        _productData = ret.foods;
      }
    } catch (ex) {}
    _loading = false;
    notifyListeners();
  }

  foodDelete(String id, Function(String status) callbackError) async {
    setDeleting(id, true);
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";
    var url = '${serverPath}foodDelete';
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

  List<FoodsData> getFilteredProducts(int status) {
    return _productData.where((product) {
      return status == 1 ? product.visible == "1" : product.visible == "0";
    }).toList();
  }
}
