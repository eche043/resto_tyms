import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsProvider with ChangeNotifier {
  int _selectedTabIndex = 0;
  List<FoodsData> _productData = [];
  bool _loading = true;
  // bool _deleting = false;
  Map<String, bool> _deleting = {};

  int get selectedTabIndex => _selectedTabIndex;
  List<FoodsData> get productData => _productData;
  bool get loading => _loading;
  Map<String, bool> get deletingStatus => _deleting;

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setDeleting(String productId, bool isLoading) {
    deletingStatus[productId] = isLoading;
    notifyListeners();
  }

  bool isDeleting(String productId) {
    return deletingStatus[productId] ?? false; // Retourne false si non défini
  }

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";
    var url = '${serverPath}foodsList';
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };
    var body = json.encoder.convert({});
    try {
      var response = await http
          .post(Uri.parse(url), headers: requestHeaders, body: body)
          .timeout(const Duration(seconds: 30));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        if (jsonResult["error"] != "0") throw Exception(jsonResult["error"]);
        ResponseFoods ret = ResponseFoods.fromJson(jsonResult);
        _productData = ret.foods;
      }
    } catch (ex) {}
    _loading = false;
    notifyListeners();
  }

  foodDelete(String id, Function(String status) callbackError) async {
    setDeleting(id, true);
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";
    var url = '${serverPath}foodDelete';
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer ${uid}",
    };
    var body = json.encoder.convert({
      "id": id,
    });
    try {
      var response =
          await http.post(Uri.parse(url), headers: requestHeaders, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        if (jsonResult["error"] != "0") {
          callbackError("error");
          return;
        }
        callbackError("success");
      } else {
        callbackError("error");
      }
    } catch (ex) {
      callbackError('error');
    }
    setDeleting(id, false);
    notifyListeners();
  }

  List<FoodsData> getFilteredProducts(int status) {
    return _productData.where((product) {
      return status == 1 ? product.visible == "1" : product.visible == "0";
    }).toList();
  }

  // Filtrer les produits selon leur statut (basé sur le champ etat)
  List<FoodsData> getFilteredProductsByStatus(int statusIndex) {
    final statusText = _convertStatusIndexToEtat(statusIndex);
    return _productData.where((product) {
      return product.etat?.toLowerCase() == statusText.toLowerCase();
    }).toList();
  }

  // Convertir l'index de statut vers le texte etat
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

  // Convertir le texte etat vers l'index de statut
  int _convertEtatToStatusIndex(String? etat) {
    if (etat == null) return 0;

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
        return 0;
    }
  }

  // Mettre à jour le statut d'un produit avec la vraie API
  Future<void> updateProductStatus(String productId, String newEtat,
      Function(bool, String?) callback) async {
    try {
      // Import de votre fonction API
      final response = await updateFoodStatus(
        foodId: productId,
        newEtat: newEtat,
      );

      if (response['success'] == true) {
        // Mettre à jour localement si nécessaire
        final index =
            _productData.indexWhere((product) => product.id == productId);
        if (index != -1) {
          // Copier l'objet existant et modifier seulement l'état
          final existingProduct = _productData[index];

          // Créer une nouvelle instance en copiant tous les champs existants
          _productData[index] = FoodsData(
            id: existingProduct.id,
            name: existingProduct.name,
            image: existingProduct.image,
            imageid: existingProduct.imageid,
            visible: existingProduct.visible,
            updatedAt: existingProduct.updatedAt,
            etat: newEtat, // Nouveau statut
            price: existingProduct.price,
            discountprice: existingProduct.discountprice,
            desc: existingProduct.desc,
            restaurant: existingProduct.restaurant,
            category: existingProduct.category,
            ingredients: existingProduct.ingredients,
            extras: existingProduct.extras,
            nutrition: existingProduct.nutrition,
            variants: existingProduct.variants,
            imagesFilesIds: existingProduct.imagesFilesIds,
            // Ajoutez tous les autres champs selon votre modèle FoodsData
          );

          notifyListeners();
        }

        callback(true, response['message']);
      } else {
        callback(false, response['error']);
      }
    } catch (e) {
      print('Error updating product status: $e');
      callback(false, 'Erreur de connexion: ${e.toString()}');
    }
  }

  // Obtenir les statistiques par statut
  Map<String, int> getProductStatusStats() {
    final stats = {
      'Disponible': 0,
      'En rupture de stock': 0,
      'Indisponible': 0,
      'Retiré du menu': 0,
    };

    for (final product in _productData) {
      final etat = product.etat ?? 'Disponible';
      if (stats.containsKey(etat)) {
        stats[etat] = stats[etat]! + 1;
      }
    }

    return stats;
  }

  // Obtenir la couleur associée à un statut
  Color getStatusColor(String? etat) {
    switch (etat?.toLowerCase()) {
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

  // Obtenir l'icône associée à un statut
  IconData getStatusIcon(String? etat) {
    switch (etat?.toLowerCase()) {
      case 'disponible':
        return Icons.check_circle;
      case 'en rupture de stock':
        return Icons.inventory_2;
      case 'indisponible':
        return Icons.pause_circle;
      case 'retiré du menu':
        return Icons.remove_circle;
      default:
        return Icons.help;
    }
  }
}
