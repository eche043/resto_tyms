// lib/views/restaurants/restaurants_detail_screen_v2.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:odrive_restaurant/common/const/colors.dart';
import 'package:odrive_restaurant/common/widgets/appbar.dart';
import 'package:odrive_restaurant/common/widgets/bg_image.dart';
import 'package:odrive_restaurant/common/widgets/custom_drawer.dart';
import 'package:odrive_restaurant/common/widgets/stats_overview_card.dart';
import 'package:odrive_restaurant/providers/restaurants_detail_provider.dart';
import 'package:odrive_restaurant/model/restaurant_ranking.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class RestaurantsDetailScreen extends StatefulWidget {
  const RestaurantsDetailScreen({super.key});

  @override
  State<RestaurantsDetailScreen> createState() =>
      _RestaurantsDetailScreenState();
}

class _RestaurantsDetailScreenState extends State<RestaurantsDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final provider =
        Provider.of<RestaurantsDetailProvider>(context, listen: false);
    await provider.loadRestaurants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          const BgContainer(),
          CustomAppBar(
            leadingImageAsset: 'assets/images/drawer.png',
            title: 'Détail Restaurants',
            /* showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.file_download, color: Colors.white),
                onPressed: _showExportDialog,
              ),
            ], */
          ),
          Positioned(
            top: 115,
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<RestaurantsDetailProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: appColor),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Vue d'ensemble
                    _buildOverviewSection(provider),

                    // Onglets
                    _buildTabBar(),

                    // Contenu des onglets
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(provider),
                          _buildRestaurantsListTab(provider),
                          _buildAnalyticsTab(provider),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(RestaurantsDetailProvider provider) {
    final evolutionStats = provider.getEvolutionStats();

    return Container(
      margin: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: appColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: appColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Restaurants',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.totalRestaurants}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: appColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: evolutionStats['growth_positive']
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        evolutionStats['growth_positive']
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: evolutionStats['growth_positive']
                            ? Colors.green[600]
                            : Colors.red[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${evolutionStats['growth_positive'] ? '+' : ''}${evolutionStats['growth_percentage'].toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: evolutionStats['growth_positive']
                              ? Colors.green[600]
                              : Colors.red[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Évolution sur les 30 derniers jours',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: TabBar(
        controller: _tabController,
        indicatorColor: appColor,
        labelColor: appColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Vue d\'ensemble'),
          Tab(text: 'Liste'),
          Tab(text: 'Analyses'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(RestaurantsDetailProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques rapides
            _buildQuickStatsGrid(provider),
            const SizedBox(height: 20),

            // Top restaurants
            _buildTopRestaurantsSection(provider),
            const SizedBox(height: 20),

            // Restaurants récents
            _buildRecentRestaurantsSection(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsListTab(RestaurantsDetailProvider provider) {
    return Column(
      children: [
        // Filtres et recherche
        _buildFiltersSection(provider),

        // Liste des restaurants
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: _buildRestaurantsList(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(RestaurantsDetailProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Graphiques et analyses
          _buildAnalyticsCharts(provider),
          const SizedBox(height: 20),

          // Répartition par statut
          _buildStatusDistribution(provider),
          const SizedBox(height: 20),

          // Métriques avancées
          _buildAdvancedMetrics(provider),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(RestaurantsDetailProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Restaurants Actifs',
          '${provider.activeRestaurants}',
          Colors.green,
          Icons.check_circle,
        ),
        _buildStatCard(
          'Restaurants Inactifs',
          '${provider.inactiveRestaurants}',
          Colors.orange,
          Icons.pause_circle,
        ),
        _buildStatCard(
          'Total Commandes',
          '${provider.totalOrders}',
          appColor,
          Icons.shopping_bag,
        ),
        _buildStatCard(
          'Revenus Totaux',
          '${provider.totalRevenue.toStringAsFixed(0)} FCFA',
          Colors.purple,
          Icons.monetization_on,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTopRestaurantsSection(RestaurantsDetailProvider provider) {
    final topByOrders =
        provider.getTopRestaurants(criteria: 'orders', limit: 5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 - Commandes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...topByOrders.asMap().entries.map((entry) {
            final index = entry.key;
            final restaurant = entry.value;
            return _buildTopRestaurantItem(restaurant, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildTopRestaurantItem(RestaurantRanking restaurant, int position) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getRankingColor(position),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${restaurant.ordersCount} commandes',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${restaurant.totalRevenue.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRestaurantsSection(RestaurantsDetailProvider provider) {
    final recentRestaurants = provider.getRecentlyAddedRestaurants(limit: 3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récemment ajoutés',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...recentRestaurants
              .map((restaurant) => _buildRecentRestaurantItem(restaurant)),
        ],
      ),
    );
  }

  Widget _buildRecentRestaurantItem(RestaurantRanking restaurant) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.restaurant, color: appColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  restaurant.published == 1 ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    color: restaurant.published == 1
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(RestaurantsDetailProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            onChanged: provider.updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'Rechercher un restaurant...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.updateSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Filtres de statut et tri
          Row(
            children: [
              // Filtres de statut
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilter('Tous', 0, provider),
                      const SizedBox(width: 8),
                      _buildStatusFilter('Actifs', 1, provider),
                      const SizedBox(width: 8),
                      _buildStatusFilter('Inactifs', 2, provider),
                    ],
                  ),
                ),
              ),

              // Menu de tri
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  provider.updateSort(value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'name',
                    child: Text('Trier par nom'),
                  ),
                  const PopupMenuItem(
                    value: 'orders',
                    child: Text('Trier par commandes'),
                  ),
                  const PopupMenuItem(
                    value: 'revenue',
                    child: Text('Trier par revenus'),
                  ),
                  const PopupMenuItem(
                    value: 'status',
                    child: Text('Trier par statut'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(
      String label, int value, RestaurantsDetailProvider provider) {
    final isSelected = provider.statusFilter == value;
    return GestureDetector(
      onTap: () => provider.updateStatusFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? appColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantsList(RestaurantsDetailProvider provider) {
    final restaurants = provider.restaurants;

    if (restaurants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun restaurant trouvé'),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: restaurants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return _buildRestaurantCard(restaurant, provider);
      },
    );
  }

  Widget _buildRestaurantCard(
      RestaurantRanking restaurant, RestaurantsDetailProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildStatusBadge(restaurant.published),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'toggle':
                      await provider.toggleRestaurantStatus(restaurant.id);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(restaurant, provider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(
                        restaurant.published == 1 ? 'Désactiver' : 'Activer'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Supprimer'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.shopping_cart, '${restaurant.ordersCount}'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.monetization_on,
                  '${restaurant.totalRevenue.toStringAsFixed(0)} FCFA'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    final isActive = status == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Actif' : 'Inactif',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green[700] : Colors.orange[700],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCharts(RestaurantsDetailProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyses et Tendances',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Graphique en barres simple (simulation)
          Container(
            height: 200,
            child: Column(
              children: [
                const Text('Commandes par mois',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(6, (index) {
                      final height = (index + 1) * 20.0 + 40;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: height,
                            decoration: BoxDecoration(
                              color: appColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'M${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(RestaurantsDetailProvider provider) {
    final total = provider.totalRestaurants;
    final active = provider.activeRestaurants;
    final inactive = provider.inactiveRestaurants;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition par Statut',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Barres de progression
          _buildProgressItem(
            'Restaurants Actifs',
            active,
            total,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildProgressItem(
            'Restaurants Inactifs',
            inactive,
            total,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value (${(percentage * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedMetrics(RestaurantsDetailProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métriques Avancées',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Moyenne commandes/restaurant',
            provider.averageOrdersPerRestaurant.toStringAsFixed(1),
            Icons.trending_up,
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            'Revenus moyens/restaurant',
            '${provider.averageRevenuePerRestaurant.toStringAsFixed(0)} FCFA',
            Icons.monetization_on,
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            'Taux d\'activation',
            '${provider.totalRestaurants > 0 ? (provider.activeRestaurants / provider.totalRestaurants * 100).toStringAsFixed(1) : 0}%',
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: appColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: appColor,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
      RestaurantRanking restaurant, RestaurantsDetailProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content:
            Text('Êtes-vous sûr de vouloir supprimer "${restaurant.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteRestaurant(restaurant.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Restaurant supprimé avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter les données'),
        content: const Text('Choisissez le format d\'export'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = Provider.of<RestaurantsDetailProvider>(context,
                    listen: false);
                final data = await provider.exportData(format: 'csv');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export CSV réussi'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Dans une vraie app, vous sauvegarderiez le fichier ou l'enverriez
                print('Données CSV exportées: $data');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = Provider.of<RestaurantsDetailProvider>(context,
                    listen: false);
                final data = await provider.exportData(format: 'excel');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export Excel réussi'),
                    backgroundColor: Colors.green,
                  ),
                );

                print('Données Excel exportées: $data');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur Export Excel: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = Provider.of<RestaurantsDetailProvider>(context,
                    listen: false);
                final data = await provider.exportData(format: 'pdf');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export PDF réussi'),
                    backgroundColor: Colors.green,
                  ),
                );

                print('Données PDF exportées: $data');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur Export PDF: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Options de filtrage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Réinitialiser les filtres'),
              onTap: () {
                Navigator.pop(context);
                final provider = Provider.of<RestaurantsDetailProvider>(context,
                    listen: false);
                provider.resetFilters();
                _searchController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Filtres réinitialisés'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Sauvegarder la vue'),
              onTap: () {
                Navigator.pop(context);
                // Ici vous pourriez sauvegarder les filtres actuels
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vue sauvegardée'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptionsDialog(RestaurantsDetailProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Options de tri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.sort_by_alpha,
                color: provider.sortBy == 'name' ? appColor : Colors.grey,
              ),
              title: Text(
                'Trier par nom',
                style: TextStyle(
                  color: provider.sortBy == 'name' ? appColor : Colors.black,
                  fontWeight: provider.sortBy == 'name'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              trailing: provider.sortBy == 'name'
                  ? Icon(
                      provider.sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: appColor,
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                provider.updateSort('name');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.shopping_cart,
                color: provider.sortBy == 'orders' ? appColor : Colors.grey,
              ),
              title: Text(
                'Trier par commandes',
                style: TextStyle(
                  color: provider.sortBy == 'orders' ? appColor : Colors.black,
                  fontWeight: provider.sortBy == 'orders'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              trailing: provider.sortBy == 'orders'
                  ? Icon(
                      provider.sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: appColor,
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                provider.updateSort('orders');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.monetization_on,
                color: provider.sortBy == 'revenue' ? appColor : Colors.grey,
              ),
              title: Text(
                'Trier par revenus',
                style: TextStyle(
                  color: provider.sortBy == 'revenue' ? appColor : Colors.black,
                  fontWeight: provider.sortBy == 'revenue'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              trailing: provider.sortBy == 'revenue'
                  ? Icon(
                      provider.sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: appColor,
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                provider.updateSort('revenue');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.toggle_on,
                color: provider.sortBy == 'status' ? appColor : Colors.grey,
              ),
              title: Text(
                'Trier par statut',
                style: TextStyle(
                  color: provider.sortBy == 'status' ? appColor : Colors.black,
                  fontWeight: provider.sortBy == 'status'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              trailing: provider.sortBy == 'status'
                  ? Icon(
                      provider.sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: appColor,
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                provider.updateSort('status');
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankingColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return appColor;
    }
  }

  String _getRankingIcon(int position) {
    switch (position) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return position.toString();
    }
  }

  void _showRestaurantDetailsBottomSheet(RestaurantRanking restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(restaurant.published),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistiques détaillées
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailStatCard(
                            'Commandes',
                            '${restaurant.ordersCount}',
                            Icons.shopping_cart,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailStatCard(
                            'Revenus',
                            '${restaurant.totalRevenue.toStringAsFixed(0)} FCFA',
                            Icons.monetization_on,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Informations supplémentaires
                    const Text(
                      'Informations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoRow('ID', '${restaurant.id}'),
                    _buildInfoRow('Statut',
                        restaurant.published == 1 ? 'Actif' : 'Inactif'),
                    _buildInfoRow(
                        'Nombre de commandes', '${restaurant.ordersCount}'),
                    _buildInfoRow('Revenus totaux',
                        '${restaurant.totalRevenue.toStringAsFixed(2)} FCFA'),

                    const SizedBox(height: 20),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigation vers l'édition
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Modifier'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              final provider =
                                  Provider.of<RestaurantsDetailProvider>(
                                      context,
                                      listen: false);
                              provider.toggleRestaurantStatus(restaurant.id);
                            },
                            icon: Icon(restaurant.published == 1
                                ? Icons.pause
                                : Icons.play_arrow),
                            label: Text(restaurant.published == 1
                                ? 'Désactiver'
                                : 'Activer'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: appColor,
                              side: const BorderSide(color: appColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
