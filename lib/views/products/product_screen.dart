// lib/views/products/product_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/const/colors.dart';
import 'package:odrive_restaurant/common/const/images.dart';
import 'package:odrive_restaurant/common/widgets/appbar.dart';
import 'package:odrive_restaurant/common/widgets/bg_image.dart';
import 'package:odrive_restaurant/common/widgets/custom_drawer.dart';
import 'package:odrive_restaurant/common/widgets/product_card.dart';
import 'package:odrive_restaurant/model/product.dart';
import 'package:odrive_restaurant/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _controller = TextEditingController();

  void _onSearchSubmitted(String value) {
    print("Search Value: $value");
  }

  Future<void> _handleRefresh() async {
    final productProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    await productProvider.fetchProducts();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductsProvider>(context);
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          const BgContainer(),
          CustomAppBar(
            leadingImageAsset: drawer,
            title: AppLocalizations.of(context)!.products,
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
                      hintText: 'Rechercher un produit...',
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
                          productProvider,
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
                    child: _buildContent(productProvider),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button pour ajouter un produit
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers la page d'ajout de produit
          print("Add new product");
        },
        backgroundColor: appColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<String> _getFilterLabels() {
    return ['Tous', 'Disponibles', 'En rupture', 'Indisponibles', 'Retirés'];
  }

  Widget _buildFilterChip(
      String label, int index, ProductsProvider productProvider) {
    final isSelected = productProvider.selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        productProvider.setSelectedTabIndex(index);
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

  Widget _buildContent(ProductsProvider productProvider) {
    int currentTab = productProvider.selectedTabIndex;
    List<FoodsData> products =
        _getFilteredProducts(productProvider, currentTab);

    if (productProvider.loading) {
      return const Center(
        child: CircularProgressIndicator(color: appColor),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
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
            if (currentTab == 0) // Seulement pour "Tous"
              ElevatedButton.icon(
                onPressed: () {
                  // Navigation vers ajout de produit
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un produit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final data = products[index];
        return ProductCard(
          title: data.name,
          orderId: "#${data.id}",
          updateDate: "Mis à jour: ${data.updatedAt}",
          imageUrl: "${serverImages}${data.image}",
          isPublished: data.visible == "1",
          status: _convertEtatToStatusIndex(
              data.etat), // Conversion depuis le champ etat
          isLoading: productProvider.isDeleting(data.id),
          onPublish: () {
            _toggleProductPublication(data, productProvider);
          },
          onStatusChanged: (newStatus) {
            _handleStatusChange(data, newStatus, productProvider);
          },
        );
      },
    );
  }

  List<FoodsData> _getFilteredProducts(
      ProductsProvider productProvider, int currentTab) {
    if (currentTab == 0) {
      return productProvider.productData; // Tous les produits
    } else {
      return productProvider.productData.where((product) {
        int productStatus = _convertEtatToStatusIndex(product.etat);
        return productStatus ==
            (currentTab - 1); // currentTab - 1 car index 0 = "Tous"
      }).toList();
    }
  }

  // Convertir le champ etat (String) vers l'index de statut (int)
  int _convertEtatToStatusIndex(String? etat) {
    if (etat == null) return 0; // Par défaut disponible

    switch (etat.toLowerCase()) {
      case 'disponible':
        return 0;
      case 'en rupture de stock':
        return 1;
      case 'indisponible':
        return 2;
      case 'retiré du menu':
        return 3;
      default:
        return 0; // Par défaut disponible
    }
  }

  // Convertir l'index de statut (int) vers le champ etat (String)
  String _convertStatusIndexToEtat(int statusIndex) {
    switch (statusIndex) {
      case 0:
        return 'Disponible';
      case 1:
        return 'En rupture de stock';
      case 2:
        return 'Indisponible';
      case 3:
        return 'Retiré du menu';
      default:
        return 'Disponible';
    }
  }

  String _getEmptyMessage(int currentTab) {
    switch (currentTab) {
      case 0:
        return 'Aucun produit disponible\nCommencez par ajouter vos premiers produits';
      case 1:
        return 'Aucun produit disponible\nTous vos produits sont dans d\'autres statuts';
      case 2:
        return 'Aucun produit en rupture de stock\nParfait ! Tous vos produits sont disponibles';
      case 3:
        return 'Aucun produit indisponible\nTous vos produits sont disponibles pour commande';
      case 4:
        return 'Aucun produit retiré du menu\nTous vos produits sont visibles aux clients';
      default:
        return 'Aucun produit trouvé';
    }
  }

  void _toggleProductPublication(
      FoodsData product, ProductsProvider productProvider) {
    // Logique pour changer la publication du produit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.visible == "1"
            ? 'Masquer le produit'
            : 'Publier le produit'),
        content: Text(
          product.visible == "1"
              ? 'Voulez-vous masquer "${product.name}" ? Il ne sera plus visible pour les clients.'
              : 'Voulez-vous publier "${product.name}" ? Il sera visible pour les clients.',
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
              _updateProductVisibility(product, productProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  product.visible == "1" ? Colors.orange : appColor,
            ),
            child: Text(product.visible == "1" ? 'Masquer' : 'Publier'),
          ),
        ],
      ),
    );
  }

  void _updateProductVisibility(
      FoodsData product, ProductsProvider productProvider) {
    // Ici vous devriez appeler votre API pour mettre à jour la visibilité
    // Pour l'exemple, je simule avec un toast
    final newVisibility = product.visible == "1" ? "0" : "1";

    // Simuler l'appel API
    // productProvider.updateProductVisibility(product.id, newVisibility, (success) {
    //   if (success) {
    Fluttertoast.showToast(
      msg: product.visible == "1"
          ? "Produit masqué avec succès"
          : "Produit publié avec succès",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: appColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    // Rafraîchir la liste
    productProvider.fetchProducts();
    //   } else {
    //     Fluttertoast.showToast(
    //       msg: "Erreur lors de la mise à jour",
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //     );
    //   }
    // });
  }

  void _handleStatusChange(
      FoodsData product, int newStatus, ProductsProvider productProvider) {
    // Logique pour changer le statut du produit
    final newEtat = _convertStatusIndexToEtat(newStatus);
    print("Changement de statut pour ${product.name}: $newEtat");

    // Utiliser la vraie API
    _updateProductStatus(product, newEtat, productProvider);
  }

  void _updateProductStatus(
      FoodsData product, String newEtat, ProductsProvider productProvider) {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: appColor),
      ),
    );

    // Appeler la vraie API
    productProvider.updateProductStatus(product.id, newEtat,
        (success, message) {
      // Fermer l'indicateur de chargement
      Navigator.pop(context);

      if (success) {
        // Succès
        Fluttertoast.showToast(
          msg: message ??
              "${product.name} marqué comme ${newEtat.toLowerCase()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: _getStatusColorFromEtat(newEtat),
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Rafraîchir la liste après la mise à jour
        productProvider.fetchProducts();
      } else {
        // Erreur
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

  Color _getStatusColorFromEtat(String etat) {
    switch (etat.toLowerCase()) {
      case 'disponible':
        return Colors.green;
      case 'en rupture de stock':
        return Colors.orange;
      case 'indisponible':
        return Colors.red;
      case 'retiré du menu':
        return Colors.grey[600]!;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
