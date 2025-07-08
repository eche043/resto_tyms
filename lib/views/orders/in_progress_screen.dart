// lib/views/orders/in_progress_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/model/order.dart';
import 'package:odrive_restaurant/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:odrive_restaurant/views/orders/order_details.dart';
import 'package:odrive_restaurant/common/widgets/distance_calculator.dart';

class InProgressScreen extends StatefulWidget {
  const InProgressScreen({Key? key}) : super(key: key);

  @override
  State<InProgressScreen> createState() => _InProgressScreenState();
}

class _InProgressScreenState extends State<InProgressScreen> {
  Timer? _refreshTimer;
  List<Order> _newOrders = [];
  List<Order> _inProgressOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      await provider.fetchOrders();

      if (mounted) {
        setState(() {
          // Filtrer les commandes nouvelles (statut 1) - prendre les 3 plus récentes
          final newOrders = provider.orderData
              .where((order) => order.status == 1 && order.is_accept == 0)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          _newOrders = newOrders.take(3).toList();

          // Filtrer les commandes en progression (statut 2 et 3)
          // Commandes en progression :
          // - TOUTES les commandes statut 1 ET is_accept = 0 (non acceptées)
          // - Statut 1 ET is_accept = 1 (acceptées mais pas en préparation)
          // - Statut 2 (en préparation)
          // - Statut 3 (prêtes)
          _inProgressOrders = provider.orderData
              .where((order) => (order.status == 1)) // Prêtes
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Erreur lors du chargement des commandes: $e');
      }
    }
  }

  Future<void> _acceptOrder(Order order) async {
    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);

      provider.acceptOrder(order.id.toString(), () {
        // Succès - mettre à jour la liste locale
        /* setState(() {
          _newOrders.removeWhere((o) => o.id == order.id);
          order.is_accept = 1;
          order.updatedAt = DateTime.now().toString();
          _inProgressOrders.insert(0, order);
        }); */

        // Juste recharger les données depuis le provider
        _newOrders.removeWhere((o) => o.id == order.id);
        _loadOrders();

        Fluttertoast.showToast(
          msg: "Commande acceptée avec succès",
          backgroundColor: Colors.green,
        );
      }, (error) {
        Fluttertoast.showToast(
          msg: "Erreur: $error",
          backgroundColor: Colors.red,
        );
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de l'acceptation",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _changeToPrepairing(Order order) async {
    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);

      provider.changeStatus(order.id.toString(), "2", () {
        // Succès - mettre à jour localement
        setState(() {
          final index = _inProgressOrders.indexWhere((o) => o.id == order.id);
          if (index != -1) {
            _inProgressOrders.removeWhere((o) => o.id == order.id);
            _loadOrders();
            /* _inProgressOrders[index].status = 3;
            _inProgressOrders[index].updatedAt = DateTime.now().toString(); */
          }
        });

        Fluttertoast.showToast(
          msg: "Commande mise en préparation",
          backgroundColor: Colors.green,
        );
      }, (error) {
        Fluttertoast.showToast(
          msg: "Erreur: $error",
          backgroundColor: Colors.red,
        );
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors du changement de statut",
        backgroundColor: Colors.red,
      );
    }
  }

