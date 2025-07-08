// lib/providers/auth_provider.dart - Corriger pour recharger UserProvider

import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/providers/user_provider.dart'; // ✅ Ajouter cet import

class AuthProvider with ChangeNotifier {
  bool _loading = false;
  bool _error = false;
  String _errorMessage = "";
  UserProvider? _userProvider; // ✅ Référence au UserProvider

  bool get loading => _loading;
  bool get error => _error;
  String get errorMessage => _errorMessage;

  // ✅ Setter pour injecter UserProvider
  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  Future<void> loginUser(String email, String password) async {
    _loading = true;
    notifyListeners();

    dynamic response = await login(email, password);

    if (response["error"] == 1) {
      _error = true;
      _errorMessage = response["message"];
    } else {
      _error = false;
      var userData = response['user'];
      var uuid = response['access_token'];
      var notify = response['notify'];
      var restoData = response["restaurants"];

      print("restoData*********");
      print(restoData);

      // Sauvegarder dans SharedPreferences
      saveUserDataToSharedPreferences(userData, password, uuid, notify,
          restaurants: restoData);

      // ✅ Recharger les données dans UserProvider
      if (_userProvider != null) {
        await _userProvider!.loadUserData();
        _userProvider!.printUserData(); // Debug
      }
    }

    _loading = false;
    notifyListeners();
  }
}
