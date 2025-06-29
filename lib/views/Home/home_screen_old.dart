import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:odrive_restaurant/common/const/colors.dart' as colors;
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/widgets/dashboardCard.dart';
import 'package:odrive_restaurant/providers/dashboard_provider.dart';
import 'package:odrive_restaurant/views/orders/orders_screen.dart';
import 'package:odrive_restaurant/views/products/product_screen.dart';
import 'package:odrive_restaurant/views/restaurants/restaurant_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.fetchTotalsData(prefs.getString('uuid')!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    return Scaffold(
        drawer: const CustomDrawer(),
        body: RefreshIndicator(
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
                            if (provider.statDashboard != null) ...[
                              _buildSummaryCard(
                                title1:
                                    AppLocalizations.of(context)!.totalOrders,
                                value1: provider.statDashboard!.totalOrders
                                    .toString(),
                                title2:
                                    AppLocalizations.of(context)!.totalEarnings,
                                value2:
                                    '${provider.statDashboard!.rightSymbol == "true" ? provider.statDashboard!.totalEarnings.toStringAsFixed(provider.statDashboard!.symbolDigits) + " " + provider.statDashboard!.code : provider.statDashboard!.code + " " + provider.statDashboard!.totalEarnings.toStringAsFixed(provider.statDashboard!.symbolDigits)}',
                              ),
                              const SizedBox(height: 20),
                              _buildSummaryCard(
                                title1: AppLocalizations.of(context)!
                                    .totalRestaurants,
                                value1: provider.statDashboard!.totalRestaurants
                                    .toString(),
                                title2:
                                    AppLocalizations.of(context)!.totalProducts,
                                value2: provider.statDashboard!.totalProducts
                                    .toString(),
                              ),
                            ] else
                              const Center(child: CircularProgressIndicator()),
                            const SizedBox(height: 20),
                            _buildDashboardCards(
                              [
                                {
                                  'title':
                                      AppLocalizations.of(context)!.totalOrders,
                                  'subtitle':
                                      AppLocalizations.of(context)!.totalOrders,
                                  'value': provider.statDashboard?.totalOrders
                                      .toString(),
                                  'action': () => Get.off(OrdersScreen()),
                                },
                                {
                                  'title': AppLocalizations.of(context)!
                                      .totalRestaurants,
                                  'subtitle': AppLocalizations.of(context)!
                                      .totalRestaurants,
                                  'value': provider
                                      .statDashboard?.totalRestaurants
                                      .toString(),
                                  'action': () => Get.off(RestaurantScreen()),
                                },
                                {
                                  'title': AppLocalizations.of(context)!
                                      .totalProducts,
                                  'subtitle': AppLocalizations.of(context)!
                                      .totalProducts,
                                  'value': provider.statDashboard?.totalProducts
                                      .toString(),
                                  'action': () => Get.off(ProductScreen()),
                                }
                              ],
                            ),
                          ],
                        ),
                      ),
              )
            ],
          ),
        ));
  }

  Widget _buildSummaryCard({
    required String title1,
    required String value1,
    required String title2,
    required String value2,
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
            child: _buildSummaryColumn(title1, value1),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildSummaryColumn(title2, value2),
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
          title: cardData['title']??"",
          subtitle: cardData['subtitle']??"",
          value: cardData['value']??"0",
          onTap: cardData['action'],
        );
      },
    );
  }
}
