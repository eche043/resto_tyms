import 'package:flutter/material.dart';
import 'package:odrive_restaurant/model/role.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoleCard extends StatelessWidget {
  final UserRole role;
  final VoidCallback onTap;

  const RoleCard({
    Key? key,
    required this.role,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = true; // You can implement selection logic here

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A7C59)
                      : Colors.grey.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Role illustration
                  _buildRoleIllustration(role),

                  const SizedBox(height: 32),

                  // Role title
                  Text(
                    _getRoleTitle(l10n, role),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A7C59),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Role description
          Text(
            l10n.manageMenuTrackOrders,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _getButtonText(l10n, role),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleIllustration(UserRole role) {
    // Since we don't have actual images, let's create simple illustrations
    switch (role) {
      case UserRole.restaurant:
        return Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              role.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback en cas d'erreur de chargement d'image
                return Container(
                  color: _getRoleColor(role).withOpacity(0.1),
                  child: Icon(
                    _getRoleIcon(role),
                    size: 80,
                    color: const Color(0xFF4A7C59),
                  ),
                );
              },
            ),
          ),
        );
      case UserRole.market:
        return Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              role.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback en cas d'erreur de chargement d'image
                return Container(
                  color: _getRoleColor(role).withOpacity(0.1),
                  child: Icon(
                    _getRoleIcon(role),
                    size: 80,
                    color: const Color(0xFF4A7C59),
                  ),
                );
              },
            ),
          ),
        );
      case UserRole.supermarket:
        return Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              role.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback en cas d'erreur de chargement d'image
                return Container(
                  color: _getRoleColor(role).withOpacity(0.1),
                  child: Icon(
                    _getRoleIcon(role),
                    size: 80,
                    color: const Color(0xFF4A7C59),
                  ),
                );
              },
            ),
          ),
        );
    }
  }

  String _getRoleTitle(AppLocalizations l10n, UserRole role) {
    switch (role) {
      case UserRole.restaurant:
        return l10n.restaurant;
      case UserRole.market:
        return l10n.market;
      case UserRole.supermarket:
        return l10n.supermarket;
    }
  }

  String _getButtonText(AppLocalizations l10n, UserRole role) {
    switch (role) {
      case UserRole.restaurant:
        return l10n.loginAsRestaurant;
      case UserRole.market:
        return l10n.loginAsMarket;
      case UserRole.supermarket:
        return l10n.loginAsSupermarket;
    }
  }

  // Méthodes helper pour le fallback
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.restaurant:
        return Colors.orange;
      case UserRole.market:
        return Colors.blue;
      case UserRole.supermarket:
        return Colors.green;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.restaurant:
        return Icons.restaurant;
      case UserRole.market:
        return Icons.storefront;
      case UserRole.supermarket:
        return Icons.shopping_cart;
    }
  }
}
