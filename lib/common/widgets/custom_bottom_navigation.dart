import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/const/const.dart';

class CustomBottomNavigationModern extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationModern({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildModernNavItem(
            index: 0,
            icon: Icons.home_filled,
            label: 'Accueil',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _buildModernNavItem(
            index: 1,
            icon: Icons.live_tv_rounded,
            label: 'Live',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _buildModernNavItem(
            index: 2,
            icon: Icons.assignment_rounded,
            label: 'Commandes',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? appColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
