import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
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
      return status == 1
          ? restaurant.published == 1
          : restaurant.published == 0;
    }).toList();
  }

  // Mettre à jour les heures d'ouverture d'un restaurant
  Future<void> updateRestaurantOpeningHours(int restaurantId,
      Map<String, String> hoursData, Function(bool, String?) callback) async {
    try {
      // Appel de votre API pour mettre à jour les heures
      final response = await updateRestaurantHours(
        restaurantId: restaurantId,
        hoursData: hoursData,
      );

      if (response['success'] == true) {
        // Mettre à jour localement si nécessaire
        final index = _restaurantData
            .indexWhere((restaurant) => restaurant.id == restaurantId);
        if (index != -1) {
          // Créer une nouvelle instance avec les heures mises à jour
          final existingRestaurant = _restaurantData[index];

          print("hoursData_________");
          print(hoursData);
          print(hoursData['openTimeMonday']);
          _restaurantData[index] = RestaurantData(
              id: existingRestaurant.id,
              name: existingRestaurant.name,
              image: existingRestaurant.image,
              published: existingRestaurant.published,
              updatedAt: existingRestaurant.updatedAt,
              // Nouvelles heures d'ouverture
              openTimeMonday: hoursData['openTimeMonday'] ??
                  existingRestaurant.openTimeMonday,
              closeTimeMonday: hoursData['closeTimeMonday'] ??
                  existingRestaurant.closeTimeMonday,
              openTimeTuesday: hoursData['openTimeTuesday'] ??
                  existingRestaurant.openTimeTuesday,
              closeTimeTuesday: hoursData['closeTimeTuesday'] ??
                  existingRestaurant.closeTimeTuesday,
              openTimeWednesday: hoursData['openTimeWednesday'] ??
                  existingRestaurant.openTimeWednesday,
              closeTimeWednesday: hoursData['closeTimeWednesday'] ??
                  existingRestaurant.closeTimeWednesday,
              openTimeThursday: hoursData['openTimeThursday'] ??
                  existingRestaurant.openTimeThursday,
              closeTimeThursday: hoursData['closeTimeThursday'] ??
                  existingRestaurant.closeTimeThursday,
              openTimeFriday: hoursData['openTimeFriday'] ??
                  existingRestaurant.openTimeFriday,
              closeTimeFriday: hoursData['closeTimeFriday'] ??
                  existingRestaurant.closeTimeFriday,
              openTimeSaturday: hoursData['openTimeSaturday'] ??
                  existingRestaurant.openTimeSaturday,
              closeTimeSaturday: hoursData['closeTimeSaturday'] ??
                  existingRestaurant.closeTimeSaturday,
              openTimeSunday: hoursData['openTimeSunday'] ??
                  existingRestaurant.openTimeSunday,
              closeTimeSunday: hoursData['closeTimeSunday'] ??
                  existingRestaurant.closeTimeSunday,
              createdAt: existingRestaurant.createdAt,
              user: existingRestaurant.user,
              restaurant: existingRestaurant.restaurant,
              delivered: existingRestaurant.delivered,
              phone: existingRestaurant.phone,
              mobilePhone: existingRestaurant.mobilePhone,
              address: existingRestaurant.address,
              lat: existingRestaurant.lat,
              lng: existingRestaurant.lng,
              imageId: existingRestaurant.imageId,
              desc: existingRestaurant.desc,
              fee: existingRestaurant.fee,
              percent: existingRestaurant.percent,
              is_pause: existingRestaurant.is_pause
              // Autres champs existants...
              );

          notifyListeners();
        }

        callback(true, response['message']);
      } else {
        callback(false, response['error']);
      }
    } catch (e) {
      print('Error updating restaurant hours: $e');
      callback(false, 'Erreur de connexion: ${e.toString()}');
    }
  }

  // Mettre à jour le statut de pause d'un restaurant
  // Mettre à jour le statut de pause d'un restaurant
  Future<void> updateRestaurantPauseStatus(
      int restaurantId, bool isPaused, Function(bool, String?) callback) async {
    try {
      // Appel de votre API pour mettre à jour le statut de pause
      final response = await updateRestaurantPause(
        restaurantId: restaurantId,
        isPaused: isPaused,
      );

      if (response['success'] == true) {
        // Mettre à jour localement le champ is_pause
        final index = _restaurantData
            .indexWhere((restaurant) => restaurant.id == restaurantId);
        if (index != -1) {
          final existingRestaurant = _restaurantData[index];

          _restaurantData[index] = RestaurantData(
              id: existingRestaurant.id,
              name: existingRestaurant.name,
              image: existingRestaurant.image,
              published: existingRestaurant.published,
              updatedAt: existingRestaurant.updatedAt,
              is_pause: isPaused ? 1 : 0, // Mise à jour du statut de pause
              // Heures d'ouverture existantes
              openTimeMonday: existingRestaurant.openTimeMonday,
              closeTimeMonday: existingRestaurant.closeTimeMonday,
              openTimeTuesday: existingRestaurant.openTimeTuesday,
              closeTimeTuesday: existingRestaurant.closeTimeTuesday,
              openTimeWednesday: existingRestaurant.openTimeWednesday,
              closeTimeWednesday: existingRestaurant.closeTimeWednesday,
              openTimeThursday: existingRestaurant.openTimeThursday,
              closeTimeThursday: existingRestaurant.closeTimeThursday,
              openTimeFriday: existingRestaurant.openTimeFriday,
              closeTimeFriday: existingRestaurant.closeTimeFriday,
              openTimeSaturday: existingRestaurant.openTimeSaturday,
              closeTimeSaturday: existingRestaurant.closeTimeSaturday,
              openTimeSunday: existingRestaurant.openTimeSunday,
              closeTimeSunday: existingRestaurant.closeTimeSunday,
              createdAt: existingRestaurant.createdAt,
              user: existingRestaurant.user,
              delivered: existingRestaurant.delivered,
              restaurant: existingRestaurant.restaurant,
              phone: existingRestaurant.phone,
              mobilePhone: existingRestaurant.mobilePhone,
              address: existingRestaurant.address,
              lat: existingRestaurant.lat,
              lng: existingRestaurant.lng,
              imageId: existingRestaurant.imageId,
              desc: existingRestaurant.desc,
              fee: existingRestaurant.fee,
              percent: existingRestaurant.percent
              // Autres champs existants...
              );

          notifyListeners();
        }

        callback(true, response['message']);
      } else {
        callback(false, response['error']);
      }
    } catch (e) {
      print('Error updating restaurant pause status: $e');
      callback(false, 'Erreur de connexion: ${e.toString()}');
    }
  }

  // Vérifier si un restaurant est actuellement ouvert
  bool isRestaurantCurrentlyOpen(RestaurantData restaurant) {
    final now = DateTime.now();
    final currentDay = _getCurrentDayIndex(now.weekday);
    final currentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    String? openTime;
    String? closeTime;

    switch (currentDay) {
      case 1: // Lundi
        openTime = restaurant.openTimeMonday;
        closeTime = restaurant.closeTimeMonday;
        break;
      case 2: // Mardi
        openTime = restaurant.openTimeTuesday;
        closeTime = restaurant.closeTimeTuesday;
        break;
      case 3: // Mercredi
        openTime = restaurant.openTimeWednesday;
        closeTime = restaurant.closeTimeWednesday;
        break;
      case 4: // Jeudi
        openTime = restaurant.openTimeThursday;
        closeTime = restaurant.closeTimeThursday;
        break;
      case 5: // Vendredi
        openTime = restaurant.openTimeFriday;
        closeTime = restaurant.closeTimeFriday;
        break;
      case 6: // Samedi
        openTime = restaurant.openTimeSaturday;
        closeTime = restaurant.closeTimeSaturday;
        break;
      case 7: // Dimanche
        openTime = restaurant.openTimeSunday;
        closeTime = restaurant.closeTimeSunday;
        break;
    }

    // Vérifier si le restaurant est fermé ce jour
    if (openTime == null ||
        closeTime == null ||
        openTime.isEmpty ||
        closeTime.isEmpty ||
        (openTime == '00:00' && closeTime == '00:00')) {
      return false;
    }

    // Comparer les heures
    return _isTimeInRange(currentTime, openTime, closeTime);
  }

  // Convertir le jour de la semaine (DateTime.weekday) vers notre index
  int _getCurrentDayIndex(int weekday) {
    // DateTime.weekday: Lundi=1, Mardi=2, ..., Dimanche=7
    return weekday;
  }

  // Vérifier si l'heure actuelle est dans la plage d'ouverture
  bool _isTimeInRange(String currentTime, String openTime, String closeTime) {
    try {
      final current = _timeToMinutes(currentTime);
      final open = _timeToMinutes(openTime);
      final close = _timeToMinutes(closeTime);

      // Cas normal (ex: 08:00-22:00)
      if (close > open) {
        return current >= open && current <= close;
      }
      // Cas où le restaurant ferme après minuit (ex: 22:00-02:00)
      else {
        return current >= open || current <= close;
      }
    } catch (e) {
      print('Error parsing time: $e');
      return false;
    }
  }

  // Convertir une heure (HH:MM) en minutes depuis minuit
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  // Obtenir le statut d'un restaurant (ouvert/fermé/en pause)
  String getRestaurantStatus(RestaurantData restaurant) {
    // Si vous avez un champ isPaused
    // if (restaurant.isPaused == true) return 'En pause';

    if (isRestaurantCurrentlyOpen(restaurant)) {
      return 'Ouvert';
    } else {
      return 'Fermé';
    }
  }

  // Obtenir la couleur associée au statut
  Color getRestaurantStatusColor(RestaurantData restaurant) {
    final status = getRestaurantStatus(restaurant);
    switch (status) {
      case 'Ouvert':
        return Colors.green;
      case 'En pause':
        return Colors.orange;
      case 'Fermé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Obtenir l'icône associée au statut
  IconData getRestaurantStatusIcon(RestaurantData restaurant) {
    final status = getRestaurantStatus(restaurant);
    switch (status) {
      case 'Ouvert':
        return Icons.check_circle;
      case 'En pause':
        return Icons.pause_circle;
      case 'Fermé':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Vérifier si un restaurant est en pause
  bool isRestaurantPaused(RestaurantData restaurant) {
    return restaurant.is_pause == 1;
  }
}
