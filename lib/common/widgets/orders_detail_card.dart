import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/util.dart';
import 'package:odrive_restaurant/common/widgets/caractere_limit.dart';
import 'package:odrive_restaurant/common/widgets/distance_calculator.dart';
import 'package:odrive_restaurant/model/order.dart';
import 'package:odrive_restaurant/model/orderData.dart';
import 'package:odrive_restaurant/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/* class OrdersDetailCard1 extends StatefulWidget {
  const OrdersDetailCard1({
    super.key,
  });

  @override
  State<OrdersDetailCard1> createState() => _OrdersDetailCard1State();
}

class _OrdersDetailCard1State extends State<OrdersDetailCard1> {
  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            /* Get.to(
                () => OrderDetails(
                      order: {},
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
                        transform: Matrix4.identity()..rotateY(-70 * 2 / 250),
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
                            text: 'Shawarma', color: blackColor, size: 18.0),
                        normalText(
                            text: 'x1', color: fontGrey.withOpacity(0.7)),
                        '50 x1 =50'
                            .text
                            .fontWeight(FontWeight.bold)
                            .size(12)
                            .make(),
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
                        '50.00'
                            .text
                            .size(18)
                            .fontWeight(FontWeight.bold)
                            .make(),
                        'SubTotal:50.00 '
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Shopping Cost:00 '
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Total:150.00 '
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Taxs:100.00 '
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    normalText(
                        text: 'Distance:', color: fontGrey.withOpacity(0.7)),
                    boldText(text: ' 6.651 km', color: appColor, size: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(icShop),
                    5.widthBox,
                    'Lorem Ipsum Shop'
                        .text
                        .size(10)
                        .color(fontGrey.withOpacity(0.7))
                        .make(),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Image.asset(icLocation),
                      5.widthBox,
                      'Lorem Ipsum home'
                          .text
                          .size(10)
                          .color(fontGrey.withOpacity(0.7))
                          .make(),
                      const Spacer(),
                      Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              'Order ID #81'
                                  .text
                                  .size(12)
                                  .fontWeight(FontWeight.w600)
                                  .color(blackColor)
                                  .make(),
                              Row(
                                children: [
                                  Image.asset(icCalender),
                                  5.widthBox,
                                  'Date: 2024-05-22 / 00:20:13'
                                      .text
                                      .size(10)
                                      .overflow(TextOverflow.ellipsis)
                                      .color(fontGrey.withOpacity(0.7))
                                      .make(),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: white,
                                backgroundImage: AssetImage(dpIcon),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  'RAO ZULQURNAIN'
                                      .text
                                      .size(10)
                                      .fontWeight(FontWeight.w600)
                                      .color(blackColor)
                                      .make(),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.call,
                                        color: appColor,
                                        size: 8,
                                      ),
                                      5.widthBox,
                                      '+1 234 567 897'
                                          .text
                                          .size(12)
                                          .fontWeight(FontWeight.w600)
                                          .color(fontGrey.withOpacity(0.7))
                                          .make(),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButton(
                width: MediaQuery.of(context).size.width * 0.45,
                height: 42,
                context: context,
                color: grey,
                title: 'Delivery Status',
                onPress: () {}),
            5.widthBox,
            customButton(
                width: MediaQuery.of(context).size.width * 0.45,
                height: 42,
                color: appColor,
                context: context,
                title: 'Call to Customer',
                onPress: () {})
          ],
        )
      ],
    );
  }
} */

class OrdersDetailCard2 extends StatefulWidget {
  Order order;
  DistanceCalculatorWidget distance;
  bool history;
  Function(int) acceptSuccess;

  OrdersDetailCard2(
      {super.key,
      required this.order,
      required this.distance,
      required this.history,
      required this.acceptSuccess});

  @override
  State<OrdersDetailCard2> createState() => _OrdersDetailCard2State();
}

class _OrdersDetailCard2State extends State<OrdersDetailCard2> {
  double value = 0;
  double subTotal = 0.0;

  late String _statusText = "Preparing";
  late bool _isLoadingStatus = false;
  late bool _isLoadingStatusCancel = false;

  @override
  void initState() {
    super.initState();
  }

  // Met à jour le texte de statut en fonction du statut actuel de la commande
  // void _updateOrderStatusText(int status, {String? curbsidePickup}) {
  //   print(curbsidePickup);
  //   print("order s: ${widget.order.driver}");
  //   setState(() {
  //     if (status == 2) {
  //       _statusText = "Ready";
  //     } else if (status == 3) {
  //       _statusText = "Set Driver";
  //       // if (curbsidePickup == "true") {
  //       //   _statusText = "Delivered";
  //       // }
  //       // else {
  //       //   _statusText = "Change Driver";
  //       // }
  //     } else if (status == 5) {
  //       _statusText = "Delivered";
  //     } else {
  //       _statusText = "Preparing";
  //     }

  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final distance = widget.distance;
    OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    List<OrderData> detail = order.ordersData;
    String? name = order.friend == 0 ? order.userName : order.friendName;

