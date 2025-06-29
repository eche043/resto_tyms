import 'package:flutter/material.dart';
import 'package:odrive_restaurant/model/role.dart';

class RoleProvider extends ChangeNotifier {
  UserRole? _selectedRole;

  UserRole? get selectedRole => _selectedRole;

  void selectRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void clearRole() {
    _selectedRole = null;
    notifyListeners();
  }
}
