// lib/common/widgets/product_card.dart
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String orderId;
  final String updateDate;
  final String imageUrl;
  final bool isPublished;
  final int status; // 0: disponible, 1: rupture, 2: indisponible, 3: retiré
  final Function onPublish;
  final Function(int) onStatusChanged; // Remplace onEdit et onDelete
  final bool isLoading;

  ProductCard({
    required this.title,
    required this.orderId,
    required this.updateDate,
    required this.imageUrl,
    required this.isPublished,
    this.status = 0, // Par défaut disponible
    required this.onPublish,
    required this.onStatusChanged,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    ProductsProvider productsProvider = Provider.of<ProductsProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: greyScale900Color,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              orderId,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              updateDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Badge de publication
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  isPublished ? appColor : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPublished ? "Published" : "Draft",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Badge de statut
                          _buildStatusBadge(status),
                        ],
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton statut principal
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _showStatusBottomSheet(context),
                    icon: Icon(_getStatusIcon(status), size: 16),
                    label: Text(_getStatusText(status)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStatusColor(status),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Menu d'actions rapides
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (newStatus) {
                      _showStatusConfirmationDialog(context, newStatus);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 0,
                        child: _buildMenuItemWithIcon(
                          Icons.check_circle,
                          'Disponible',
                          Colors.green,
                          status == 0,
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: _buildMenuItemWithIcon(
                          Icons.inventory_2,
                          'En rupture de stock',
                          Colors.orange,
                          status == 1,
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: _buildMenuItemWithIcon(
                          Icons.pause_circle,
                          'Indisponible',
                          Colors.red,
                          status == 2,
                        ),
                      ),
                      PopupMenuItem(
                        value: 3,
                        child: _buildMenuItemWithIcon(
                          Icons.remove_circle,
                          'Retiré du menu',
                          Colors.grey,
                          status == 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Badge de statut
  Widget _buildStatusBadge(int status) {
    final statusData = _getStatusData(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusData['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusData['icon'],
            size: 12,
            color: statusData['color'],
          ),
          const SizedBox(width: 4),
          Text(
            statusData['text'],
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: statusData['color'],
            ),
          ),
        ],
      ),
    );
  }

  // Item de menu avec icon et indication du statut actuel
  Widget _buildMenuItemWithIcon(
      IconData icon, String text, Color color, bool isSelected) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isSelected ? color : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? color : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check,
            size: 16,
            color: color,
          ),
      ],
    );
  }

  // Bottom sheet avec toutes les options
  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Changer le statut',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: appColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Statut actuel: '),
                      _buildStatusBadge(status),
                    ],
                  ),
                ],
              ),
            ),

            // Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildStatusOption(
                    context,
                    title: 'Disponible',
                    description:
                        'Le produit est disponible et peut être commandé',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    statusValue: 0,
                    isSelected: status == 0,
                  ),
                  _buildStatusOption(
                    context,
                    title: 'En rupture de stock',
                    description:
                        'Temporairement indisponible, réapprovisionnement en cours',
                    icon: Icons.inventory_2,
                    color: Colors.orange,
                    statusValue: 1,
                    isSelected: status == 1,
                  ),
                  _buildStatusOption(
                    context,
                    title: 'Indisponible',
                    description:
                        'Produit temporairement non disponible pour les commandes',
                    icon: Icons.pause_circle,
                    color: Colors.red,
                    statusValue: 2,
                    isSelected: status == 2,
                  ),
                  _buildStatusOption(
                    context,
                    title: 'Retiré du menu',
                    description:
                        'Le produit ne sera plus visible pour les clients',
                    icon: Icons.remove_circle,
                    color: Colors.grey[600]!,
                    statusValue: 3,
                    isSelected: status == 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required int statusValue,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isSelected
            ? null
            : () {
                Navigator.pop(context);
                _showStatusConfirmationDialog(context, statusValue);
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Popup de confirmation
  void _showStatusConfirmationDialog(BuildContext context, int newStatus) {
    final statusData = _getStatusData(newStatus);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              statusData['icon'],
              color: statusData['color'],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Changer le statut',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Voulez-vous marquer le produit '),
                  TextSpan(
                    text: '"$title"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: appColor,
                    ),
                  ),
                  const TextSpan(text: ' comme '),
                  TextSpan(
                    text: statusData['text'].toLowerCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: statusData['color'],
                    ),
                  ),
                  const TextSpan(text: ' ?'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusData['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusData['color'].withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: statusData['color'],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusData['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: statusData['color'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onStatusChanged(newStatus);
              _showSuccessSnackBar(context, statusData);
            },
            icon: Icon(statusData['icon'], size: 16),
            label: const Text('Confirmer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: statusData['color'],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Données des statuts - adaptées pour correspondre au champ etat
  Map<String, dynamic> _getStatusData(int status) {
    switch (status) {
      case 0:
        return {
          'text': 'Disponible',
          'icon': Icons.check_circle,
          'color': Colors.green,
          'description': 'Le produit est disponible et peut être commandé.',
        };
      case 1:
        return {
          'text': 'En rupture de stock',
          'icon': Icons.inventory_2,
          'color': Colors.orange,
          'description':
              'Temporairement indisponible, réapprovisionnement en cours.',
        };
      case 2:
        return {
          'text': 'Indisponible',
          'icon': Icons.pause_circle,
          'color': Colors.red,
          'description':
              'Produit temporairement non disponible pour les commandes.',
        };
      case 3:
        return {
          'text': 'Retiré du menu',
          'icon': Icons.remove_circle,
          'color': Colors.grey[600]!,
          'description': 'Le produit ne sera plus visible pour les clients.',
        };
      default:
        return {
          'text': 'Inconnu',
          'icon': Icons.help,
          'color': Colors.grey,
          'description': 'Statut non défini.',
        };
    }
  }

  // Fonctions utilitaires pour l'affichage
  Color _getStatusColor(int status) {
    return _getStatusData(status)['color'];
  }

  IconData _getStatusIcon(int status) {
    return _getStatusData(status)['icon'];
  }

  String _getStatusText(int status) {
    return _getStatusData(status)['text'];
  }

  // SnackBar de succès
  void _showSuccessSnackBar(
      BuildContext context, Map<String, dynamic> statusData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              statusData['icon'],
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$title marqué comme ${statusData['text'].toLowerCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: statusData['color'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
