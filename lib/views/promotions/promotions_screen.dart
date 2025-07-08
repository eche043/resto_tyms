import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/model/promotion.dart';
import 'package:odrive_restaurant/providers/user_provider.dart';
import 'package:odrive_restaurant/views/promotions/add_promotion_screen.dart';
import 'package:provider/provider.dart';
//import 'package:odrive_restaurant/views/promotions/add_promotion_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({Key? key}) : super(key: key);

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Promotion> _allPromotions = [];
  List<Promotion> _pendingPromotions = [];
  List<Promotion> _approvedPromotions = [];
  List<Promotion> _rejectedPromotions = [];
  bool _isLoading = true;
  int? _restaurantId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // ✅ Délai pour s'assurer que UserProvider est chargé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurantId();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Version corrigée avec refresh des données
  Future<void> _loadRestaurantId() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // ✅ Forcer le rechargement des données depuis SharedPreferences
    await userProvider.refreshUserData();

    print('=== PROMOTION SCREEN DEBUG ===');
    userProvider.printUserData();
    print('==============================');

    if (userProvider.hasRestaurants) {
      // Utiliser le restaurant par défaut ou le premier disponible
      _restaurantId = userProvider.defaultRestaurantId > 0
          ? userProvider.defaultRestaurantId
          : userProvider.firstRestaurantId;

      print('Restaurant ID sélectionné: $_restaurantId');
      print('Restaurants disponibles: ${userProvider.userRestaurants}');

      _loadPromotions();
    } else {
      // L'utilisateur ne gère aucun restaurant
      Fluttertoast.showToast(
        msg: "Aucun restaurant assigné à votre compte",
        backgroundColor: Colors.red,
      );

      // ✅ Debug pour comprendre pourquoi aucun restaurant
      print('=== DEBUG: NO RESTAURANTS ===');
      print('UserRestaurants: ${userProvider.userRestaurants}');
      print('RestaurantCount: ${userProvider.restaurantCount}');
      print('DefaultRestaurantId: ${userProvider.defaultRestaurantId}');

      // Vérifier directement dans SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('Direct from prefs:');
      print('userRestaurants: ${prefs.getStringList('userRestaurants')}');
      print('restaurantCount: ${prefs.getInt('restaurantCount')}');
      print('defaultRestaurantId: ${prefs.getInt('defaultRestaurantId')}');
      print('============================');

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPromotions() async {
    print("_restaurantId__________-");
    print(_restaurantId);
    if (_restaurantId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await getRestaurantOffers(restaurantId: _restaurantId!);
      print("OKKK11111");

      if (response['error'] == '0') {
        print("OKKK2222222");
        final promotionsData = response['offers'] as List;
        _allPromotions =
            promotionsData.map((data) => Promotion.fromJson(data)).toList();
        print("OKKK3333333");
        _filterPromotions();
        print("OKKK444444");
      } else {
        print("ERRREUR__________");
        print(response['error']);
        Fluttertoast.showToast(
          msg: response['error'],
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("erreur in catch__________");
      print(e);
      Fluttertoast.showToast(
        msg: "Erreur de chargement: $e",
        backgroundColor: Colors.red,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _filterPromotions() {
    _pendingPromotions =
        _allPromotions.where((p) => p.status == 'pending').toList();
    _approvedPromotions = _allPromotions
        .where((p) => p.status == 'approved' || p.status == 'active')
        .toList();
    _rejectedPromotions =
        _allPromotions.where((p) => p.status == 'rejected').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          const BgContainer(),
          const CustomAppBar(
            leadingImageAsset: drawer,
            title: 'Promotions',
            notificationImageAsset: notificationIcon,
          ),
          Positioned(
            top: 115,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Header avec statistiques
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          _allPromotions.length.toString(),
                          Colors.blue,
                          Icons.campaign,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'En attente',
                          _pendingPromotions.length.toString(),
                          Colors.orange,
                          Icons.schedule,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Approuvées',
                          _approvedPromotions.length.toString(),
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Onglets
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: appColor,
                    unselectedLabelColor: Colors.grey,
                    indicator: BoxDecoration(
                      color: appColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    tabs: const [
                      Tab(text: 'Toutes'),
                      Tab(text: 'En attente'),
                      Tab(text: 'Approuvées'),
                      Tab(text: 'Rejetées'),
                    ],
                  ),
                ),

                // Contenu des onglets
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildPromotionsList(_allPromotions),
                            _buildPromotionsList(_pendingPromotions),
                            _buildPromotionsList(_approvedPromotions),
                            _buildPromotionsList(_rejectedPromotions),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddPromotionScreen(restaurantId: _restaurantId!),
            ),
          );
          if (result == true) {
            _loadPromotions();
          }
        },
        backgroundColor: appColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle Promotion',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsList(List<Promotion> promotions) {
    if (promotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune promotion',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPromotions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          return _buildPromotionCard(promotions[index]);
        },
      ),
    );
  }

  Widget _buildPromotionCard(Promotion promotion) {
    Color statusColor = _getStatusColor(promotion.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec nom et statut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    promotion.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(promotion.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 12),

                // Détails de l'offre
                Row(
                  children: [
                    Icon(Icons.local_offer, size: 16, color: appColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getOfferDetails(promotion),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: appColor),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(promotion.startDate)} - ${_formatDate(promotion.endDate)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),

                if (promotion.status == 'rejected' &&
                    promotion.responseMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.red.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            promotion.responseMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'active':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'approved':
        return 'Approuvée';
      case 'active':
        return 'Active';
      case 'rejected':
        return 'Rejetée';
      case 'expired':
        return 'Expirée';
      default:
        return status;
    }
  }

  String _getOfferDetails(Promotion promotion) {
    String trigger = promotion.offerType == 'specific_item'
        ? 'Achat de ${promotion.triggerItem}'
        : 'Minimum ${promotion.minimumAmount} FCFA';

    String reward = '';
    switch (promotion.rewardType) {
      case 'discount':
        reward = promotion.rewardPercentage != null
            ? '${promotion.rewardPercentage}% de réduction'
            : '${promotion.rewardValue} FCFA de réduction';
        break;
      case 'cashback':
        reward = '${promotion.rewardValue} FCFA de cashback';
        break;
      case 'free_product':
        reward = '${promotion.freeProduct} offert';
        break;
      case 'points':
        reward = '${promotion.pointsValue} points';
        break;
      default:
        reward = promotion.rewardType;
    }

    return '$trigger → $reward';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
