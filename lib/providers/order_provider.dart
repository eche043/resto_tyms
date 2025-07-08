import 'dart:async';
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

  // Nouvelles propriétés pour la gestion des délais
  Map<int, Timer> _preparingTimers = {};
  Map<int, DateTime> _acceptedTimes = {};

  // Getters pour les nouvelles propriétés
  Map<int, DateTime> get acceptedTimes => _acceptedTimes;

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

    try {
      var response = await getOrders();
      notifyListeners();
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

  Future<void> changeStatus(String orderId, String status,
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
      var response =
          await http.post(Uri.parse(url), headers: requestHeaders, body: body);
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

  /// Méthode pour accepter une commande (mettre is_accept à 1)
  void acceptOrder(
      String orderId, Function() onSuccess, Function(String) onError) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";

    try {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': "application/json",
        'Authorization': "Bearer $uid",
      };

      var body = json.encoder.convert({"order_id": orderId});
      var url = '${serverPath}acceptOrder'; // Adaptez selon votre API

      var response =
          await http.post(Uri.parse(url), headers: requestHeaders, body: body);

      print('Accept Order Response status: ${response.statusCode}');
      print('Accept Order Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        if (jsonResult['error'] == "0" || jsonResult['success'] == true) {
          print("commade acceptation ok111");
          print(_orderData);
          print("commade acceptation ok11122");
          // Mettre à jour localement
          final orderIdInt = int.tryParse(orderId) ?? 0;
          final orderIndex =
              _orderData.indexWhere((order) => order.id == orderIdInt);
          print("commade acceptation ok111223333");
          print(orderIndex);
          if (orderIndex != -1) {
            print("if 111111");
            _orderData[orderIndex].is_accept = 1;
            print("if 22222");
            _orderData[orderIndex].updatedAt = DateTime.now().toString();
            print("if 3333");
          }
          print("commade acceptation ok");

          onSuccess();
          notifyListeners();
        } else {
          onError(jsonResult['error']?.toString() ??
              "Erreur lors de l'acceptation");
        }
      } else {
        onError("Erreur de connexion (${response.statusCode})");
      }
    } catch (ex) {
      onError(ex.toString());
    }
  }

  /// Démarrer le timer pour une commande acceptée
  void startPreparingTimer(int orderId) {
    // Enregistrer l'heure d'acceptation
    _acceptedTimes[orderId] = DateTime.now();

    // Annuler le timer existant s'il y en a un
    _preparingTimers[orderId]?.cancel();

    // Démarrer un nouveau timer de 5 minutes
    /* _preparingTimers[orderId] = Timer(const Duration(minutes: 5), () {
      // Après 5 minutes, notifier que la commande est en retard
      print('Commande $orderId en retard pour la préparation');
      notifyListeners();
    }); */

    notifyListeners();
  }

  /// Arrêter le timer quand la commande passe en préparation
  void stopPreparingTimer(int orderId) {
    _preparingTimers[orderId]?.cancel();
    _preparingTimers.remove(orderId);
    _acceptedTimes.remove(orderId);
    notifyListeners();
  }

  /// Vérifier si une commande est en retard
  bool isOrderOverdue(int orderId) {
    final acceptedTime = _acceptedTimes[orderId];
    if (acceptedTime == null) return false;

    final now = DateTime.now();
    final difference = now.difference(acceptedTime);
    return difference.inMinutes > 5;
  }

  /// Obtenir le temps écoulé depuis l'acceptation
  int getMinutesSinceAccepted(int orderId) {
    final acceptedTime = _acceptedTimes[orderId];
    if (acceptedTime == null) return 0;

    final now = DateTime.now();
    return now.difference(acceptedTime).inMinutes;
  }

  /// Méthode améliorée pour changer le statut avec gestion des timers
  void changeStatusWithTimer(String orderId, String status,
      Function() onSuccess, Function(String) onError) {
    final orderIdInt = int.tryParse(orderId) ?? 0;

    changeStatus(orderId, status, () {
      // Gérer les timers selon le nouveau statut
      switch (status) {
        case "2": // Preparing
          stopPreparingTimer(orderIdInt);
          break;
        case "3": // Ready
        case "4": // On the way
        case "5": // Delivered
        case "6": // Cancelled
          stopPreparingTimer(orderIdInt);
          break;
      }

      onSuccess();
    }, onError);
  }

  /// Obtenir les commandes par statut et is_accept avec tri
  List<Order> getOrdersByStatusAndAccept(int status, int isAccept) {
    return _orderData
        .where((order) => order.status == status && order.is_accept == isAccept)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Obtenir les nouvelles commandes (statut 1, is_accept 0, les 3 plus récentes)
  List<Order> getNewOrders({int limit = 3}) {
    return getOrdersByStatusAndAccept(1, 0).take(limit).toList();
  }

  /// Obtenir les commandes en progression
  List<Order> getInProgressOrders() {
    // Commandes acceptées mais pas encore en préparation (statut 1, is_accept 1)
    final acceptedOrders = getOrdersByStatusAndAccept(1, 1);

    // Commandes en préparation (statut 2)
    final preparingOrders =
        _orderData.where((order) => order.status == 2).toList();

    // Commandes prêtes (statut 3)
    final readyOrders = _orderData.where((order) => order.status == 3).toList();

    final allInProgress = [
      ...acceptedOrders,
      ...preparingOrders,
      ...readyOrders
    ];
    allInProgress.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return allInProgress;
  }

  /// Nettoyer les timers lors de la suppression du provider
  @override
  void dispose() {
    // Annuler tous les timers actifs
    for (var timer in _preparingTimers.values) {
      timer.cancel();
    }
    _preparingTimers.clear();
    _acceptedTimes.clear();
    super.dispose();
  }

  /// Rafraîchir automatiquement les commandes
  Timer? _autoRefreshTimer;

  void startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      fetchOrders();
    });
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Méthode pour vérifier les commandes en retard
  List<Order> getOverdueOrders() {
    return _orderData.where((order) {
      return order.status == 1 &&
          order.is_accept == 1 &&
          isOrderOverdue(order.id);
    }).toList();
  }

  /// Obtenir le statut d'affichage d'une commande
  Map<String, dynamic> getOrderDisplayStatus(Order order) {
    if (order.status == 1 && order.is_accept == 0) {
      return {
        'text': 'New',
        'color': Colors.orange,
        'action': 'accept',
      };
    } else if (order.status == 1 && order.is_accept == 1) {
      final minutesSinceAccept = getMinutesSinceAccepted(order.id);
      final isOverdue = minutesSinceAccept > 5;
      return {
        'text': 'Accepted',
        'color': isOverdue ? Colors.red : Colors.blue,
        'action': 'prepare',
        'time': minutesSinceAccept,
        'overdue': isOverdue,
      };
    } else if (order.status == 2) {
      return {
        'text': 'Preparing',
        'color': Colors.orange,
        'action': 'ready',
      };
    } else if (order.status == 3) {
      return {
        'text': 'Ready',
        'color': Colors.green,
        'action': 'assign_driver',
      };
    } else {
      return {
        'text': 'Unknown',
        'color': Colors.grey,
        'action': null,
      };
    }
  }
}
