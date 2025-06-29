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

  String get name => _name;
  String get email => _email;
  int get userRole => _userRole;
  int get userImageId => _userImageId;
  String get userPhone => _userPhone;
  String get userAvatar => _userAvatar;
  String get uuid => _uuid;
  String get userAddress => _userAddress;

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('userName') ?? 'Unknown User';
    _email = prefs.getString('userEmail') ?? 'Unknown Email';
    _userRole = prefs.getInt('userRole') ?? 0;
    _userImageId = prefs.getInt('userImageId') ?? 0;
    _userPhone = prefs.getString('userPhone') ?? '';
    _userAvatar = prefs.getString('userAvatar') ?? '';
    _uuid = prefs.getString('uuid') ?? '';
    _userAddress = prefs.getString('userAddress') ?? '';
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
