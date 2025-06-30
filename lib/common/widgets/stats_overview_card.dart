// lib/common/widgets/stats_overview_card.dart
import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/const/colors.dart';
import 'package:odrive_restaurant/providers/dashboard_provider.dart';

class StatsOverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String? trendValue;
  final bool? trendPositive;
  final VoidCallback? onTap;

  const StatsOverviewCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.iconColor = appColor,
    this.trendValue,
    this.trendPositive,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const Spacer(),
                if (trendValue != null) _buildTrendIndicator(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = trendPositive ?? true;
    final color = isPositive ? Colors.green[600] : Colors.red[600];
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            trendValue!,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Utilisation dans restaurants_detail_screen.dart :
// Remplacer _buildOverviewSection par :

Widget _buildOverviewSection(DashboardProvider provider) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    child: StatsOverviewCard(
      title: 'Total Restaurants',
      value: '${provider.totalRestaurants}',
      subtitle: 'Évolution sur les 30 derniers jours',
      icon: Icons.restaurant,
      iconColor: appColor,
      trendValue: '+12%',
      trendPositive: true,
      onTap: () {
        // Action optionnelle
      },
    ),
  );
}
