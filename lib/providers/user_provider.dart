import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _email = '';
  int _userRole = 0;
  int _userImageId = 0;
  String _userPhone = '';
  String _userAvatar = '';
  String _uuid = '';
  String _userAddress = '';

  // ✅ Nouvelles propriétés pour les restaurants
  List<String> _userRestaurants = [];
  int _restaurantCount = 0;
  int _defaultRestaurantId = 0;

  String get name => _name;
  String get email => _email;
  int get userRole => _userRole;
  int get userImageId => _userImageId;
  String get userPhone => _userPhone;
  String get userAvatar => _userAvatar;
  String get uuid => _uuid;
  String get userAddress => _userAddress;

  // ✅ Nouveaux getters pour les restaurants
  List<String> get userRestaurants => _userRestaurants;
  List<int> get userRestaurantsAsInt =>
      _userRestaurants.map((e) => int.tryParse(e) ?? 0).toList();
  int get restaurantCount => _restaurantCount;
  int get defaultRestaurantId => _defaultRestaurantId;
  bool get hasRestaurants => _userRestaurants.isNotEmpty;

  // Vérifier si l'utilisateur peut gérer un restaurant spécifique
  bool canManageRestaurant(int restaurantId) {
    return userRestaurantsAsInt.contains(restaurantId);
  }

  // Obtenir le premier restaurant (par défaut)
  int? get firstRestaurantId {
    if (userRestaurantsAsInt.isNotEmpty) {
      return userRestaurantsAsInt.first;
    }
    return null;
  }

  // Vérifier les rôles
  bool get isAdmin => _userRole == 1;
  bool get isManager => _userRole == 2;
  bool get isDriver => _userRole == 3;
  bool get isClient => _userRole == 4;
  bool get isOwner => _userRole == 5;
  bool get canManageRestaurants => isAdmin || isManager || isOwner;

  Future<void> loadUserData() async {
    print("load user data");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('userName') ?? 'Unknown User';
    _email = prefs.getString('userEmail') ?? 'Unknown Email';
    _userRole = prefs.getInt('userRole') ?? 0;
    _userImageId = prefs.getInt('userImageId') ?? 0;
    _userPhone = prefs.getString('userPhone') ?? '';
    _userAvatar = prefs.getString('userAvatar') ?? '';
    _uuid = prefs.getString('uuid') ?? '';
    _userAddress = prefs.getString('userAddress') ?? '';

    // ✅ Charger les nouvelles données restaurants
    _userRestaurants = prefs.getStringList('userRestaurants') ?? [];
    _restaurantCount = prefs.getInt('restaurantCount') ?? 0;
    _defaultRestaurantId = prefs.getInt('defaultRestaurantId') ?? 0;
    notifyListeners();
    print("load user data ok");
  }

  // ✅ Méthode pour forcer le rechargement des données
  Future<void> refreshUserData() async {
    await loadUserData();
  }

  // ✅ Mettre à jour le restaurant par défaut
  Future<void> setDefaultRestaurant(int restaurantId) async {
    if (canManageRestaurant(restaurantId)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('defaultRestaurantId', restaurantId);
      _defaultRestaurantId = restaurantId;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Réinitialiser toutes les variables
    _name = '';
    _email = '';
    _userRole = 0;
    _userImageId = 0;
    _userPhone = '';
    _userAvatar = '';
    _uuid = '';
    _userAddress = '';
    _userRestaurants = [];
    _restaurantCount = 0;
    _defaultRestaurantId = 0;
    notifyListeners();
  }

  // ✅ Méthode debug pour afficher les données
  void printUserData() {
    print('=== USER DATA ===');
    print('Name: $_name');
    print('Role: $_userRole');
    print('Restaurants: $_userRestaurants');
    print('Restaurant Count: $_restaurantCount');
    print('Default Restaurant: $_defaultRestaurantId');
    print('Can Manage Restaurants: $canManageRestaurants');
    print('=================');
  }
}
