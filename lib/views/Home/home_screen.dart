import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:odrive_restaurant/common/const/colors.dart' as colors;
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/widgets/custom_bottom_navigation.dart';
import 'package:odrive_restaurant/common/widgets/dashboardCard.dart';
import 'package:odrive_restaurant/providers/dashboard_provider.dart';
import 'package:odrive_restaurant/views/Home/widgets/best_selling_chart.dart';
import 'package:odrive_restaurant/views/Home/widgets/filter_section.dart';
import 'package:odrive_restaurant/views/Home/widgets/payment_history_list.dart';
import 'package:odrive_restaurant/views/Home/widgets/ranking_list.dart';
import 'package:odrive_restaurant/views/Home/widgets/stats_card.dart';
import 'package:odrive_restaurant/views/Home/widgets/stats_chart.dart';
import 'package:odrive_restaurant/views/orders/in_progress_screen.dart';
import 'package:odrive_restaurant/views/orders/orders_screen.dart';
import 'package:odrive_restaurant/views/products/product_screen.dart';
import 'package:odrive_restaurant/views/restaurants/restaurant_screen.dart';
import 'package:odrive_restaurant/views/restaurants/restaurants_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // ✅ Index pour la navigation
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    //provider.fetchTotalsData(prefs.getString('uuid')!);

    // Initialiser les nouvelles données dynamiques
    provider.initializeDashboard();
  }

  // ✅ Liste des écrans pour chaque onglet
  List<Widget> get _screens => [
        _buildHomeContent(), // Contenu original du HomeScreen
        const InProgressScreen(), // Live
        OrdersScreen(), // Commandes
      ];

  // ✅ Contenu original du HomeScreen extrait en méthode
  Widget _buildHomeContent() {
    final provider = Provider.of<DashboardProvider>(context);
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchData();
      },
      child: Stack(
        children: [
          const BgContainer(),
          CustomAppBar(
            leadingImageAsset: drawer,
            title: AppLocalizations.of(context)!.home,
            notificationImageAsset: notificationIcon,
            smsImageAsset: mailIcon,
          ),
          Positioned(
            top: 115,
            left: 8,
            right: 8,
            bottom: 0,
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (provider.error != null)
                          Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red),
                          ),

                        // Section des statistiques principales (adaptée)
                        _buildStatsSection(provider),

                        const SizedBox(height: 20),

                        // Section des graphiques et données dynamiques
                        _buildChartSection(provider),

                        const SizedBox(height: 20),

                        // Section Ranking et Produits populaires
                        _buildRankingAndProductsSection(provider),

                        const SizedBox(height: 20),

                        // Section Navigation Cards (existante)
                        /* _buildDashboardCards(
                            [
                              {
                                'title':
                                    AppLocalizations.of(context)!.totalOrders,
                                'subtitle':
                                    AppLocalizations.of(context)!.totalOrders,
                                'value': provider.stats?.totalOrders.toString(),
                                'action': () => Get.off(OrdersScreen()),
                              },
                              {
                                'title': AppLocalizations.of(context)!
                                    .totalRestaurants,
                                'subtitle': AppLocalizations.of(context)!
                                    .totalRestaurants,
                                'value':
                                    provider.stats?.totalRestaurants.toString(),
                                'action': () => Get.off(RestaurantScreen()),
                              },
                              {
                                'title': AppLocalizations.of(context)!.totalProducts,
                                'subtitle': AppLocalizations.of(context)!.totalProducts,
                                'value': provider.stats?.totalProducts.toString(),
                                'action': () => Get.off(ProductScreen()),
                              }
                            ],
                          ), */

                        const SizedBox(height: 20),

                        // Historique des paiements
                        _buildPaymentHistorySection(provider),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildCustomBottomNavigation(),
    );
  }

  // ✅ Bottom navigation utilisant le composant externe
  Widget _buildCustomBottomNavigation() {
    return CustomBottomNavigationModern(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? appColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? appColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? appColor : Colors.grey.shade600,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(DashboardProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Sur petit écran, afficher en colonne
        //if (constraints.maxWidth < 600) {
        return Column(
          children: [
            StatsCard(
              title: l10n.totalOrders,
              value: provider.totalOrders.toString(),
              onDetailPressed: () {
                Get.off(OrdersScreen());
                // TODO: Navigation vers les détails des commandes
                /*  Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => OrdersProvider(),
                      child: OrdersScreen(),
                    ),
                  ),
                ); */
              },
            ),
            const SizedBox(height: 12),
            StatsCard(
              title: l10n.totalRestaurants,
              value: provider.totalRestaurants.toString(),
              onDetailPressed: () {
                Get.to(() => const RestaurantsDetailScreen());
                // TODO: Navigation vers les détails des restaurants
              },
            ),
            const SizedBox(height: 12),
            StatsCard(
              title: l10n.totalEarnings,
              value: provider.totalEarnings.toString(),
              onDetailPressed: () {
                Get.to(() => const RestaurantsDetailScreen());
                // TODO: Navigation vers les détails des restaurants
              },
            ),
          ],
        );
        //}

        // Sur grand écran, afficher en ligne
        /* return Row(
          children: [
            Expanded(
              child: StatsCard(
                title: l10n.totalOrders,
                value: provider.totalOrders.toString(),
                onDetailPressed: () {
                  // TODO: Navigation vers les détails des commandes
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: l10n.totalRestaurants,
                value: provider.totalRestaurants.toString(),
                onDetailPressed: () {
                  // TODO: Navigation vers les détails des restaurants
                },
              ),
            ),
          ],
        ); */
      },
    );
  }

  // Section des statistiques adaptée
  /* Widget _buildStatsSection(DashboardProvider provider) {
    if (provider.stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        
        // Première ligne de stats (existante mais modernisée)
        _buildSummaryCard(
          title1: AppLocalizations.of(context)!.totalOrders,
          value1: provider.stats!.totalOrders.toString(),
          title2: AppLocalizations.of(context)!.totalEarnings,
          value2:
              '${provider.rightSymbol == "true" ? provider.stats!.totalEarnings.toStringAsFixed(provider.symbolDigits) + " " + provider.stats!.currency : provider.stats!.currency + " " + provider.stats!.totalEarnings.toStringAsFixed(provider.symbolDigits)}',
          onTap1: () => Get.off(OrdersScreen()),
          onTap2: () {}, // TODO: Navigation vers les détails des gains
        ),
        const SizedBox(height: 16),

        // Deuxième ligne de stats
        _buildSummaryCard(
          title1: AppLocalizations.of(context)!.totalRestaurants,
          value1: provider.stats!.totalRestaurants.toString(),
          title2: AppLocalizations.of(context)!.totalProducts,
          value2: provider.stats!.totalProducts.toString(),
          onTap1: () => Get.off(RestaurantScreen()),
          onTap2: () => Get.off(ProductScreen()),
        ),
      ],
    );
  } */

  // Section des graphiques (nouvelle)
  Widget _buildChartSection(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filtres
        FilterSection(
          selectedPeriod: provider.selectedPeriod,
          onPeriodChanged: provider.setPeriod,
          onCustomPeriodSelected: provider.setCustomPeriod,
          customStartDate: provider.customStartDate,
          customEndDate: provider.customEndDate,
        ),

        const SizedBox(height: 16),

        // Titre des statistiques
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.statistics ?? 'Statistiques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.greyScale900Color,
                ),
              ),
              if (provider.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Graphique des statistiques
        StatsChart(
          data: provider.getOrdersEvolutionData().isNotEmpty
              ? provider.getOrdersEvolutionData()
              : provider.getChartData(),
          isLoading: provider.isLoading,
        ),

        const SizedBox(height: 8),

        // Résumé de l'évolution
        if (provider.ordersEvolution.isNotEmpty)
          _buildEvolutionSummary(provider),
      ],
    );
  }

  // Section Ranking et Produits (nouvelle)
  Widget _buildRankingAndProductsSection(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Ranking
        _buildRankingSection(provider),

        const SizedBox(height: 20),

        // Section Produits populaires
        _buildBestSellingSection(provider),
      ],
    );
  }

  Widget _buildRankingSection(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.ranking ?? 'Classement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.greyScale900Color,
                ),
              ),
              if (provider.isLoadingRankings)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          RankingList(
            rankings: provider.getRankingData(),
            isLoading: provider.isLoadingRankings,
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellingSection(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.bestSellingProduct ??
                'Produits populaires',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.greyScale900Color,
            ),
          ),
          const SizedBox(height: 16),
          BestSellingChart(
            products: provider.getBestSellingProductsData(),
            colors: provider.getProductChartColors(),
            isLoading: provider.isLoadingTopFoods,
          ),
        ],
      ),
    );
  }

  // Section Payment History (nouvelle)
  Widget _buildPaymentHistorySection(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.paymentHistory ??
                'Historique des paiements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.greyScale900Color,
            ),
          ),
          const SizedBox(height: 16),
          PaymentHistoryList(
            payments: provider.stats?.paymentHistory ?? [],
            isLoading: provider.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionSummary(DashboardProvider provider) {
    final evolution = provider.ordersEvolution;
    if (evolution.isEmpty) return const SizedBox.shrink();

    final totalRevenue = evolution.fold<double>(
      0.0,
      (sum, item) => sum + item.totalRevenue,
    );

    final totalOrders = evolution.fold<int>(
      0,
      (sum, item) => sum + item.totalOrders,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Périodes',
            evolution.length.toString(),
            Icons.calendar_today,
          ),
          _buildSummaryItem(
            'Total commandes',
            totalOrders.toString(),
            Icons.shopping_cart,
          ),
          _buildSummaryItem(
            'Revenus total',
            '${totalRevenue.toStringAsFixed(0)} ${provider.currency}',
            Icons.monetization_on,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: colors.appColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.greyScale900Color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Méthode modifiée pour inclure les actions
  Widget _buildSummaryCard({
    required String title1,
    required String value1,
    required String title2,
    required String value2,
    VoidCallback? onTap1,
    VoidCallback? onTap2,
  }) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap1,
              child: _buildSummaryColumn(title1, value1),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: onTap2,
              child: _buildSummaryColumn(title2, value2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 14,
              color: colors.greyScale900Color,
              fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.greyScale900Color),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDashboardCards(List<Map<String, dynamic>> cardsData) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 36,
        childAspectRatio: 0.9,
      ),
      itemCount: cardsData.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final cardData = cardsData[index];
        return DashboardCard(
          title: cardData['title'] ?? "",
          subtitle: cardData['subtitle'] ?? "",
          value: cardData['value'] ?? "0",
          onTap: cardData['action'],
        );
      },
    );
  }
}
