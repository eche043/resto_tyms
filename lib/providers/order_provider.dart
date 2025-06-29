import 'dart:convert';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/model/order.dart';
import 'package:odrive_restaurant/model/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider with ChangeNotifier {
  int _selectedTabIndex = 0;
  List<Order> _orderData = [];
  List<Order> _orderDataBase = [];
  List<Order> _filteredOrders = []; // Liste séparée pour le filtrage
  bool _loading = true; // État de chargement initial
  bool _isLoadingMore = false; // Pour le chargement supplémentaire
  int _currentOffset = 0; // Utilisé pour la pagination
  bool _hasMoreOrders = true; // Indique s'il reste des commandes à charger
  final int _itemsPerPage = 10; // Nombre d'éléments à charger par page

  int get selectedTabIndex => _selectedTabIndex;
  List<Order> get orderData => _orderData;
  List<Order> get filteredOrders => _filteredOrders; // Liste de filtrage
  bool get loading => _loading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreOrders => _hasMoreOrders;

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    _filterOrders(); // Appliquer le filtre lors du changement d'onglet
    notifyListeners();
  }

  // Méthode pour filtrer les commandes en fonction de l'onglet sélectionné
  void _filterOrders() {
    if (_selectedTabIndex == 0) {
      _filteredOrders = [..._orderData];
    } else {
      _filteredOrders = _orderDataBase.where((order) {
        return order.status == _selectedTabIndex;
      }).toList();
    }
  }

  Future<void> fetchOrders({bool isLoadMore = false}) async {
    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _loading = true;
      _currentOffset =
          0; // Réinitialiser l'offset si ce n'est pas un chargement supplémentaire
      _orderData.clear(); // Vider les données existantes
      _filteredOrders.clear(); // Réinitialiser les données filtrées
      _hasMoreOrders = true; // Réinitialiser à vrai pour un nouvel appel
    }

    notifyListeners();

    try {
      var response = await getOrders();
      print("laaaaaá");
      // print(response["orders"][0]['HaveDelivery']);
      List<Order> fetchedOrders =
          (response["orders"] as List).map((e) => Order.fromJson(e)).toList();

      if (fetchedOrders.isNotEmpty) {
        _orderDataBase = fetchedOrders;
        int endOffset = _currentOffset + _itemsPerPage;
        List<Order> nextChunk = fetchedOrders.sublist(
          _currentOffset,
          endOffset > fetchedOrders.length ? fetchedOrders.length : endOffset,
        );

        _orderData.addAll(nextChunk);
        _currentOffset = endOffset;

        if (_currentOffset >= fetchedOrders.length) {
          _hasMoreOrders = false; // Toutes les données ont été chargées
        }
      } else {
        _hasMoreOrders = false;
      }
    } catch (e) {
      print("Erreur lors de la récupération des commandes: $e");
      _hasMoreOrders = false;
    }

    _loading = false;
    _isLoadingMore = false;

    _filterOrders(); // Mettre à jour la liste filtrée
    notifyListeners();
  }

// Nouvelle Méthode
  void updateOrder(Order updatedOrder) {
    int index = _orderData.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orderData[index] = updatedOrder;
      notifyListeners();
    }
  }

  Future<void>  changeStatus(String orderId, String status,
      VoidCallback onSuccess, Function(String) onError) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";
    var url = '${serverPath}changeStatus';
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };
    var body = json.encoder.convert({"id": orderId, "status": status});
    try {
      var response = await http
          .post(Uri.parse(url), headers: requestHeaders, body: body);
          // .timeout(const Duration(seconds: 30));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        print(jsonResult);
        if (jsonResult['error'] == "1") {
          // fetchOrders();
          // Order order = _orderData
          //     .firstWhere((element) => element.id.toString() == orderId);
          // order.status = int.parse(status);
          // updateOrder(order);
          onSuccess();
          print("success est letiit");
        } else
          onError(jsonResult['error']);
      } else
        onError("statusCode=${response.statusCode}");
    } catch (ex) {
      onError(ex.toString());
    }
  }

  Future<List<DriversData>> getNearestDrivers(String restaurantId) async {
  final response = await http.post(
    Uri.parse('${serverPath}getNearestDrivers'),
    body: {'restaurant': restaurantId},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];

    List<DriversData> driversList =
        data.map((item) => DriversData.fromJson(item)).toList();

    print("---------------------------------");
    driversList.forEach((driver) {
      print(driver.toString_());
    });

    return driversList;
  } else {
    final data = json.decode(response.body);
    print(data);
    throw Exception('Impossible de charger les livreurs');
  }
}

Future<bool> fetchOrdertimeStatus(String orderId) async {
  try {
    final response = await http.post(
      Uri.parse('${serverPath}getOrdertimeStatus'),
      body: {'orderid': orderId},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      bool hasStatus9 = data["status"];
      return hasStatus9;
    } else {
      final data = json.decode(response.body);
      print("Erreur : ${data["error"]}");
      return false;
    }
  } catch (e) {
    print("Erreur lors de la requête : $e");
    return false;
  }
}

changeDriver(String id, String driver, Function() callback,
    Function(String) callbackError) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";
  var url = '${serverPath}changeDriver';
  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': "application/json",
    'Authorization': "Bearer ${uid}",
  };
  var body = json.encoder.convert({"id": id, "driver": driver});
  try {
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult['ret'] == true)
        callback();
      else
        callbackError(jsonResult['ret']);
    } else
      callbackError("statusCode=${response.statusCode}");
  } catch (ex) {
    callbackError(ex.toString());
  }
}

}
