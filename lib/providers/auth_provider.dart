import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';

class AuthProvider with ChangeNotifier {
  bool _loading = false;
  bool _error = false;
  String _errorMessage = "";

  bool get loading => _loading;
  bool get error => _error;
  String get errorMessage => _errorMessage;

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
      saveUserDataToSharedPreferences(userData, password, uuid, notify);
    }

    _loading = false;
    notifyListeners();
  }
}
