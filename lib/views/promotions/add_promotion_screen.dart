import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddPromotionScreen extends StatefulWidget {
  final int restaurantId;

  const AddPromotionScreen({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  State<AddPromotionScreen> createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int? _selectedFreeProductId;

  // Contrôleurs de formulaire
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minimumAmountController = TextEditingController();
  final _rewardValueController = TextEditingController();
  final _rewardPercentageController = TextEditingController();
  final _freeProductNameController = TextEditingController();
  final _pointsValueController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _frequencyDetailsController = TextEditingController();

  // Variables de formulaire
  String _offerType = 'minimum_amount';
  String _rewardType = 'discount';
  String _frequency = 'once_per_day';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _usePercentage = false;

  // ✅ Nouvelles variables pour les articles
  List<Map<String, dynamic>> _availableProducts = [];
  int? _selectedTriggerItemId;
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurantProducts();
  }

  // ✅ Charger les produits du restaurant
  Future<void> _loadRestaurantProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final response = await getRestaurantProducts(widget.restaurantId);

      if (response['error'] == '0') {
        setState(() {
          _availableProducts =
              List<Map<String, dynamic>>.from(response['products'] ?? []);
        });

        print('Produits chargés: ${_availableProducts.length}');
      } else {
        Fluttertoast.showToast(
          msg: "Erreur: ${response['error']}",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
      Fluttertoast.showToast(
        msg: "Erreur lors du chargement des produits",
        backgroundColor: Colors.red,
      );
    }

    setState(() {
      _isLoadingProducts = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minimumAmountController.dispose();
    _rewardValueController.dispose();
    _rewardPercentageController.dispose();
    _freeProductNameController.dispose();
    _pointsValueController.dispose();
    _conditionsController.dispose();
    _frequencyDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BgContainer(),
          const CustomAppBar(
            leadingImageAsset: drawer,
            title: 'Nouvelle Promotion',
            notificationImageAsset: notificationIcon,
          ),
          Positioned(
            top: 115,
            left: 0,
            right: 0,
            bottom: 0,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header d'information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appColor.withOpacity(0.1),
                            appColor.withOpacity(0.05)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: appColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: appColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                Icon(Icons.campaign, color: appColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Formulaire de Soumission d\'Offre Personnalisée',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Partenaires Tym\'s',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: appColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Informations Générales
                    _buildSectionTitle('🟢 Informations Générales'),
                    _buildCard([
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nom de l\'offre',
                        hint: 'Ex: Combo Double Whopper + Coca offert',
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Brève description',
                        hint: 'Ex: 1 boisson offerte dès 4000 FCFA d\'achat',
                        maxLines: 3,
                        isRequired: true,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Déclencheur de l'offre
                    _buildSectionTitle('🔸 Déclencheur de l\'offre'),
                    _buildCard([
                      _buildRadioGroup(
                        title: 'Type de déclencheur',
                        value: _offerType,
                        options: [
                          RadioOption('minimum_amount',
                              'À partir d\'un montant minimum'),
                          RadioOption('specific_item',
                              'Commande d\'un article spécifique'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _offerType = value;
                          });
                        },
                      ),
                      if (_offerType == 'minimum_amount') ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _minimumAmountController,
                          label: 'Montant minimum requis (FCFA)',
                          hint: '4000',
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                      ],
                      if (_offerType == 'specific_item') ...[
                        const SizedBox(height: 16),
                        // ✅ Sélecteur d'articles
                        _buildProductSelector(),
                        /* Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade600, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'La sélection d\'articles spécifiques sera disponible prochainement',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ), */
                      ],
                    ]),

                    const SizedBox(height: 24),

                    // Type de récompense
                    _buildSectionTitle('🎁 Type de récompense offerte'),
                    _buildCard([
                      _buildRadioGroup(
                        title: 'Type de récompense',
                        value: _rewardType,
                        options: [
                          RadioOption('discount', 'Réduction immédiate'),
                          RadioOption('cashback', 'Cashback crédité'),
                          RadioOption('free_product', 'Produit offert'),
                          RadioOption('points', 'Points de fidélité'),
                          RadioOption('next_order_discount',
                              'Réduction prochaine commande'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _rewardType = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Champs conditionnels selon le type de récompense
                      if (_rewardType == 'discount' ||
                          _rewardType == 'cashback' ||
                          _rewardType == 'next_order_discount') ...[
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('En pourcentage'),
                                value: _usePercentage,
                                onChanged: (value) {
                                  setState(() {
                                    _usePercentage = value ?? false;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          ],
                        ),
                        if (_usePercentage)
                          _buildTextField(
                            controller: _rewardPercentageController,
                            label: 'Pourcentage (%)',
                            hint: '10',
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          )
                        else
                          _buildTextField(
                            controller: _rewardValueController,
                            label: 'Valeur (FCFA)',
                            hint: '500',
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          ),
                      ],

                      if (_rewardType == 'free_product') ...[
                        // ✅ Sélecteur de produit gratuit
                        _buildFreeProductSelector(),
                        /* _buildTextField(
                          controller: _freeProductNameController,
                          label: 'Nom du produit offert',
                          hint: 'Ex: Coca-Cola 33cl',
                          isRequired: true,
                        ), */
                      ],

                      if (_rewardType == 'points') ...[
                        _buildTextField(
                          controller: _pointsValueController,
                          label: 'Nombre de points offerts',
                          hint: '100',
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                      ],
                    ]),

                    const SizedBox(height: 24),

                    // Durée de validité
                    _buildSectionTitle('⏱️ Durée de validité de l\'offre'),
                    _buildCard([
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: 'Date de début',
                              selectedDate: _startDate,
                              onDateSelected: (date) {
                                setState(() {
                                  _startDate = date;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              label: 'Date de fin',
                              selectedDate: _endDate,
                              onDateSelected: (date) {
                                setState(() {
                                  _endDate = date;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Boutons de sélection rapide
                      const Text(
                        'Sélection rapide:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildQuickDateButton('7 jours', 7),
                          _buildQuickDateButton('14 jours', 14),
                          _buildQuickDateButton('1 mois', 30),
                        ],
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Fréquence de participation
                    _buildSectionTitle(
                        '🔄 Fréquence de participation autorisée'),
                    _buildCard([
                      _buildRadioGroup(
                        title: 'Fréquence',
                        value: _frequency,
                        options: [
                          RadioOption(
                              'once_per_client', '1 commande par client'),
                          RadioOption(
                              'once_per_day', '1 commande par jour par client'),
                          RadioOption(
                              'unlimited', 'Commandes illimitées par jour'),
                          RadioOption('custom', 'Autre (précisez)'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _frequency = value;
                          });
                        },
                      ),
                      if (_frequency == 'custom') ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _frequencyDetailsController,
                          label: 'Précisez la fréquence',
                          hint: 'Ex: 1 fois par semaine',
                          isRequired: true,
                        ),
                      ],
                    ]),

                    const SizedBox(height: 24),

                    // Conditions détaillées
                    _buildSectionTitle('📜 Conditions détaillées (optionnel)'),
                    _buildCard([
                      _buildTextField(
                        controller: _conditionsController,
                        label: 'Conditions spéciales',
                        hint:
                            'Ex: Offre valable uniquement pour les commandes livrées entre 11h et 15h. Non cumulable avec d\'autres promotions.',
                        maxLines: 4,
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // Bouton de soumission
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitOffer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Soumission en cours...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send, size: 24),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'SOUMETTRE L\'OFFRE',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Nouvelle méthode pour le sélecteur de produits
  Widget _buildProductSelector() {
    if (_isLoadingProducts) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Aucun produit disponible pour ce restaurant.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadRestaurantProducts,
              child: Text(
                'Actualiser',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Article déclencheur *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
                color: _selectedTriggerItemId == null
                    ? Colors.red.shade300
                    : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedTriggerItemId,
              hint: const Text(
                'Sélectionner un article',
                style: TextStyle(color: Colors.grey),
              ),
              isExpanded: true,
              items: _availableProducts.map((product) {
                return DropdownMenuItem<int>(
                  value: product['id'],
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Image du produit
                        Container(
                          width: 45,
                          height: 45,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          child: product['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product['image'],
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.restaurant,
                                        color: Colors.grey.shade500,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.restaurant,
                                  color: Colors.grey.shade500,
                                ),
                        ),

                        // Informations du produit
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? 'Produit sans nom',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 15),
                              /* if (product['description'] != null &&
                                  product['description'].isNotEmpty)
                                Text(
                                  product['description'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 2), */
                              Text(
                                '${product['price']} FCFA',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: appColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTriggerItemId = newValue;
                });
              },
            ),
          ),
        ),

        // Affichage du produit sélectionné
        if (_selectedTriggerItemId != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Article sélectionné :',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _getSelectedProductName(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Message d'aide
        const SizedBox(height: 8),
        Text(
          'L\'offre se déclenchera uniquement lors de l\'achat de cet article spécifique.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // Méthode helper pour obtenir le nom du produit sélectionné
  String _getSelectedProductName() {
    if (_selectedTriggerItemId == null) return '';

    final selectedProduct = _availableProducts.firstWhere(
      (product) => product['id'] == _selectedTriggerItemId,
      orElse: () => {'name': 'Produit introuvable'},
    );

    return selectedProduct['name'] ?? 'Produit sans nom';
  }

  // ✅ Nouvelle méthode pour le sélecteur de produit gratuit
  Widget _buildFreeProductSelector() {
    if (_isLoadingProducts) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Chargement des produits...',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_availableProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Aucun produit disponible. Vous pouvez saisir le nom manuellement.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produit offert *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 8),

        // Sélecteur de produit
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
                color: _selectedFreeProductId == null &&
                        _freeProductNameController.text.isEmpty
                    ? Colors.red.shade300
                    : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedFreeProductId,
              hint: const Text(
                'Choisir un produit à offrir',
                style: TextStyle(color: Colors.grey),
              ),
              isExpanded: true,
              items: _availableProducts.map((product) {
                return DropdownMenuItem<int>(
                  value: product['id'],
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Image du produit
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey.shade200,
                          ),
                          child: product['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    product['image'],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.restaurant,
                                        color: Colors.grey.shade500,
                                        size: 20,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.restaurant,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                        ),

                        // Informations du produit
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? 'Produit sans nom',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              /* Text(
                                '${product['price']} FCFA',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: appColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ), */
                            ],
                          ),
                        ),

                        // Badge "GRATUIT"
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'GRATUIT',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFreeProductId = newValue;
                  if (newValue != null) {
                    // Vider le champ manuel si on sélectionne un produit
                    _freeProductNameController.clear();
                  }
                });
              },
            ),
          ),
        ),

        // Affichage de la sélection
        if (_selectedFreeProductId != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produit gratuit sélectionné :',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _getSelectedFreeProductName(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Valeur: ${_getSelectedFreeProductPrice()} FCFA',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_freeProductNameController.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Produit personnalisé: "${_freeProductNameController.text}"',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 8),
        Text(
          'Sélectionnez un produit existant ou saisissez un nom personnalisé.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // Méthodes helper pour les produits gratuits
  String _getSelectedFreeProductName() {
    if (_selectedFreeProductId == null) return '';

    final selectedProduct = _availableProducts.firstWhere(
      (product) => product['id'] == _selectedFreeProductId,
      orElse: () => {'name': 'Produit introuvable'},
    );

    return selectedProduct['name'] ?? 'Produit sans nom';
  }

  String _getSelectedFreeProductPrice() {
    if (_selectedFreeProductId == null) return '0';

    final selectedProduct = _availableProducts.firstWhere(
      (product) => product['id'] == _selectedFreeProductId,
      orElse: () => {'price': '0.00'},
    );

    return selectedProduct['price'] ?? '0.00';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    Function(String)? onChanged, // ✅ Nouveau paramètre
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged, // ✅ Ajouter ce callback
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: appColor, width: 2),
        ),
        labelStyle: TextStyle(
          color: isRequired ? Colors.red.shade700 : Colors.grey.shade700,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildRadioGroup({
    required String title,
    required String value,
    required List<RadioOption> options,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...options
            .map((option) => RadioListTile<String>(
                  title: Text(option.label),
                  value: option.value,
                  groupValue: value,
                  onChanged: (newValue) => onChanged(newValue!),
                  activeColor: appColor,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label + ' *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
              : 'Sélectionner une date',
          style: TextStyle(
            color: selectedDate != null ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, int days) {
    return OutlinedButton(
      onPressed: () {
        final startDate = DateTime.now();
        final endDate = startDate.add(Duration(days: days));
        setState(() {
          _startDate = startDate;
          _endDate = endDate;
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: appColor,
        side: BorderSide(color: appColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
        msg: "Veuillez remplir tous les champs requis",
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      Fluttertoast.showToast(
        msg: "Veuillez sélectionner les dates de début et de fin",
        backgroundColor: Colors.red,
      );
      return;
    }

    // ✅ Validation pour article spécifique
    if (_offerType == 'specific_item' && _selectedTriggerItemId == null) {
      Fluttertoast.showToast(
        msg: "Veuillez sélectionner un article déclencheur",
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_rewardType == 'free_product' &&
        _selectedFreeProductId == null &&
        _freeProductNameController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Veuillez sélectionner un produit gratuit ou saisir son nom",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await submitOffer(
        restaurantId: widget.restaurantId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        offerType: _offerType,
        // ✅ Ajout de l'article sélectionné
        triggerItemId:
            _offerType == 'specific_item' ? _selectedTriggerItemId : null,
        minimumAmount: _offerType == 'minimum_amount'
            ? double.tryParse(_minimumAmountController.text)
            : null,
        rewardType: _rewardType,
        rewardValue: !_usePercentage && _rewardValueController.text.isNotEmpty
            ? double.tryParse(_rewardValueController.text)
            : null,
        rewardPercentage:
            _usePercentage && _rewardPercentageController.text.isNotEmpty
                ? double.tryParse(_rewardPercentageController.text)
                : null,
        freeProductId: _selectedFreeProductId,
        freeProductName: _freeProductNameController.text.trim().isNotEmpty
            ? _freeProductNameController.text.trim()
            : null,
        pointsValue: _rewardType == 'points'
            ? int.tryParse(_pointsValueController.text)
            : null,
        startDate: _startDate!.toIso8601String(),
        endDate: _endDate!.toIso8601String(),
        frequency: _frequency,
        frequencyDetails: _frequency == 'custom'
            ? _frequencyDetailsController.text.trim()
            : null,
        conditions: _conditionsController.text.trim().isNotEmpty
            ? _conditionsController.text.trim()
            : null,
      );

      if (response['error'] == '0') {
        Fluttertoast.showToast(
          msg: "Offre soumise avec succès pour validation !",
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );
        Navigator.of(context).pop(true);
      } else {
        Fluttertoast.showToast(
          msg: response['error'],
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la soumission: $e",
        backgroundColor: Colors.red,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}

class RadioOption {
  final String value;
  final String label;

  RadioOption(this.value, this.label);
}
