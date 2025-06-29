import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/model/filter_period.dart';
import 'package:odrive_restaurant/model/order_evolution.dart';
import 'package:odrive_restaurant/model/restaurant_ranking.dart';
import 'package:odrive_restaurant/model/statDashboard.dart';
import 'package:odrive_restaurant/model/statistic_data.dart';
import 'package:odrive_restaurant/model/top_food.dart';

class DashboardProvider with ChangeNotifier {
  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;

  FilterPeriod _selectedPeriod = FilterPeriod.lastUpdated;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Données des totaux depuis l'API
  int _totalOrders = 0;
  int _totalRestaurants = 0;
  double _totalEarnings = 0.0;
  int _totalFoods = 0;
  String _currencySymbol = 'FCFA';
  bool _rightSymbol = true;
  int _symbolDigits = 0;

  // Données d'évolution des commandes
  List<OrdersEvolution> _ordersEvolution = [];
  String _evolutionPeriod = 'month';

  // Données des classements des restaurants
  List<RestaurantRanking> _restaurantRankings = [];
  bool _isLoadingRankings = false;

  // Données des produits populaires
  List<TopFood> _topFoods = [];
  TopFoodSummary? _topFoodSummary;
  bool _isLoadingTopFoods = false;

  // Getters
  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FilterPeriod get selectedPeriod => _selectedPeriod;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  int get totalOrders => _totalOrders;
  int get totalRestaurants => _totalRestaurants;
  double get totalEarnings => _totalEarnings;
  int get totalFoods => _totalFoods;
  String get currency => _currencySymbol;
  bool get rightSymbol => _rightSymbol;
  int get symbolDigits => _symbolDigits;

  List<OrdersEvolution> get ordersEvolution => _ordersEvolution;

  List<RestaurantRanking> get restaurantRankings => _restaurantRankings;
  bool get isLoadingRankings => _isLoadingRankings;

  List<TopFood> get topFoods => _topFoods;
  TopFoodSummary? get topFoodSummary => _topFoodSummary;
  bool get isLoadingTopFoods => _isLoadingTopFoods;

