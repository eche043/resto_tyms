import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/providers/user_provider.dart';
import 'package:odrive_restaurant/views/orders/in_progress_screen.dart';
import 'package:odrive_restaurant/views/orders/orders_screen.dart';
import 'package:odrive_restaurant/views/products/product_screen.dart';
import 'package:odrive_restaurant/views/promotions/promotions_screen.dart';
import 'package:odrive_restaurant/views/restaurants/restaurant_screen.dart';
import 'package:odrive_restaurant/views/statut/statut_screen.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Drawer(
      backgroundColor: drawerColor.withOpacity(0.8),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50,
            left: 8,
            right: 8,
          ),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: white,
                    maxRadius: 25,
                    backgroundImage: userProvider.userAvatar != null
                        ? NetworkImage(
                                "$serverImages/${userProvider.userAvatar}")
                            as ImageProvider<Object>
                        : const AssetImage(dpIcon) as ImageProvider<Object>),
                title: userProvider.name.text.white.semiBold.make(),
                subtitle: userProvider.email.text
                    .color(white.withOpacity(0.7))
                    .make(),
              ),
              25.heightBox,
              Container(
                padding: const EdgeInsets.all(12.0),
                width: 265,
                decoration: BoxDecoration(
                    color: white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.offAll(() => HomeScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          Image.asset(profileIcon),
                          const SizedBox(width: 16),
                          'Home'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    10.heightBox,
                    InkWell(
                      onTap: () {
                        Get.offAll(() => const ProfileEditScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          Image.asset(profileIcon),
                          const SizedBox(width: 16),
                          'My Profile'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    10.heightBox,
                    InkWell(
                      onTap: () {
                        Get.offAll(() => OrdersScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.list,
                            color: appColor,
                          ),
                          const SizedBox(width: 16),
                          'Orders'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    10.heightBox,
                    InkWell(
                      onTap: () {
                        Get.offAll(() => const InProgressScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: appColor,
                          ),
                          const SizedBox(width: 16),
                          'En Progression'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    10.heightBox,
                    InkWell(
                      onTap: () {
                        Get.offAll(() => PromotionsScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.campaign,
                            color: appColor,
                          ),
                          const SizedBox(width: 16),
                          'Promotions'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    10.heightBox,
                    InkWell(
                      onTap: () {
                        Get.offAll(() => ProductScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.production_quantity_limits,
                            color: appColor,
                          ),
                          const SizedBox(width: 16),
                          'Products'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    10.heightBox,
                    InkWell(
                      onTap: () {
                        Get.offAll(() => RestaurantScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.restaurant,
                            color: appColor,
                          ),
                          const SizedBox(width: 16),
                          'Restaurants'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    10.heightBox,
                    InkWell(
                      onTap: () {
                        Get.to(() => const StatutScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            storyIcon,
                            color: appColor,
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 16),
                          'Statut'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    10.heightBox,
                    InkWell(
                      onTap: () {
                        Get.to(() => const NotificationsScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            notificationIcon,
                            color: appColor,
                          ),
                          const SizedBox(width: 16),
                          'Notifications'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    10.heightBox,
                    InkWell(
                      onTap: () {
                        Get.to(
                            () => ChatScreen(
                                  orderId: 1,
                                  currentUserId: 1,
                                  receiverId: 1,
                                ),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat,
                            color: appColor,
                          ),
                          const SizedBox(width: 16),
                          'Chat'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              20.heightBox,
              Container(
                padding: const EdgeInsets.all(12.0),
                width: 265,
                height: 126,
                decoration: BoxDecoration(
                    color: white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => const HelpSupportScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Row(
                        children: [
                          Image.asset(supportIcons),
                          const SizedBox(width: 16),
                          'Help & Support'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => const LanguagesScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 600));
                      },
                      child: Row(
                        children: [
                          Image.asset(languageIcon),
                          const SizedBox(width: 16),
                          'Language'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          Image.asset(aboutIcon),
                          const SizedBox(width: 16),
                          'About Us'
                              .text
                              .color(fontGrey)
                              .fontWeight(FontWeight.w400)
                              .make(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              20.heightBox,
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: Colors.white,
                  child: ListTile(
                    leading: Image.asset(logOut),
                    title: 'Log Out'
                        .text
                        .color(fontGrey)
                        .fontWeight(FontWeight.w400)
                        .make(),
                    onTap: () async {
                      await userProvider.logout();
                      Get.offAll(() => const SignInScreen(),
                          transition: Transition.upToDown,
                          duration: const Duration(milliseconds: 500));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
