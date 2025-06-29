import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/providers/order_provider.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _needsRefresh = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_needsRefresh) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
      _needsRefresh = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          const BgContainer(),
          CustomAppBar(
            leadingImageAsset: drawer,
            title: 'Orders',
            notificationImageAsset: notificationIcon,
            smsImageAsset: mailIcon,
          ),
          Positioned(
            top: 115,
            left: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildTab("All", 0),
                    buildTab("Received", 1),
                    buildTab("Preparing", 2),
                    buildTab("Ready", 3),
                    buildTab("On the way", 4),
                    buildTab("Delivered", 5),
                    buildTab("Cancelled", 6),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 80.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: RefreshIndicator(
              onRefresh: orderProvider.fetchOrders,
              child: orderProvider.loading
                  ? Center(child: CircularProgressIndicator())
                  : _buildContent(orderProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTab(String label, int index) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        orderProvider.setSelectedTabIndex(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          height: 40,
          width: MediaQuery.of(context).size.width * 0.26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: orderProvider.selectedTabIndex == index
                ? appColor
                : Color(0XFFECECEC),
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: orderProvider.selectedTabIndex == index
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

Widget _buildContent(OrderProvider orderProvider) {
  int currentTab = orderProvider.selectedTabIndex;
  // List<dynamic> orders = currentTab == 0
  //     ? orderProvider.orderData
  //     : orderProvider.getFilteredOrders(currentTab);
List<dynamic> orders = orderProvider.filteredOrders;
  // Si la liste est vide et qu'on n'est pas en train de charger, afficher un message
  if (orders.isEmpty && !orderProvider.loading && !orderProvider.isLoadingMore) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Aucune commande disponible'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              orderProvider.fetchOrders();
            },
            child: Text('Actualiser', style: TextStyle(fontSize: 16, color: appColor)),
          ),
        ],
      ),
    );
  }
// Si la liste est vide et qu'on n'est pas en train de charger, afficher un message
    if (orders.isEmpty && !orderProvider.loading && !orderProvider.isLoadingMore) {
      return const Center(child: Text('Aucune commande disponible'));
    }
  // Si les données sont en cours de chargement et qu'il n'y a pas encore de commandes, affichez le loader
  if (orderProvider.loading && orders.isEmpty) {
    return Center(child: CircularProgressIndicator());
  }

  return NotificationListener<ScrollNotification>(
    onNotification: (ScrollNotification scrollInfo) {
      if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
          !orderProvider.isLoadingMore &&
          orderProvider.hasMoreOrders) {
        orderProvider.fetchOrders(isLoadMore: true);
      }
      return false;
    },
    child: ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: orders.length + (orderProvider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= orders.length) {
          // Éviter les accès hors limites et afficher l'indicateur de chargement
          return Center(child: CircularProgressIndicator(color: appColor ,));
        }

        final data = orders[index];
        return Column(
          children: [
            OrderCard1(
              isNewTab: true,
              isActiveTab: false,
              order: data,
              refreshCallback: () {
                orderProvider.fetchOrders();
              },
              isHistoryTab: false,
            ),
          ],
        );
      },
    ),
  );
}

}
