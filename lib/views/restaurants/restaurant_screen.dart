// lib/views/restaurants/restaurant_screen.dart
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

  Future<void> _handleRefresh() async {
    final restaurantProvider =
        Provider.of<RestaurantsProvider>(context, listen: false);
    await restaurantProvider.fetchRestaurants();
  }

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
    final restaurantProvider = Provider.of<RestaurantsProvider>(context);
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
            left: 8,
            right: 8,
            bottom: 0,
            child: Column(
              children: [
                // Search bar
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _onSearchSubmitted,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un restaurant...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),

                // Filter tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _getFilterLabels().length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildFilterChip(
                          _getFilterLabels()[index],
                          index,
                          restaurantProvider,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: _buildContent(restaurantProvider),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button pour ajouter un restaurant
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers la page d'ajout de restaurant
          print("Add new restaurant");
        },
        backgroundColor: appColor,
        child: const Icon(Icons.add, color: Colors.white),
      ), */
    );
  }

  List<String> _getFilterLabels() {
    return [
      'Tous',
      'Ouverts',
      'En pause',
      'Fermés',
    ];
  }

  Widget _buildFilterChip(
      String label, int index, RestaurantsProvider restaurantProvider) {
    final isSelected = restaurantProvider.selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        restaurantProvider.setSelectedTabIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? appColor : Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
            color: isSelected ? appColor : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: appColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(RestaurantsProvider restaurantProvider) {
    int currentTab = restaurantProvider.selectedTabIndex;
    List<RestaurantData> restaurants =
        _getFilteredRestaurants(restaurantProvider, currentTab);

    if (restaurantProvider.loading) {
      return const Center(
        child: CircularProgressIndicator(color: appColor),
      );
    }

    if (restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(currentTab),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            /* if (currentTab == 0) // Seulement pour "Tous"
              ElevatedButton.icon(
                onPressed: () {
                  // Navigation vers ajout de restaurant
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un restaurant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  foregroundColor: Colors.white,
                ),
              ), */
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final data = restaurants[index];
        return RestaurantCard(
          title: data.name,
          orderId: "#${data.id}",
          updateDate: "Mis à jour: ${data.updatedAt}",
          imageUrl: "${serverImages}${data.image}",
          isPublished: data.published == 1,
          isPaused:
              _getRestaurantPauseStatus(data), // Récupérer le statut de pause
          openingHours: _getRestaurantOpeningHours(
              data), // Récupérer les heures d'ouverture
          isLoading: restaurantProvider.isDeleting(data.id.toString()),
          onPublish: () {
            _toggleRestaurantPublication(data, restaurantProvider);
          },
          onPauseToggle: (isPaused) {
            _handlePauseToggle(data, isPaused, restaurantProvider);
          },
          onHoursChanged: (newHours) {
            _handleHoursChanged(data, newHours, restaurantProvider);
          },
        );
      },
    );
  }

  List<RestaurantData> _getFilteredRestaurants(
      RestaurantsProvider restaurantProvider, int currentTab) {
    if (currentTab == 0) {
      return restaurantProvider.restaurantData; // Tous les restaurants
    } else {
      return restaurantProvider.restaurantData.where((restaurant) {
        switch (currentTab) {
          case 1: // Ouverts
            return restaurant.is_pause == 0 &&
                _isRestaurantCurrentlyOpen(restaurant);
          case 2: // En pause
            return restaurant.is_pause == 1;
          case 3: // Fermés
            return restaurant.is_pause == 0 &&
                !_isRestaurantCurrentlyOpen(restaurant);
          default:
            return true;
        }
      }).toList();
    }
  }

  // Récupérer le statut de pause du restaurant depuis le champ is_pause
  bool _getRestaurantPauseStatus(RestaurantData restaurant) {
    // Utiliser le champ is_pause de RestaurantData
    return restaurant.is_pause == 1;
  }

  // Récupérer les heures d'ouverture du restaurant depuis les champs de la base de données
  Map<String, String> _getRestaurantOpeningHours(RestaurantData restaurant) {
    return {
      'lundi':
          _formatHours(restaurant.openTimeMonday, restaurant.closeTimeMonday),
      'mardi':
          _formatHours(restaurant.openTimeTuesday, restaurant.closeTimeTuesday),
      'mercredi': _formatHours(
          restaurant.openTimeWednesday, restaurant.closeTimeWednesday),
      'jeudi': _formatHours(
          restaurant.openTimeThursday, restaurant.closeTimeThursday),
      'vendredi':
          _formatHours(restaurant.openTimeFriday, restaurant.closeTimeFriday),
      'samedi': _formatHours(
          restaurant.openTimeSaturday, restaurant.closeTimeSaturday),
      'dimanche':
          _formatHours(restaurant.openTimeSunday, restaurant.closeTimeSunday),
    };
  }

  // Formater les heures d'ouverture et de fermeture
  String _formatHours(String? openTime, String? closeTime) {
    if (openTime == null ||
        closeTime == null ||
        openTime.isEmpty ||
        closeTime.isEmpty ||
        openTime == '00:00' && closeTime == '00:00') {
      return 'Fermé';
    }

    // Nettoyer et formater les heures
    final open = _cleanTimeString(openTime);
    final close = _cleanTimeString(closeTime);

    return '$open-$close';
  }

  // Nettoyer et formater une chaîne d'heure
  String _cleanTimeString(String time) {
    // Supprimer les secondes si présentes (ex: "08:00:00" -> "08:00")
    if (time.contains(':') && time.split(':').length == 3) {
      final parts = time.split(':');
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }

  // Vérifier si le restaurant est actuellement ouvert selon ses heures
  bool _isRestaurantCurrentlyOpen(RestaurantData restaurant) {
    final hours = _getRestaurantOpeningHours(restaurant);
    final today = _getCurrentDayKey();
    final todayHours = hours[today];

    if (todayHours == null || todayHours == 'Fermé') return false;

    // Logique simplifiée - vous pouvez améliorer avec l'heure actuelle
    final now = DateTime.now();
    final currentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    if (todayHours.contains('-')) {
      final parts = todayHours.split('-');
      final openTime = parts[0];
      final closeTime = parts[1];

      // Comparaison simple des heures (peut être améliorée)
      return currentTime.compareTo(openTime) >= 0 &&
          currentTime.compareTo(closeTime) <= 0;
    }

    return true; // Par défaut ouvert
  }

  String _getCurrentDayKey() {
    final days = [
      'dimanche',
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi'
    ];
    return days[DateTime.now().weekday % 7];
  }

  String _getEmptyMessage(int currentTab) {
    switch (currentTab) {
      case 0:
        return 'Aucun restaurant disponible\nCommencez par ajouter vos premiers restaurants';
      case 1:
        return 'Aucun restaurant ouvert actuellement\nVérifiez les heures d\'ouverture';
      case 2:
        return 'Aucun restaurant en pause\nTous vos restaurants sont actifs';
      case 3:
        return 'Aucun restaurant fermé\nTous vos restaurants sont ouverts ou en pause';
      default:
        return 'Aucun restaurant trouvé';
    }
  }

  void _toggleRestaurantPublication(
      RestaurantData restaurant, RestaurantsProvider restaurantProvider) {
    // Logique pour changer la publication du restaurant
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restaurant.published == 1
            ? 'Masquer le restaurant'
            : 'Publier le restaurant'),
        content: Text(
          restaurant.published == 1
              ? 'Voulez-vous masquer "${restaurant.name}" ? Il ne sera plus visible pour les clients.'
              : 'Voulez-vous publier "${restaurant.name}" ? Il sera visible pour les clients.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Appeler votre API pour changer la visibilité
              _updateRestaurantVisibility(restaurant, restaurantProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  restaurant.published == 1 ? Colors.orange : appColor,
            ),
            child: Text(restaurant.published == 1 ? 'Masquer' : 'Publier'),
          ),
        ],
      ),
    );
  }

  void _updateRestaurantVisibility(
      RestaurantData restaurant, RestaurantsProvider restaurantProvider) {
    // Ici vous devriez appeler votre API pour mettre à jour la visibilité
    // Pour l'exemple, je simule avec un toast

    Fluttertoast.showToast(
      msg: restaurant.published == 1
          ? "Restaurant masqué avec succès"
          : "Restaurant publié avec succès",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: appColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    // Rafraîchir la liste
    restaurantProvider.fetchRestaurants();
  }

  void _handlePauseToggle(RestaurantData restaurant, bool isPaused,
      RestaurantsProvider restaurantProvider) {
    print("Toggle pause pour ${restaurant.name}: $isPaused");

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: appColor),
      ),
    );

    // APPEL RÉEL de la méthode du provider
    restaurantProvider.updateRestaurantPauseStatus(restaurant.id, isPaused,
        (success, message) {
      Navigator.pop(context); // Fermer l'indicateur de chargement

      if (success) {
        Fluttertoast.showToast(
          msg: message ??
              (isPaused
                  ? "${restaurant.name} mis en pause"
                  : "${restaurant.name} reprend son activité"),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: isPaused ? Colors.orange : Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Rafraîchir la liste après succès
        restaurantProvider.fetchRestaurants();
      } else {
        // Afficher l'erreur
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content: Text(message ?? 'Erreur lors de la mise à jour du statut'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _handleHoursChanged(RestaurantData restaurant,
      Map<String, String> newHours, RestaurantsProvider restaurantProvider) {
    print("Nouvelles heures pour ${restaurant.name}: $newHours");

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: appColor),
      ),
    );

    // APPEL DIRECT avec les heures au format interface
    restaurantProvider.updateRestaurantOpeningHours(restaurant.id, newHours,
        (success, message) {
      Navigator.pop(context); // Fermer l'indicateur de chargement

      if (success) {
        Fluttertoast.showToast(
          msg: message ?? "Heures d'ouverture mises à jour avec succès",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Rafraîchir la liste après succès
        restaurantProvider.fetchRestaurants();
      } else {
        // Afficher l'erreur
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content:
                Text(message ?? 'Erreur lors de la mise à jour des heures'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