  /// Initialiser le dashboard avec des données depuis l'API
  Future<void> initializeDashboard() async {
    _setLoading(true);
    _clearError();

    try {
      // Charger les totaux depuis l'API
      await loadTotals();

      // Charger l'évolution des commandes
      await loadOrdersEvolution();

      // Charger les classements des restaurants
      await loadRestaurantRankings();

      // Charger les produits populaires
      await loadTopFoods();

      // Charger le reste des données (pour le moment mock)
      //await loadDashboardData();
      _stats = _createStatsWithRealData();
    } catch (e) {
      _setError('Erreur lors du chargement des données');
      print('Error initializing dashboard: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les totaux depuis l'API
  Future<void> loadTotals() async {
    try {
      final response = await getTotals();

      if (response['success'] == true) {
        final data = response['data'];
        _totalOrders = data['total_orders'] ?? 0;
        _totalRestaurants = data['total_restaurants'] ?? 0;
        _totalEarnings = data['total_earnings'] ?? 0.0;
        _totalFoods = data['total_foods'] ?? 0;
        _currencySymbol = data['currency_symbol'] ?? 'FCFA';
        _rightSymbol = data['right_symbol'] ?? true;
        _symbolDigits = data['symbol_digits'] ?? 0;

        print('Totals loaded successfully:');
        print(
            'Orders: $_totalOrders, Restaurants: $_totalRestaurants, Earnings: $_totalEarnings');

        notifyListeners();
      } else {
        _setError(response['error'] ?? 'Erreur lors du chargement des totaux');
      }
    } catch (e) {
      print('Error loading totals: $e');
      _setError('Erreur de connexion lors du chargement des totaux');
    }
  }

  /// Charger l'évolution des commandes depuis l'API
  Future<void> loadOrdersEvolution({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await getOrdersEvolution(
        period: period,
        startDate: startDate,
        endDate: endDate,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _ordersEvolution =
            data.map((item) => OrdersEvolution.fromJson(item)).toList();
        _evolutionPeriod = response['period'] ?? 'month';

        // Mettre à jour la devise si elle est fournie
        if (response['currency'] != null) {
          _currencySymbol = response['currency'];
        }

        print(
            'Orders evolution loaded successfully: ${_ordersEvolution.length} periods');

        notifyListeners();
      } else {
        print('Error loading orders evolution: ${response['error']}');
      }
    } catch (e) {
      print('Error loading orders evolution: $e');
    }
  }

  /// Charger les classements des restaurants depuis l'API
  Future<void> loadRestaurantRankings({
    String? startDate,
    String? endDate,
    int limit = 5,
  }) async {
    _isLoadingRankings = true;
    notifyListeners();

    try {
      final response = await getRestaurantRankings(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _restaurantRankings =
            data.map((item) => RestaurantRanking.fromJson(item)).toList();

        // Mettre à jour la devise si elle est fournie
        if (response['currency'] != null) {
          _currencySymbol = response['currency'];
        }

        print(
            'Restaurant rankings loaded successfully: ${_restaurantRankings.length} restaurants');
        print(
            'Rankings: ${_restaurantRankings.map((r) => '${r.name}: ${r.ordersCount} orders').join(', ')}');
      } else {
        print('Error loading restaurant rankings: ${response['error']}');
      }
    } catch (e) {
      print('Error loading restaurant rankings: $e');
    } finally {
      _isLoadingRankings = false;
      notifyListeners();
    }
  }

  /// Charger les produits populaires depuis l'API
  Future<void> loadTopFoods({
    int limit = 5,
    int? restaurantId,
    String? startDate,
    String? endDate,
  }) async {
    _isLoadingTopFoods = true;
    notifyListeners();

    try {
      final response = await getTopFoods(
        limit: limit,
        restaurantId: restaurantId,
        startDate: startDate,
        endDate: endDate,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _topFoods = data.map((item) => TopFood.fromJson(item)).toList();

        // Charger le résumé
        if (response['summary'] != null) {
          _topFoodSummary = TopFoodSummary.fromJson(response['summary']);
        }

        // Mettre à jour la devise si elle est fournie
        if (response['currency'] != null) {
          _currencySymbol = response['currency'];
        }

        print('Top foods loaded successfully: ${_topFoods.length} products');
        print(
            'Top foods: ${_topFoods.map((f) => '${f.foodName}: ${f.totalOrdered} orders').join(', ')}');
      } else {
        print('Error loading top foods: ${response['error']}');
      }
    } catch (e) {
      print('Error loading top foods: $e');
    } finally {
      _isLoadingTopFoods = false;
      notifyListeners();
    }
  }

  /// Créer les statistiques avec les données réelles
  DashboardStats _createStatsWithRealData() {
    final mockData = DashboardStats.getMockData();

    // Convertir les données d'évolution en données de graphique
    final List<StatisticData> chartData = _ordersEvolution
        .map((evolution) => StatisticData(
              month: evolution.formattedPeriod,
              orders: evolution.totalOrders,
              restaurants: _totalRestaurants,
            ))
        .toList();

    // Convertir les classements des restaurants en RankingData
    final List<RankingData> rankingData = _restaurantRankings
        .asMap()
        .entries
        .map<RankingData>((entry) => entry.value
            .toRankingData(currency: _currencySymbol, rank: entry.key + 1))
        .toList();

    // Convertir les produits populaires en BestSellingProduct
    final List<BestSellingProduct> bestSellingProducts = _topFoods
        .map((food) => food.toBestSellingProduct(_currencySymbol))
        .toList();

    // S'assurer qu'on a au moins quelques données avec le bon type
    /* final List<StatisticData> finalChartData =
        chartData.isNotEmpty ? chartData : mockData.chartData; */
    final List<StatisticData> finalChartData = chartData;
    /* final List<RankingData> finalRankingData = rankingData.isNotEmpty
        ? rankingData
        : mockData.ranking.cast<RankingData>(); */
    final List<RankingData> finalRankingData = rankingData;

    /* final finalBestSellingProducts = bestSellingProducts.isNotEmpty
        ? bestSellingProducts
        : mockData.bestSellingProducts; */
    final finalBestSellingProducts = bestSellingProducts;

    return DashboardStats(
      totalOrders: _totalOrders,
      totalRestaurants: _totalRestaurants,
      totalEarnings: _totalEarnings,
      currency: _currencySymbol,
      chartData: finalChartData,
      ranking: finalRankingData,
      bestSellingProducts: finalBestSellingProducts,
      paymentHistory: mockData.paymentHistory, // Mock pour le moment
    );
  }

  /// Rafraîchir les données
  Future<void> refreshData() async {
    await initializeDashboard();
  }

  /// Changer la période de filtre
  void setPeriod(FilterPeriod period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      notifyListeners();

      // Recharger les données avec la nouvelle période
      _loadDataForPeriod(period);
    }
  }

  /// Définir une période personnalisée
  void setCustomPeriod(DateTime startDate, DateTime endDate) {
    _customStartDate = startDate;
    _customEndDate = endDate;
    _selectedPeriod = FilterPeriod.custom;
    notifyListeners();

    // Recharger les données pour la période personnalisée
    _loadDataForCustomPeriod(startDate, endDate);
  }

  /// Charger les données pour une période spécifique
  Future<void> _loadDataForPeriod(FilterPeriod period) async {
    _setLoading(true);

    try {
      String apiPeriod = 'month';
      String? startDate;
      String? endDate;

      final now = DateTime.now();

      switch (period) {
        case FilterPeriod.last7Days:
          apiPeriod = 'day';
          startDate = _formatDateForApi(now.subtract(const Duration(days: 7)));
          endDate = _formatDateForApi(now);
          break;
        case FilterPeriod.last30Days:
          apiPeriod = 'day';
          startDate = _formatDateForApi(now.subtract(const Duration(days: 30)));
          endDate = _formatDateForApi(now);
          break;
        case FilterPeriod.lastUpdated:
        default:
          apiPeriod = 'month';
          // Pas de dates spécifiques pour avoir toute l'évolution
          break;
      }

      // Charger l'évolution des commandes
      await loadOrdersEvolution(
        period: apiPeriod,
        startDate: startDate,
        endDate: endDate,
      );

      // Charger les classements pour la même période
      await loadRestaurantRankings(
        startDate: startDate,
        endDate: endDate,
      );

      // Charger les produits populaires pour la même période
      await loadTopFoods(
        startDate: startDate,
        endDate: endDate,
      );

      _stats = _createStatsWithRealData();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des données pour la période');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les données pour une période personnalisée
  Future<void> _loadDataForCustomPeriod(
      DateTime startDate, DateTime endDate) async {
    _setLoading(true);

    try {
      // Déterminer la période selon la durée
      final difference = endDate.difference(startDate).inDays;
      String apiPeriod = 'month';

      if (difference <= 31) {
        apiPeriod = 'day';
      } else if (difference <= 90) {
        apiPeriod = 'week';
      }

      final formattedStartDate = _formatDateForApi(startDate);
      final formattedEndDate = _formatDateForApi(endDate);

      // Charger l'évolution des commandes
      await loadOrdersEvolution(
        period: apiPeriod,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );

      // Charger les classements pour la même période
      await loadRestaurantRankings(
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );

      // Charger les produits populaires pour la même période
      await loadTopFoods(
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );

      _stats = _createStatsWithRealData();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des données personnalisées');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtenir les données des produits populaires formatées
  List<BestSellingProduct> getBestSellingProductsData() {
    return _topFoods
        .map((food) => food.toBestSellingProduct(_currencySymbol))
        .toList();
  }

  /// Formater une date pour l'API (YYYY-MM-DD)
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Obtenir le texte d'affichage de la période
  String getPeriodDisplayText() {
    switch (_selectedPeriod) {
      case FilterPeriod.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return '${_formatDate(_customStartDate!)} - ${_formatDate(_customEndDate!)}';
        }
        return 'Période personnalisée';
      default:
        return _selectedPeriod.displayNameFr;
    }
  }

  /// Formater une date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Obtenir les données du graphique formatées pour le widget de graphique
  List<Map<String, dynamic>> getChartData() {
    return _stats?.chartData
            .map((data) => {
                  'month': data.month,
                  'orders': data.orders,
                  'restaurants': data.restaurants,
                })
            .toList() ??
        [];
  }

  /// Obtenir les données brutes d'évolution des commandes pour le graphique
  List<Map<String, dynamic>> getOrdersEvolutionData() {
    return _ordersEvolution
        .map((evolution) => {
              'month': evolution.formattedPeriod,
              'orders': evolution.totalOrders,
              'revenue': evolution.totalRevenue,
              'average': evolution.averageOrderValue,
              'delivered': evolution.deliveredOrders,
              'cancelled': evolution.cancelledOrders,
            })
        .toList();
  }

  /// Obtenir les données de classement formatées
  List<RankingData> getRankingData() {
    return _restaurantRankings
        .asMap()
        .entries
        .map<RankingData>((entry) => entry.value
            .toRankingData(currency: _currencySymbol, rank: entry.key + 1))
        .toList();
  }

  /// Obtenir les couleurs pour le graphique en secteurs des produits
  List<Color> getProductChartColors() {
    if (_topFoods.isNotEmpty) {
      return _topFoods.map((food) {
        final colorString =
            food.getColorByRanking(food.ranking).replaceAll('#', '');
        return Color(int.parse('FF$colorString', radix: 16));
      }).toList();
    }

    return _stats?.bestSellingProducts.map((product) {
          final colorString = product.color.replaceAll('#', '');
          return Color(int.parse('FF$colorString', radix: 16));
        }).toList() ??
        [];
  }

  /// Charger les vraies données depuis l'API
  /* Future<void> loadDashboardData() async {
    try {
      final response = await _apiService.getStatistics();

      if (response['error'] == '0') {
        // Créer les stats avec les vraies données
        _stats = _createStatsWithRealData();
        notifyListeners();
      } else {
        // En cas d'erreur, utiliser les données réelles disponibles + mock
        _stats = _createStatsWithRealData();
        notifyListeners();
      }
    } catch (e) {
      // En cas d'erreur, créer des stats avec les données réelles disponibles
      print('Error loading dashboard data: $e');
      _stats = _createStatsWithRealData();
      notifyListeners();
    }
  } */

  /* Future<void> fetchTotalsData(String uid) async {
    isLoading = true;
    error = null;
    notifyListeners();

    var url = '${serverPath}totals';
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    try {
      var response = await http.post(Uri.parse(url), headers: requestHeaders);

      print([response.statusCode, response.body]);

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        statDashboard = StatDashboard.fromJson(jsonResult);
      } else {
        error = "Error: statusCode=${response.statusCode}";
      }
    } catch (ex) {
      error = ex.toString();
    }

    isLoading = false;
    notifyListeners();
  } */

  /* void refreshData(String uid) {
    fetchTotalsData(uid);
  } */

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
    notifyListeners();
  }
}
