import 'dart:math';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/util.dart';
import 'package:odrive_restaurant/common/widgets/caractere_limit.dart';
import 'package:odrive_restaurant/common/widgets/distance_calculator.dart';
import 'package:odrive_restaurant/model/order.dart';

class OrderCard1 extends StatefulWidget {
  final bool isNewTab;
  final bool isActiveTab;
  final bool isHistoryTab;
  Order order;
  final VoidCallback refreshCallback;

  OrderCard1({
    Key? key,
    required this.isNewTab,
    required this.isActiveTab,
    required this.isHistoryTab,
    required this.order,
    required this.refreshCallback,
  }) : super(key: key);

  @override
  State<OrderCard1> createState() => _OrderCard1State();
}

class _OrderCard1State extends State<OrderCard1> {
  double value = 0;

  _acceptSuccess() {
    widget.refreshCallback.call();
    Fluttertoast.showToast(msg: "Commande acceptée");
  }

  _completeSuccess(int status) {
    widget.refreshCallback.call();
    Fluttertoast.showToast(msg: status == 2 ? "Commande acceptée" : "Opération effectuée");
  }

  _error(String error) {
    Fluttertoast.showToast(msg: "Erreur: $error");
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final distance = DistanceCalculatorWidget(
      latitude1: double.parse(order.lat),
      longitude1: double.parse(order.lng),
      latitude2: double.parse(order.latRest),
      longitude2: double.parse(order.lngRest),
    );

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(seconds: 0),
      builder: (_, double val, __) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..setEntry(0, 3, 200 * val)
            ..rotateY(pi / 12)
            ..rotateX(pi / -100),
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => OrderDetails(
                      order: widget.order,
                      distance: distance,
                      history: widget.isHistoryTab,
                      acceptSuccess: (int status) => _completeSuccess(status),
                    ),
                  ),
                )
                    .then((isUpdated) {
                  if (isUpdated == true) {
                    print("Order updated");
                    // orderProvider.fetchOrders(); // Rafraîchir la liste après le retour
                  }
                });
                // Get.to(
                //   () => OrderDetails(
                //     order: order,
                //     distance: distance,
                //     history: widget.isHistoryTab,
                //   ),
                //   duration: const Duration(milliseconds: 500),
                //   transition: Transition.downToUp,
                // );
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: blue, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.4),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(5, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.ordersData
                            .isNotEmpty) // Vérifier si la liste n'est pas vide
                          Transform(
                            transform: Matrix4.identity()
                              ..rotateY(-130 * 2 / 250),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                border: Border.all(color: blue, width: 1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Image.network(
                                "$serverImages${order.ordersData[0].image}",
                                height: 55,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: blue, width: 1),
                            ),
                            child: const Center(
                              child: Text(
                                'No Image',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            boldText(
                              text: 'Order ID #${order.id}',
                              color: blackColor,
                              size: 18.0,
                            ),
                            Row(
                              children: [
                                Image.asset(icCalender),
                                5.widthBox,
                                normalText(
                                  text: '${order.updatedAt}',
                                  color: fontGrey.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            boldText(
                              text:
                                  '${double.parse(order.total).toStringAsFixed(0)} F',
                              size: 17.0,
                              color: blackColor,
                            ),
                            Row(
                              children: [
                                normalText(
                                  text: '${order.method}',
                                  color: fontGrey.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        normalText(
                          text: 'Customer Name:',
                          color: fontGrey.withOpacity(0.7),
                        ),
                        boldText(
                          text: "${order.userName}",
                          color: appColor,
                          size: 16.0,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(icLocation),
                        2.widthBox,
                        CharacterLimitWidget(
                          text: '${order.address}',
                          style: TextStyle(
                              color: fontGrey.withOpacity(0.7), fontSize: 9),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (widget.isNewTab || widget.isActiveTab)
                              customButton(
                                width: MediaQuery.of(context).size.width * 0.26,
                                height: 42,
                                color: getStatus(order.status)["color"],
                                context: context,
                                title: getStatus(order.status)["title"],
                                onPress: () {},
                              )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrderCard2 extends StatefulWidget {
  final bool isNewTab;

  const OrderCard2({super.key, required this.isNewTab});

  @override
  State<OrderCard2> createState() => _OrderCard2State();
}

class _OrderCard2State extends State<OrderCard2> {
  double value = 0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(seconds: 0),
      builder: (_, double val, __) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..setEntry(0, 3, 200 * val)
            ..rotateY(pi / -12)
            ..rotateX(pi / 100),
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: InkWell(
              onTap: () {
                /* Get.to(
                    () => OrderDetails(
                          order: {},
                          distance: ,
                        ),
                    duration: const Duration(milliseconds: 500),
                    transition: Transition.downToUp); */
              },
              child: Container(
                // width: MediaQuery.of(context).size.width * 0.92,
                // height: MediaQuery.of(context).size.height * 0.35,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: blue, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.4),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(5, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform(
                            transform: Matrix4.identity()
                              ..rotateY(-70 * 2 / 250),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  border: Border.all(color: blue, width: 1),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Image.asset(
                                shwarma,
                                height: 55,
                              ),
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            boldText(
                                text: 'Shawarma',
                                color: blackColor,
                                size: 18.0),
                            normalText(
                                text: 'x1', color: fontGrey.withOpacity(0.7)),
                            normalText(text: 'Order ID #81', color: fontGrey),
                            Row(
                              children: [
                                Image.asset(icCalender),
                                5.widthBox,
                                Text(
                                  'Date: 2024-05-22 / 00:20:13',
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: fontGrey.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            normalText(
                              text: 'Ready',
                              color: fontGrey.withOpacity(0.7),
                            ),
                            boldText(
                                text: '\$50.00', size: 17.0, color: blackColor),
                            Row(
                              children: [
                                normalText(
                                    text: 'Driver fee:',
                                    color: fontGrey.withOpacity(0.7)),
                                boldText(text: ' 5F', color: appColor),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        normalText(
                            text: 'Distance:',
                            color: fontGrey.withOpacity(0.7)),
                        boldText(
                            text: '  6.651 km', color: appColor, size: 16.0)
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(icShop),
                        2.widthBox,
                        Text(
                          'Lorem Ipsum shop',
                          style: TextStyle(
                              color: fontGrey.withOpacity(0.7), fontSize: 9.0),
                        ),
                        const Spacer(),
                        boldText(text: 'Open Map', color: appColor),
                        5.widthBox,
                        const Icon(
                          Icons.location_on,
                          color: appColor,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Row(
                        children: [
                          Image.asset(
                            icLine,
                            color: appColor,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(icLocation),
                        2.widthBox,
                        Text(
                          'Lorem Ipsum home',
                          style: TextStyle(
                              color: fontGrey.withOpacity(0.7), fontSize: 9),
                        ),
                        const Spacer(),
                        if (widget.isNewTab)
                          customButton(
                              width: MediaQuery.of(context).size.width * 0.26,
                              height: 42,
                              context: context,
                              color: appColor,
                              title: 'Rejected',
                              onPress: () {}),
                        5.widthBox,
                        customButton(
                            width: MediaQuery.of(context).size.width * 0.26,
                            height: 42,
                            color: widget.isNewTab ? grey : appColor,
                            context: context,
                            title: widget.isNewTab ? 'Accept' : 'Completed',
                            onPress: () {})
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
