import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/const/colors.dart';
import 'package:odrive_restaurant/common/const/images.dart';
import 'package:odrive_restaurant/common/widgets/appbar.dart';
import 'package:odrive_restaurant/common/widgets/bg_image.dart';
import 'package:odrive_restaurant/common/widgets/custom_drawer.dart';
import 'package:odrive_restaurant/common/widgets/restaurant_card.dart';
import 'package:odrive_restaurant/model/product.dart';
import 'package:odrive_restaurant/providers/restaurant_provider.dart';
import 'package:provider/provider.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final TextEditingController _controller = TextEditingController();

  void _onSearchSubmitted(String value) {
    print("Search Value: $value");
  }

  Future<void> _handleRefresh() async {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantsProvider>(context, listen: false)
          .fetchRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<RestaurantsProvider>(context);
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          const BgContainer(),
          CustomAppBar(
            leadingImageAsset: drawer,
            title: 'Restaurants',
            notificationImageAsset: notificationIcon,
            smsImageAsset: mailIcon,
          ),
          Positioned(
              top: 115,
              left: 16,
              right: 16,
              child: Column(children: [
                // Container(
                //   margin: const EdgeInsets.only(bottom: 20),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(30.0),
                //   ),
                //   child: TextField(
                //     controller: _controller,
                //     onSubmitted: _onSearchSubmitted,
                //     decoration: InputDecoration(
                //       hintText: "Search here",
                //       hintStyle: TextStyle(color: Colors.grey),
                //       contentPadding:
                //           EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                //       border: InputBorder.none,
                //       suffixIcon: Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: Container(
                //           padding: EdgeInsets.all(2),
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(20),
                //           ),
                //           child: Icon(
                //             Icons.menu_open,
                //             color: Colors.black,
                //           ),
                //         ),
                //       ),
                //     ),
                //     textInputAction: TextInputAction.search,
                //   ),
                // ),
                Container(
                    // margin: const EdgeInsets.only(left: 8, right: 8),
                    // width: MediaQuery.of(context).size.width * 0.98,
                    decoration: BoxDecoration(
                        color: white, borderRadius: BorderRadius.circular(40)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildTab("All", 0, productProvider),
                          buildTab("Published", 1, productProvider),
                          buildTab("Draft", 2, productProvider),
                          // buildTab(AppLocalizations.of(context)!.active, 1),
                          // buildTab(AppLocalizations.of(context)!.history, 2),
                        ],
                      ),
                    ))
              ])),
          // Content Container (to place content below the tabs)
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 100.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: RefreshIndicator(
              onRefresh: productProvider.fetchRestaurants,
              child: Container(
                color: Colors.transparent,
                child: productProvider.loading
                    ? Center(child: CircularProgressIndicator())
                    : _buildContent(
                        productProvider), // Call a function to build content based on selected tab
              ),
            ),
          ),
          //_loading ? LoadingWidget() : Container(),
        ],
      ),
    );
  }

  Widget buildTab(
      String label, int index, RestaurantsProvider productProvider) {
    return GestureDetector(
      onTap: () {
        productProvider.setSelectedTabIndex(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          height: 40,
          width: MediaQuery.of(context).size.width * 0.26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: productProvider.selectedTabIndex == index
                ? appColor
                : Color(0XFFECECEC),
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: productProvider.selectedTabIndex == index
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(RestaurantsProvider productProvider) {
    int currentTab = productProvider.selectedTabIndex;
    List<RestaurantData> product = currentTab == 0
        ? productProvider.restaurantData
        : productProvider.getFilteredRestaurants(currentTab);

// print(orders);
    if (product.isEmpty) {
      return Center(
        child: Text('No restaurants available'),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: product.length,
      itemBuilder: (context, index) {
        final data = product[index];
        print(data.published);
        return RestaurantCard(
            title: data.name,
            orderId: "#${data.id}",
            updateDate: "last update: ${data.updatedAt}",
            imageUrl: "${serverImages}${data.image}",
            isPublished: data.published == 1,
            isLoading: productProvider.isDeleting(data.id.toString()),
            onPublish: () {
              print("Published");
            },
            onEdit: () {
              print("Edit");
            },
            onDelete: (String status) {
              if (status == 'error') {
                Fluttertoast.showToast(
                    msg: "une erreur est survenue, veuillez réessayer",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                print("Error deleting product:");
              } else {
                Fluttertoast.showToast(
                    msg: "Produit supprimé avec succès",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: appColor,
                    textColor: Colors.white,
                    fontSize: 16.0);
                print("Product deleted successfully");
              }
            });
      },
    );
  }
}