  // Méthode pour naviguer vers OrderDetails
  void _navigateToOrderDetails(Order order) {
    final distance = DistanceCalculatorWidget(
      latitude1: double.parse(order.lat),
      longitude1: double.parse(order.lng),
      latitude2: double.parse(order.latRest),
      longitude2: double.parse(order.lngRest),
    );

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => OrderDetails(
          order: order,
          distance: distance,
          history: false, // false car c'est une commande en cours
          acceptSuccess: (int status) {
            // Callback appelé quand une action est effectuée dans OrderDetails
            _loadOrders(); // Recharger les commandes
            Fluttertoast.showToast(
              msg: status == 2 ? "Commande acceptée" : "Opération effectuée",
              backgroundColor: Colors.green,
            );
          },
        ),
      ),
    )
        .then((isUpdated) {
      if (isUpdated == true) {
        print("Order updated");
        _loadOrders(); // Rafraîchir la liste après le retour
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          const BgContainer(),
          const CustomAppBar(
            leadingImageAsset: drawer,
            title: 'En Ligne',
            notificationImageAsset: notificationIcon,
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 20.0,
            left: 8,
            right: 8,
            bottom: 0,
            child: RefreshIndicator(
              onRefresh: _loadOrders,
              child: _isLoading &&
                      _newOrders.isEmpty &&
                      _inProgressOrders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        // Section des nouvelles commandes
                        if (_newOrders.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'New(${_newOrders.length})',
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._newOrders
                              .map((order) => _buildNewOrderCard(order)),
                          const SizedBox(height: 24),
                        ],

                        // Section des commandes en progression
                        if (_inProgressOrders.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'In Progress (${_inProgressOrders.length})',
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._inProgressOrders
                              .map((order) => _buildInProgressOrderCard(order)),
                        ],

                        // Message si aucune commande
                        if (_newOrders.isEmpty &&
                            _inProgressOrders.isEmpty &&
                            !_isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune commande en cours',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Les nouvelles commandes apparaîtront ici',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrderCard(Order order) {
    final customerName = order.friend == 0 ? order.userName : order.friendName;
    final timeAgo =
        _getTimeAgo(DateTime.tryParse(order.createdAt) ?? DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF067756), // ✅ Couleur principale des cards New
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec nom et distance
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$customerName" ?? 'Client',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // ✅ Texte blanc
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white, // ✅ Texte blanc
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        order.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white, // ✅ Texte blanc
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          order.userType,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white, // ✅ Texte blanc
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Montant de la commande
          Row(
            children: [
              Text(
                '${order.total}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // ✅ Texte blanc
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/images/cfa_icon.png',
                width: 16,
                height: 16,
                color: Colors.white, // ✅ Icône en blanc pour la section New
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'F',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              //const Icon(Icons.payment, size: 16, color: Colors.white),
            ],
          ),

          const SizedBox(height: 2),

          // Bouton Accept aligné à droite
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _acceptOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF80BB85), // ✅ Couleur bouton accepter
                    foregroundColor: Colors.white, // ✅ Texte blanc
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0, // Pas d'ombre supplémentaire
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // ✅ Texte blanc
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressOrderCard(Order order) {
    final customerName = order.friend == 0 ? order.userName : order.friendName;
    final provider = Provider.of<OrderProvider>(context);

    // Logique pour déterminer l'état et le temps
    bool isOverdue = false;
    String timeDisplay = '';
    String statusText = '';
    Color statusColor = Colors.blue;
    bool showActionButton = false;
    String actionButtonText = '';
    VoidCallback? actionButtonCallback;

    if (order.status == 1 && order.is_accept == 0) {
      // Commande non acceptée
      final minutesSinceCreated = _getMinutesSinceCreated(order);
      timeDisplay = '$minutesSinceCreated min.';
      statusText = 'New Order';
      isOverdue = minutesSinceCreated > 5;
      statusColor = Colors.orange;
      showActionButton = true;
      actionButtonText = 'Accept';
      actionButtonCallback = () => _acceptOrder(order);
    } else if (order.status == 1 && order.is_accept == 1) {
      // Commande acceptée mais pas encore en préparation
      final minutesSinceAccept = provider.getMinutesSinceAccepted(order.id) == 0
          ? _getMinutesSinceUpdate(order)
          : provider.getMinutesSinceAccepted(order.id);
      isOverdue = minutesSinceAccept > 5;
      timeDisplay = '$minutesSinceAccept min.';
      statusText = 'Accepted';
      statusColor = Colors.blue;
      showActionButton = true;
      actionButtonText = 'Start Preparing';
      actionButtonCallback = () => _changeToPrepairing(order);
    } else if (order.status == 2) {
      // En préparation
      final minutesSinceUpdate = _getMinutesSinceUpdate(order);
      timeDisplay = '$minutesSinceUpdate min.';
      statusText = 'Preparing';
      statusColor = Colors.orange;
      showActionButton = false;
    } else if (order.status == 3) {
      // Prêt
      final minutesSinceUpdate = _getMinutesSinceUpdate(order);
      timeDisplay = '$minutesSinceUpdate min.';
      statusText = 'Ready';
      statusColor = Colors.green;
      showActionButton = false;
    }

    // Obtenir l'image du premier élément de ordersData
    String? imageUrl;
    if (order.ordersData.isNotEmpty) {
      final firstOrderData = order.ordersData.first;
      imageUrl = firstOrderData.image;
    }

    return InkWell(
      onTap: () => _navigateToOrderDetails(order), // ✅ Navigation ajoutée ici
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // En-tête avec image et infos
            Row(
              children: [
                // Image du premier élément de ordersData
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "$serverImages$imageUrl",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.restaurant,
                                color: Colors.grey.shade500,
                                size: 30,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey.shade400,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.restaurant,
                          color: Colors.grey.shade500,
                          size: 30,
                        ),
                ),

                const SizedBox(width: 12),

                // Infos principales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$customerName" ?? 'Client',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '4.9 km Away',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Montant avec icône CFA
                      Row(
                        children: [
                          Text(
                            '${order.total}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: appColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Image.asset(
                            'assets/images/cfa_icon.png',
                            width: 16,
                            height: 16,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                'F',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: appColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bookmark et temps
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                isOverdue ? Colors.red : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isOverdue ? Colors.red : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Badge de statut et bouton d'action
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        order.status == 1 && order.is_accept == 0
                            ? Icons.new_releases
                            : order.status == 1 && order.is_accept == 1
                                ? Icons.check_circle
                                : order.status == 2
                                    ? Icons.restaurant_menu
                                    : Icons.done_all,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bouton d'action conditionnel
                if (showActionButton && actionButtonCallback != null)
                  GestureDetector(
                    onTap: () {
                      actionButtonCallback!();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: order.status == 1 && order.is_accept == 0
                            ? const Color(0xFF80BB85) // Vert pour Accept
                            : Colors
                                .orange.shade600, // Orange pour Start Preparing
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        actionButtonText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
  }

// Méthode helper pour calculer le temps depuis la création
  int _getMinutesSinceCreated(Order order) {
    final createdTime = DateTime.tryParse(order.createdAt) ?? DateTime.now();
    final now = DateTime.now();
    return now.difference(createdTime).inMinutes;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h ${difference.inMinutes % 60}';
    } else {
      return '${difference.inMinutes} min';
    }
  }

  int _getMinutesSinceUpdate(Order order) {
    final updateTime = DateTime.tryParse(order.updatedAt) ?? DateTime.now();
    final now = DateTime.now();
    return now.difference(updateTime).inMinutes;
  }

  String _getTimeDisplay(Order order) {
    final minutes = _getMinutesSinceUpdate(order);
    return '$minutes min.';
  }
}
