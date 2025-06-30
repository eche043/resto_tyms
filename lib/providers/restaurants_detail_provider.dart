// lib/providers/restaurants_detail_provider.dart
import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/model/restaurant_ranking.dart';

class RestaurantsDetailProvider with ChangeNotifier {
  List<RestaurantRanking> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  // Filtres
  String _searchQuery = '';
  int _statusFilter = 0; // 0: Tous, 1: Actifs, 2: Inactifs
  String _sortBy = 'orders'; // 'orders', 'revenue', 'name'
  bool _sortAscending = false;

  // Getters
  List<RestaurantRanking> get restaurants => _getFilteredAndSortedRestaurants();
  List<RestaurantRanking> get allRestaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get statusFilter => _statusFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  // Statistiques calculées
  int get totalRestaurants => _restaurants.length;
  int get activeRestaurants =>
      _restaurants.where((r) => r.published == 1).length;
  int get inactiveRestaurants =>
      _restaurants.where((r) => r.published == 0).length;
  int get totalOrders => _restaurants.fold(0, (sum, r) => sum + r.ordersCount);
  double get totalRevenue =>
      _restaurants.fold(0.0, (sum, r) => sum + r.totalRevenue);
  double get averageOrdersPerRestaurant =>
      totalRestaurants > 0 ? totalOrders / totalRestaurants : 0;
  double get averageRevenuePerRestaurant =>
      totalRestaurants > 0 ? totalRevenue / totalRestaurants : 0;

  /// Charger les données des restaurants
  Future<void> loadRestaurants({
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await getRestaurantRankings(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _restaurants =
            data.map((item) => RestaurantRanking.fromJson(item)).toList();

        print(
            'Restaurants loaded successfully: ${_restaurants.length} restaurants');
        print('Active: $activeRestaurants, Inactive: $inactiveRestaurants');
      } else {
        _setError(
            response['error'] ?? 'Erreur lors du chargement des restaurants');
      }
    } catch (e) {
      print('Error loading restaurants: $e');
      _setError('Erreur de connexion: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Mettre à jour la recherche
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  /// Mettre à jour le filtre de statut
  void updateStatusFilter(int filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  /// Mettre à jour le tri
  void updateSort(String sortBy, {bool? ascending}) {
    if (_sortBy == sortBy) {
      _sortAscending = ascending ?? !_sortAscending;
    } else {
      _sortBy = sortBy;
      _sortAscending = ascending ?? false;
    }
    notifyListeners();
  }

  /// Obtenir les restaurants filtrés et triés
  List<RestaurantRanking> _getFilteredAndSortedRestaurants() {
    List<RestaurantRanking> filtered = List.from(_restaurants);

    // Filtrer par statut
    if (_statusFilter == 1) {
      filtered = filtered.where((r) => r.published == 1).toList();
    } else if (_statusFilter == 2) {
      filtered = filtered.where((r) => r.published == 0).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((r) => r.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Trier
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'orders':
          comparison = a.ordersCount.compareTo(b.ordersCount);
          break;
        case 'revenue':
          comparison = a.totalRevenue.compareTo(b.totalRevenue);
          break;
        case 'status':
          comparison = a.published.compareTo(b.published);
          break;
        default:
          comparison = a.ordersCount.compareTo(b.ordersCount);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  /// Basculer le statut d'un restaurant
  Future<bool> toggleRestaurantStatus(int restaurantId) async {
    try {
      // Ici vous ajouteriez l'appel API pour changer le statut
      // final response = await updateRestaurantStatus(restaurantId);

      // Pour l'instant, simuler le changement localement
      final index = _restaurants.indexWhere((r) => r.id == restaurantId);
      if (index != -1) {
        final restaurant = _restaurants[index];
        _restaurants[index] = RestaurantRanking(
          id: restaurant.id,
          name: restaurant.name,
          published: restaurant.published == 1 ? 0 : 1,
          ordersCount: restaurant.ordersCount,
          totalRevenue: restaurant.totalRevenue,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling restaurant status: $e');
      return false;
    }
  }

  /// Supprimer un restaurant
  Future<bool> deleteRestaurant(int restaurantId) async {
    try {
      // Ici vous ajouteriez l'appel API pour supprimer
      // final response = await deleteRestaurant(restaurantId);

      // Pour l'instant, simuler la suppression localement
      _restaurants.removeWhere((r) => r.id == restaurantId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting restaurant: $e');
      return false;
    }
  }

  /// Obtenir les statistiques d'évolution
  Map<String, dynamic> getEvolutionStats() {
    // Simulation des données d'évolution
    // Dans une vraie app, vous récupéreriez ces données depuis l'API
    return {
      'current_month': totalRestaurants,
      'previous_month': totalRestaurants - 5,
      'growth_percentage': 12.5,
      'growth_positive': true,
    };
  }

  /// Obtenir le top des restaurants par critère
  List<RestaurantRanking> getTopRestaurants({
    required String criteria, // 'orders' ou 'revenue'
    int limit = 5,
  }) {
    List<RestaurantRanking> sorted = List.from(_restaurants);

    if (criteria == 'orders') {
      sorted.sort((a, b) => b.ordersCount.compareTo(a.ordersCount));
    } else if (criteria == 'revenue') {
      sorted.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    }

    return sorted.take(limit).toList();
  }

  /// Obtenir les restaurants récemment ajoutés
  List<RestaurantRanking> getRecentlyAddedRestaurants({int limit = 5}) {
    // Dans une vraie app, vous trieriez par date de création
    // Pour l'instant, retourner les derniers de la liste
    return _restaurants.take(limit).toList();
  }

  /// Méthodes privées utilitaires
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Rafraîchir les données
  Future<void> refresh() async {
    await loadRestaurants();
  }

  /// Réinitialiser les filtres
  void resetFilters() {
    _searchQuery = '';
    _statusFilter = 0;
    _sortBy = 'orders';
    _sortAscending = false;
    notifyListeners();
  }

  /// Exporter les données (simulation)
  Future<String> exportData({String format = 'csv'}) async {
    try {
      // Simulation de l'export
      final restaurants = _getFilteredAndSortedRestaurants();

      if (format == 'csv') {
        String csv = 'Nom,Statut,Commandes,Revenus\n';
        for (final restaurant in restaurants) {
          csv +=
              '${restaurant.name},${restaurant.published == 1 ? 'Actif' : 'Inactif'},${restaurant.ordersCount},${restaurant.totalRevenue}\n';
        }
        return csv;
      }

      return 'Export réussi';
    } catch (e) {
      throw Exception('Erreur lors de l\'export: $e');
    }
  }
}
