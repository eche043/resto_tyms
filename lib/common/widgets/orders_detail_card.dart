import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/util.dart';
import 'package:odrive_restaurant/common/widgets/caractere_limit.dart';
import 'package:odrive_restaurant/common/widgets/distance_calculator.dart';
import 'package:odrive_restaurant/model/order.dart';
import 'package:odrive_restaurant/model/orderData.dart';
import 'package:odrive_restaurant/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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

  // Variables pour la gestion des livreurs
  Order? _driverSetData;
  String _state = "root";
  Widget _dialogBody = Container();
  bool _wait = false;
  double _show = 0;
  List<DriversData> _drivers = [];
  var _name = "";

  @override
  void initState() {
    super.initState();
    _updateOrderStatusText(widget.order.status,
        curbsidePickup: widget.order.curbsidePickup);
  }

  _waits(bool value) {
    _wait = value;
    if (mounted) setState(() {});
  }

  _openDialogError(String _text) {
    _waits(false);
    _dialogBody = Column(
      children: [
        Text(_text),
        const SizedBox(height: 40),
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
          child: Text("Cancel"),
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
      } else if (status == 5) {
        _statusText = "Delivered";
      } else {
        _statusText = "Preparing";
      }

      print(widget.order.driver);
      if (widget.order.driver != 0) {
        for (var _driver in _drivers) {
          if (_driver.id == widget.order.driver.toString()) {
            _name = _driver.name;
          }
        }
        _statusText = "Change Driver";
      }
    });
  }

  _driverSelect(String id) {
    print("Selected driver with id: $id");

    if (_driverSetData == null) return;

    OrderProvider orderProvider =
        Provider.of<OrderProvider>(context, listen: false);
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

    OrderProvider orderProvider =
        Provider.of<OrderProvider>(context, listen: false);

    if (_data.haveDelivery == 0) {
      try {
        _drivers =
            await orderProvider.getNearestDrivers(_data.restaurant.toString());
        setState(() {
          _drivers = _drivers;
        });
        print(_drivers);

        for (var driver in _drivers) {
          print(driver.toString_());
          await _driverSelect(driver.id);

          bool status =
              await orderProvider.fetchOrdertimeStatus(_data.id.toString());
          if (status) {
            print("La valeur 9 a été trouvée dans la colonne ordertimeStatus.");
            return;
          } else {
            print(
                "*************************************************************");
          }
        }

        setState(() {
          _isLoadingStatus = false;
        });
      } catch (e) {
        print("Erreur lors de la récupération des données : $e");
        setState(() {
          _isLoadingStatus = false;
        });
      }
    }
  }

  _changeStatus(Order _data, int status) {
    print("***********order*********");
    print(status);

    OrderProvider orderProvider =
        Provider.of<OrderProvider>(context, listen: false);
    orderProvider.changeStatus(_data.id.toString(), status.toString(), () {
      print("----------------- ${_data.status}");
      _updateOrderStatusText(status, curbsidePickup: _data.curbsidePickup);
      setState(() {
        _isLoadingStatus = false;
        _isLoadingStatusCancel = false;
        _data.status = status;
      });
      widget.acceptSuccess.call(status);
    }, (error) {
      print(error);
      setState(() {
        _isLoadingStatus = false;
        _isLoadingStatusCancel = false;
      });
    });
  }

  void _showCancelConfirmationDialog(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment annuler cette commande ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoadingStatusCancel = true;
                });
                Navigator.of(context).pop();
                _changeStatus(order, 6); // Annuler la commande avec le statut 6
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final distance = widget.distance;
    List<OrderData> detail = order.ordersData;
    String? name = order.friend == 0 ? order.userName : order.friendName;
    String? phone = order.friend == 0 ? order.phone : order.friendPhone;

    // Calcul du sous-total
    subTotal = 0.0;
    detail.forEach((detail) {
      subTotal += detail.foodPrice != "0.00"
          ? (double.parse(detail.foodPrice) * detail.count)
          : (double.parse(detail.extrasPrice) * detail.extrasCount);
    });

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
                // En-tête avec informations de base
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        'Order ID: #${order.id}'
                            .text
                            .size(18)
                            .fontWeight(FontWeight.bold)
                            .make(),
                        'Date: ${order.createdAt}'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Distance: ${distance.calculateDistance(
                                  double.parse(order.lat),
                                  double.parse(order.lng),
                                  double.parse(order.latRest),
                                  double.parse(order.lngRest),
                                ).toStringAsFixed(2)} km'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: getStatus(order.status)["title"]
                              .toString()
                              .text
                              .size(12)
                              .fontWeight(FontWeight.w600)
                              .color(Colors.white)
                              .make(),
                        ),
                      ],
                    ),
                  ],
                ),

                12.heightBox,

                // Liste des articles commandés
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
                                  width: 55,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 55,
                                      width: 55,
                                      decoration: BoxDecoration(
                                        color: grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(Icons.image_not_supported,
                                          color: grey),
                                    );
                                  },
                                ),
                              ),
                            ),
                            12.widthBox,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  boldText(
                                    text: detail.food != ""
                                        ? detail.food
                                        : detail.extras,
                                    color: blackColor,
                                    size: 16.0,
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
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
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

                // Résumé financier
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bouton Open Map à gauche
                    InkWell(
                      onTap: () {
                        Get.to(() => MapScreen(order: order));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFD2D2D2).withOpacity(0.5),
                          border: Border.all(
                            color: appColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: appColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Open Map',
                              style: TextStyle(
                                color: blackColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        'SubTotal: ${subTotal.toStringAsFixed(2)} F'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Shopping Cost: ${order.fee} F'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Taxes: ${order.tax} F'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.normal)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                        'Total: ${order.total} F'
                            .text
                            .size(20)
                            .fontWeight(FontWeight.bold)
                            .make(),
                      ],
                    ),
                  ],
                ),

                12.heightBox,

                // Informations client
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: appColor, size: 16),
                          8.widthBox,
                          'Client: ${name ?? 'N/A'}'
                              .text
                              .size(14)
                              .fontWeight(FontWeight.w600)
                              .make(),
                        ],
                      ),
                      8.heightBox,
                      Row(
                        children: [
                          Icon(Icons.phone, color: appColor, size: 16),
                          8.widthBox,
                          '${phone ?? 'N/A'}'
                              .text
                              .size(12)
                              .fontWeight(FontWeight.w600)
                              .color(fontGrey.withOpacity(0.7))
                              .make(),
                        ],
                      ),
                      8.heightBox,
                      Row(
                        children: [
                          Icon(Icons.location_on, color: appColor, size: 16),
                          8.widthBox,
                          Expanded(
                            child: CharacterLimitWidget(
                              text: order.address,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: fontGrey.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Section des boutons redesignés
        _buildActionButtons(context, order),
      ],
    );
  }

  // Nouvelle section des boutons redesignés
  Widget _buildActionButtons(BuildContext context, Order order) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Première ligne de boutons
          Row(
            children: [
              // Bouton de statut de commande
              if (order.status < 5)
                Expanded(
                  flex: order.status >= 2
                      ? 1
                      : 3, // ✅ Prend toute la largeur si pas de bouton annuler
                  child: _buildStatusButton(order),
                ),

              // Espacement seulement si les deux boutons sont visibles
              if (order.status < 5 && order.status < 2) SizedBox(width: 8),

              // Bouton d'annulation - ✅ Masqué si status >= 2
              if (order.status < 5 && order.status < 2)
                Expanded(
                  flex: 2,
                  child: _buildCancelButton(order),
                ),
            ],
          ),

          SizedBox(height: 12),

          // Deuxième ligne de boutons
          Row(
            children: [
              // Bouton d'appel client
              Expanded(
                child: _buildCallButton(order),
              ),

              SizedBox(width: 8),

              // Bouton d'impression du reçu
              Expanded(
                child: _buildPrintReceiptButton(order),
              ),
            ],
          ),

          // Troisième ligne - Bouton Scanner QR (seulement si un livreur est affecté)
          if (order.driver != 0 && order.status >= 3 && order.status < 5) ...[
            SizedBox(height: 12),
            _buildScanQRButton(order),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusButton(Order order) {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoadingStatus
            ? null
            : () {
                setState(() {
                  _isLoadingStatus = true;
                });
                if (order.status == 3) {
                  if (order.curbsidePickup == "true") {
                    _changeStatus(order, 5); // delivered
                  } else {
                    _setDriver(order);
                  }
                } else {
                  _changeStatus(order, order.status + 1);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: !widget.history ? appColor : Color(0xFFD2D2D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoadingStatus
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(order.status), size: 18),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _statusText,
                      style: TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCancelButton(Order order) {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoadingStatusCancel
            ? null
            : () {
                _showCancelConfirmationDialog(order);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoadingStatusCancel
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Annuler',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCallButton(Order order) {
    String? phone = order.friend == 0 ? order.phone : order.friendPhone;

    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: !widget.history
            ? () {
                if (phone != null && phone.isNotEmpty) {
                  launchPhone(phone);
                } else {
                  Fluttertoast.showToast(
                      msg: "Numéro de téléphone non disponible");
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: !widget.history ? appColor : Colors.grey.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone, size: 18),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Appeler Client',
                style: TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintReceiptButton(Order order) {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: () => _printOrderReceipt(order),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.print, size: 18),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Imprimer',
                style: TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanQRButton(Order order) {
    return Container(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _showQRScannerDialog(order),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 20),
            SizedBox(width: 12),
            Text(
              'Scanner QR Code Livreur',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes utilitaires

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.indigo;
      case 5:
        return Colors.green;
      case 6:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 1:
        return Icons.restaurant_menu;
      case 2:
        return Icons.check_circle_outline;
      case 3:
        return Icons.delivery_dining;
      case 4:
        return Icons.directions_car;
      default:
        return Icons.hourglass_empty;
    }
  }

  void _printOrderReceipt(Order order) async {
    try {
      final pdf = pw.Document();

      // Calculer le sous-total
      double calculatedSubTotal = 0.0;
      for (var item in order.ordersData) {
        calculatedSubTotal += item.foodPrice != "0.00"
            ? (double.parse(item.foodPrice) * item.count)
            : (double.parse(item.extrasPrice) * item.extrasCount);
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // En-tête
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'REÇU DE COMMANDE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Commande #${order.id}',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                      pw.Text(
                        'Date: ${order.createdAt}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Informations client
                pw.Container(
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INFORMATIONS CLIENT',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                          'Nom: ${order.friend == 0 ? order.userName : order.friendName}'),
                      pw.Text(
                          'Téléphone: ${order.friend == 0 ? order.phone : order.friendPhone}'),
                      pw.Text('Adresse: ${order.address}'),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Détails de la commande
                pw.Text(
                  'DÉTAILS DE LA COMMANDE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Tableau des articles
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // En-tête du tableau
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Article',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Qté',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Prix unit.',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Total',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),

                    // Lignes des articles
                    ...order.ordersData.map((item) {
                      double price = item.foodPrice != "0.00"
                          ? double.parse(item.foodPrice)
                          : double.parse(item.extrasPrice);
                      int quantity = item.foodPrice != "0.00"
                          ? item.count
                          : item.extrasCount;
                      double total = price * quantity;

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                                item.food.isNotEmpty ? item.food : item.extras),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('$quantity'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('${price.toStringAsFixed(2)} FCFA'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('${total.toStringAsFixed(2)} FCFA'),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Résumé financier
                pw.Container(
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Sous-total:'),
                          pw.Text(
                              '${calculatedSubTotal.toStringAsFixed(2)} FCFA'),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Frais de livraison:'),
                          pw.Text('${order.fee} FCFA'),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Taxes:'),
                          pw.Text('${order.tax} FCFA'),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total:',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${order.total} FCFA',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Pied de page
                pw.Center(
                  child: pw.Text(
                    'Merci pour votre commande !',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Imprimer ou partager le PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      Fluttertoast.showToast(msg: "Reçu généré avec succès");
    } catch (e) {
      print('Erreur lors de la génération du reçu: $e');
      Fluttertoast.showToast(
        msg: "Erreur lors de la génération du reçu",
        backgroundColor: Colors.red,
      );
    }
  }

  void _showQRScannerDialog(Order order) {
    final TextEditingController qrController = TextEditingController();
    bool isLoading = false;
    bool showManualInput = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // En-tête avec dégradé
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [appColor, appColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.qr_code_scanner,
                                color: Colors.white, size: 24),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vérification Livreur',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Commande #${order.id}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (!showManualInput) ...[
                            // Zone de scan QR
                            Container(
                              height: 280,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: QRView(
                                  key: GlobalKey(debugLabel: 'QR'),
                                  onQRViewCreated:
                                      (QRViewController controller) {
                                    controller.scannedDataStream
                                        .listen((scanData) {
                                      if (scanData.code != null && !isLoading) {
                                        setDialogState(() {
                                          isLoading = true;
                                        });
                                        Navigator.of(context).pop();
                                        _handleQRCodeVerification(
                                            scanData.code!, order);
                                      }
                                    });
                                  },
                                  overlay: QrScannerOverlayShape(
                                    borderColor: appColor,
                                    borderRadius: 10,
                                    borderLength: 30,
                                    borderWidth: 10,
                                    cutOutSize: 200,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Instructions
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.blue.shade600, size: 20),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Pointez la caméra vers le QR code du livreur pour vérifier son identité',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Bouton saisie manuelle
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  showManualInput = true;
                                });
                              },
                              icon: Icon(Icons.keyboard, size: 18),
                              label: Text('Saisir le code manuellement'),
                              style: TextButton.styleFrom(
                                foregroundColor: appColor,
                              ),
                            ),
                          ] else ...[
                            // Saisie manuelle
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setDialogState(() {
                                          showManualInput = false;
                                        });
                                      },
                                      icon: Icon(Icons.arrow_back,
                                          color: appColor),
                                    ),
                                    Text(
                                      'Saisie manuelle du code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                TextField(
                                  controller: qrController,
                                  decoration: InputDecoration(
                                    labelText: 'Code QR du livreur',
                                    hintText: 'Saisissez le code du livreur',
                                    prefixIcon:
                                        Icon(Icons.qr_code, color: appColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: appColor, width: 2),
                                    ),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                ),

                                SizedBox(height: 20),

                                // Bouton de vérification
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            final code =
                                                qrController.text.trim();
                                            if (code.isEmpty) {
                                              Fluttertoast.showToast(
                                                msg: "Veuillez saisir un code",
                                                backgroundColor: Colors.red,
                                              );
                                              return;
                                            }

                                            setDialogState(() {
                                              isLoading = true;
                                            });

                                            Navigator.of(context).pop();
                                            _handleQRCodeVerification(
                                                code, order);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: appColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: isLoading
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text('Vérification...'),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.verified_user,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Vérifier le Code',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleQRCodeVerification(String qrCode, Order order) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(appColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Vérification en cours...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Validation du code QR du livreur',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Appeler l'API de vérification
      final response = await verifyDeliveryCode(qrCode, order.id);

      // Fermer le dialog de chargement
      Navigator.of(context).pop();

      if (response['error'] == '0') {
        // Succès - Afficher une notification de succès
        _showSuccessDialog(
            order, response['message'] ?? 'Code QR vérifié avec succès');

        // Mettre à jour le statut de la commande localement
        setState(() {
          widget.order.status = 4; // "On the Way"
          _updateOrderStatusText(4);
        });

        // Notifier le parent du changement
        widget.acceptSuccess(4);
      } else {
        // Erreur - Afficher le message d'erreur
        _showErrorDialog(response['error']);
      }
    } catch (e) {
      // Fermer le dialog de chargement s'il est ouvert
      Navigator.of(context).pop();

      print('Erreur lors de la vérification QR: $e');
      _showErrorDialog("Erreur lors de la vérification: ${e.toString()}");
    }
  }

// Nouvelle méthode pour afficher le succès
  void _showSuccessDialog(Order order, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône de succès
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 50,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'Vérification Réussie !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12),

                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8),

                Text(
                  'Commande #${order.id} est maintenant en cours de livraison',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Parfait !',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Toast pour feedback immédiat
    Fluttertoast.showToast(
      msg: "✅ Livreur vérifié - Commande en cours de livraison",
      backgroundColor: Colors.green,
      toastLength: Toast.LENGTH_LONG,
    );
  }

// Nouvelle méthode pour afficher les erreurs
  void _showErrorDialog(String errorMessage) {
    // Formater le message d'erreur
    String formattedMessage = errorMessage;
    IconData errorIcon = Icons.error_outline;
    Color errorColor = Colors.red;

    if (errorMessage.contains('Code QR invalide')) {
      formattedMessage =
          'Le code QR scanné ne correspond pas à cette commande. Veuillez vérifier le code du livreur.';
      errorIcon = Icons.qr_code_2;
    } else if (errorMessage.contains('déjà en cours')) {
      formattedMessage = 'Cette commande est déjà en cours de livraison.';
      errorIcon = Icons.delivery_dining;
      errorColor = Colors.orange;
    } else if (errorMessage.contains('pas encore payée')) {
      formattedMessage = 'Cette commande n\'est pas encore payée.';
      errorIcon = Icons.payment;
    } else if (errorMessage.contains('Aucun livreur')) {
      formattedMessage = 'Aucun livreur n\'est assigné à cette commande.';
      errorIcon = Icons.person_off;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône d'erreur
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    errorIcon,
                    color: errorColor,
                    size: 50,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'Vérification Échouée',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12),

                Text(
                  formattedMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Fermer',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Rouvrir le scanner pour essayer à nouveau
                          Future.delayed(Duration(milliseconds: 300), () {
                            _showQRScannerDialog(widget.order);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Réessayer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // Toast pour feedback immédiat
    Fluttertoast.showToast(
      msg: "❌ $formattedMessage",
      backgroundColor: Colors.red,
      toastLength: Toast.LENGTH_LONG,
    );
  }

// Fonctions utilitaires externes
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
}
