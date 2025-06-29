// lib/models/role.dart

enum UserRole {
  restaurant,
  market,
  supermarket,
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.restaurant:
        return 'Restaurant';
      case UserRole.market:
        return 'Market';
      case UserRole.supermarket:
        return 'Supermarket';
    }
  }

  /// Clé de traduction pour l'internationalisation
  String get translationKey {
    switch (this) {
      case UserRole.restaurant:
        return 'restaurant';
      case UserRole.market:
        return 'market';
      case UserRole.supermarket:
        return 'supermarket';
    }
  }

  /// Détermine si le rôle est disponible
  /// Pour l'instant, seul le restaurant est disponible
  bool get isAvailable {
    return this == UserRole.restaurant;
  }

  /// Chemin vers l'image d'illustration du rôle
  String get imagePath {
    switch (this) {
      case UserRole.restaurant:
        return 'assets/images/restaurant_illustration.png';
      case UserRole.market:
        return 'assets/images/market_illustration.png';
      case UserRole.supermarket:
        return 'assets/images/supermarket_illustration.png';
    }
  }

  /// Icône associée au rôle
  String get iconName {
    switch (this) {
      case UserRole.restaurant:
        return 'restaurant';
      case UserRole.market:
        return 'storefront';
      case UserRole.supermarket:
        return 'shopping_cart';
    }
  }

  /// Couleur associée au rôle
  String get colorHex {
    switch (this) {
      case UserRole.restaurant:
        return '#FF9800'; // Orange
      case UserRole.market:
        return '#2196F3'; // Blue
      case UserRole.supermarket:
        return '#4CAF50'; // Green
    }
  }
}