    String? phone = order.friend == 0 ? order.phone : order.friendPhone;

    String cName = order.userName;
    String cPhone = order.phone;
    detail.forEach((detail) {
      // Ajout du prix du produit au sous-total
      subTotal += detail.foodPrice != "0.00"
          ? (double.parse(detail.foodPrice) * detail.count)
          : (double.parse(detail.extrasPrice) * detail.extrasCount);
    });

    // var _text = "Preparing";
    // // var _status = _getStatus(order.status); // "Received"
    // if (order.status == 2) // "Preparing"
    //   _text = "Ready";
    // if (order.status == 3) // "Ready",
    //   _text =  "Set Driver";
    // if (order.status > 2) if (order.curbsidePickup == "true")
    //   _text = _text =
    //       "Delivered";

    var _name = "";
    // if (order.driver != "0") {
    //   // for (var _driver in _drivers) if (_driver.id == _data.driver) _name = _driver.name;
    //   _text =  "Change Driver";
    // }
    Order? _driverSetData;
    String _state = "root";
    Widget _dialogBody = Container();
    bool _wait = false;
    double _show = 0;
    List<DriversData> _drivers = [];

    _waits(bool value) {
      _wait = value;
      if (mounted) setState(() {});
    }

    _openDialogError(String _text) {
      _waits(false);
      _dialogBody = Column(
        children: [
          Text(
            _text,
          ),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              setState(() {
                _show = 0;
              });
            },
            child: Text("cancel"), // Cancel
          ),
        ],
      );
      setState(() {
        _show = 1;
      });
    }

    // Met à jour le texte de statut en fonction du statut actuel de la commande
    void _updateOrderStatusText(int status, {String? curbsidePickup}) {
      print(curbsidePickup);
      print("order s: ${widget.order.driver}");
      setState(() {
        if (status == 2) {
          _statusText = "Ready";
        } else if (status == 3) {
          _statusText = "Set Driver";
          // if (curbsidePickup == "true") {
          //   _statusText = "Delivered";
          // }
          // else {
          //   _statusText = "Change Driver";
          // }
        } else if (status == 5) {
          _statusText = "Delivered";
        } else {
          _statusText = "Preparing";
        }
        print(order.driver);
        if (order.driver != 0) {
          for (var _driver in _drivers)
            if (_driver.id == order.driver) {
              _name = _driver.name;
            }
          _statusText = "Change Driver";
        }
      });
    }

    _updateOrderStatusText(widget.order.status);

    _driverSelect(String id) {
      print("Selected driver with id: $id");

      if (_driverSetData == null) return;

      orderProvider.changeDriver(_driverSetData!.id.toString(), id, () {
        _driverSetData!.driver = toInt(id);
        setState(() {
          _statusText = "Change Driver";
          _isLoadingStatus = false;
        });
      }, _openDialogError);

      _state = "orderDetails";
      setState(() {});
    }

    _setDriver(Order _data) async {
      _driverSetData = _data;
      _state = "drivers";
      print(_data.haveDelivery);
      if (_data.haveDelivery == 0) {
        try {
          _drivers = await orderProvider
              .getNearestDrivers(_data.restaurant.toString());
          setState(() {
            _drivers = _drivers;
          });
          print(_drivers);
          _drivers.forEach((driver) async {
            print(driver.toString_());
            await _driverSelect(driver.id);
            // await Future.delayed(Duration(minutes: 1));
            bool status =
                await orderProvider.fetchOrdertimeStatus(_data.id.toString());
            if (status) {
              print(
                  "La valeur 9 a été trouvée dans la colonne ordertimeStatus.");
              return;
            } else {
              print(
                  "*************************************************************");
            }
          });

          setState(() {
            _isLoadingStatus = false;
          });
        } catch (e) {
          // Gérer les erreurs ici
          print("Erreur lors de la récupération des données : $e");
        }
      }
    }

    _changeStatus(Order _data, int status) {
      print("***********order*********");
      print(status);
      orderProvider.changeStatus(order.id.toString(), status.toString(), () {
        print("----------------- ${order.status}");
        _updateOrderStatusText(status, curbsidePickup: order.curbsidePickup);
        setState(() {
          _isLoadingStatus = false;
          _isLoadingStatusCancel = false;
          order.status = status;
        });
        widget.acceptSuccess.call(status);
      }, (error) {
        print(error);
      });
    }

    void _showCancelConfirmationDialog(Order order) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content:
                const Text('Voulez-vous vraiment annuler cette commande ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: const Text('Non'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoadingStatusCancel = true;
                  });
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  _changeStatus(
                      order, 6); // Annuler la commande avec le statut 6
                },
                child: const Text('Oui'),
              ),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.to(
                () => OrderDetails(
                    order: widget.order,
                    distance: widget.distance,
                    history: widget.history,
                    acceptSuccess: widget.acceptSuccess),
                duration: const Duration(milliseconds: 500),
                transition: Transition.downToUp);
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
                Column(
                  children: detail.map((detail) {
                    return Column(
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
                                child: Image.network(
                                  "$serverImages${detail.image}",
                                  height: 55,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                boldText(
                                  text: detail.food != ""
                                      ? detail.food
                                      : detail.extras,
                                  color: blackColor,
                                  size: 18.0,
                                ),
                                normalText(
                                  text:
                                      'x${detail.count != 0 ? detail.count : detail.extrasCount}',
                                  color: fontGrey.withOpacity(0.7),
                                ),
                                '${detail.foodPrice != "0.00" ? detail.foodPrice : detail.extrasPrice} F x${detail.count != 0 ? detail.count : detail.extrasCount} = ${(detail.foodPrice != "0.00" ? double.parse(detail.foodPrice) : double.parse(detail.extrasPrice)) * (detail.count != 0 ? detail.count : detail.extrasCount)} F'
                                    .text
                                    .fontWeight(FontWeight.bold)
                                    .size(12)
                                    .make(),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                normalText(
                                  text: getStatus(order.status)["title"],
                                  color: fontGrey.withOpacity(0.7),
                                ),
                                '${(detail.foodPrice != "0.00" ? double.parse(detail.foodPrice) : double.parse(detail.extrasPrice)) * (detail.count != 0 ? detail.count : detail.extrasCount)} F'
                                    .text
                                    .size(18)
                                    .fontWeight(FontWeight.bold)
                                    .make(),
                              ],
                            )
                          ],
                        ),
                        12.heightBox,
                      ],
                    );
                  }).toList(),
                ),
                12.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        'SubTotal:${subTotal.toStringAsFixed(2)} F'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Shopping Cost:${order.fee} F'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Taxs:${order.tax} F'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Total:${order.total} F'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                      ],
                    )
                  ],
                ),
                Divider(
                  color: blue,
                  thickness: 1,
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Method:'),
                    Text('${order.method}'),
                  ],
                ),
                const Divider(
                  color: blue,
                  thickness: 1,
                  height: 20,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              normalText(
                                  text: 'Distance:',
                                  color: fontGrey.withOpacity(0.7)),
                              distance,
                              //boldText(text: ' 6.651 km', color: appColor, size: 16.0),
                              // SizedBox(
                              //   width: MediaQuery.of(context).size.width * 0.04,
                              // ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(icShop),
                              5.widthBox,
                              CharacterLimitWidget(
                                text: '${order.addressDest}',
                                style: TextStyle(
                                    color: fontGrey.withOpacity(0.7),
                                    fontSize: 9),
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Image.asset(icLocation),
                                5.widthBox,
                                CharacterLimitWidget(
                                  text: '${order.address}',
                                  style: TextStyle(
                                      color: fontGrey.withOpacity(0.7),
                                      fontSize: 9),
                                ),
                                // const Spacer(),
                              ],
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              'Order ID #${order.id}'
                                  .text
                                  .size(12)
                                  .fontWeight(FontWeight.w600)
                                  .color(blackColor)
                                  .make(),
                              Row(
                                children: [
                                  Image.asset(icCalender),
                                  5.widthBox,
                                  'Date: ${order.updatedAt}'
                                      .text
                                      .size(10)
                                      .overflow(TextOverflow.ellipsis)
                                      .color(fontGrey.withOpacity(0.7))
                                      .make(),
                                ],
                              ),
                            ],
                          ),
                          order.friend == 1
                              ? Row(
                                  children: [
                                    /* const CircleAvatar(
                                backgroundColor: white,
                                backgroundImage: AssetImage(dpIcon),
                              ), */
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        '$name (Ami)'
                                            .text
                                            .size(10)
                                            .fontWeight(FontWeight.w600)
                                            .color(blackColor)
                                            .make(),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.call,
                                              color: appColor,
                                              size: 8,
                                            ),
                                            5.widthBox,
                                            phone!.text
                                                .size(12)
                                                .fontWeight(FontWeight.w600)
                                                .color(
                                                    fontGrey.withOpacity(0.7))
                                                .make(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Container(),
                          Row(
                            children: [
                              /* const CircleAvatar(
                                backgroundColor: white,
                                backgroundImage: AssetImage(dpIcon),
                              ), */
                              const SizedBox(
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  cName.text
                                      .size(10)
                                      .fontWeight(FontWeight.w600)
                                      .color(blackColor)
                                      .make(),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.call,
                                        color: appColor,
                                        size: 8,
                                      ),
                                      5.widthBox,
                                      cPhone.text
                                          .size(12)
                                          .fontWeight(FontWeight.w600)
                                          .color(fontGrey.withOpacity(0.7))
                                          .make(),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]),
                const Divider(
                  color: blue,
                  thickness: 1,
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () {
                          Get.to(() => MapScreen(order: order));
                        },
                        child: Container(
                            // width: MediaQuery.of(context).size.width * 0.45,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xD2D2D2).withOpacity(0.5),
                            ),
                            child: Row(
                              children: [
                                boldText(text: 'Open map', color: blackColor),
                                5.heightBox,
                                const Icon(
                                  size: 20,
                                  Icons.location_on,
                                  color: appColor,
                                ),
                              ],
                            ))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        'Driver name'
                            .text
                            .size(10)
                            .overflow(TextOverflow.ellipsis)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        order.friend == 1
                            ? Row(
                                children: [
                                  /* const CircleAvatar(
                                backgroundColor: white,
                                backgroundImage: AssetImage(dpIcon),
                              ), */
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      '$name (Ami)'
                                          .text
                                          .size(10)
                                          .fontWeight(FontWeight.w600)
                                          .color(blackColor)
                                          .make(),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.call,
                                            color: appColor,
                                            size: 8,
                                          ),
                                          5.widthBox,
                                          phone!.text
                                              .size(12)
                                              .fontWeight(FontWeight.w600)
                                              .color(fontGrey.withOpacity(0.7))
                                              .make(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Container(),
                        Row(
                          children: [
                            /* const CircleAvatar(
                                backgroundColor: white,
                                backgroundImage: AssetImage(dpIcon),
                              ), */
                            const SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                order.userName.text
                                    .size(10)
                                    .fontWeight(FontWeight.w600)
                                    .color(blackColor)
                                    .make(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.call,
                                      color: appColor,
                                      size: 8,
                                    ),
                                    5.widthBox,
                                    order.phone.text
                                        .size(12)
                                        .fontWeight(FontWeight.w600)
                                        .color(fontGrey.withOpacity(0.7))
                                        .make(),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (order.status < 5)
              customButton(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: 42,
                  context: context,
                  color: !widget.history ? appColor : Color(0xD2D2D2),
                  title: _statusText,
                  isLoading: _isLoadingStatus,
                  onPress: () {
                    setState(() {
                      _isLoadingStatus = true;
                    });
                    if (order.status == 3) {
                      if (order.curbsidePickup == "true") {
                        _changeStatus(order, 5); // delivered
                      } else {
                        print(order);
                        //getNearestDrivers(_data.restaurant);
                        _setDriver(order);
                      }
                    } else
                      _changeStatus(order, order.status + 1);
                  }),
            5.widthBox,
            if (order.status < 5)
              customButton(
                width: MediaQuery.of(context).size.width * 0.3,
                height: 42,
                context: context,
                color: Colors.red,
                title: 'Cancel',
                isLoading: _isLoadingStatusCancel,
                onPress: () {
                  _showCancelConfirmationDialog(order);
                },
              ),
          ],
        ),
        5.widthBox,
        customButton(
            width: MediaQuery.of(context).size.width * 0.45,
            height: 42,
            color: !widget.history ? appColor : grey,
            context: context,
            title: 'Call to Customer',
            onPress: () {
              if (!widget.history) {
                launchPhone(phone!);
              }
            })
      ],
    );
  }
}

_phoneCall(String phoneNumber) async {
  // Nettoyer le numéro de téléphone en supprimant tous les caractères non numériques
  String cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

  // Vérifier si le numéro de téléphone nettoyé est valide
  if (cleanedPhoneNumber.isNotEmpty) {
    await launch('tel:$cleanedPhoneNumber');
  } else {
    throw 'Numéro de téléphone invalide';
  }
}

Future<void> launchPhone(String phoneNumber) async {
  final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
  await launch(phoneLaunchUri.toString());
  /* if (await canLaunch(phoneLaunchUri.toString())) {
    await launch(phoneLaunchUri.toString());
  } else {
    throw 'Could not launch $phoneLaunchUri';
  } */
}
