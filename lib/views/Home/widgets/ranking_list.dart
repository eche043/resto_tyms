// features/restaurant/widgets/ranking_list.dart

import 'package:flutter/material.dart';
import 'package:odrive_restaurant/model/restaurant_ranking.dart';

class RankingList extends StatelessWidget {
  final List<RankingData> rankings;
  final bool isLoading;

  const RankingList({
    Key? key,
    required this.rankings,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: isLoading
          ? _buildLoadingWidget()
          : rankings.isEmpty
              ? _buildEmptyWidget()
              : _buildRankingList(),
    );
  }

  Widget _buildLoadingWidget() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Chargement des classements...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'Aucun classement disponible',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: rankings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ranking = rankings[index];
        return _buildRankingItem(ranking, index);
      },
    );
  }

  Widget _buildRankingItem(RankingData ranking, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: ranking.position <= 3
            ? Border.all(
                color: ranking.positionColor.withOpacity(0.3), width: 2)
            : Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Position avec icône ou médaille
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ranking.position <= 3
                  ? ranking.positionColor.withOpacity(0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: ranking.position <= 3
                  ? Text(
                      ranking.positionIcon,
                      style: const TextStyle(fontSize: 16),
                    )
                  : Text(
                      '${ranking.position}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Informations du restaurant
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du restaurant
                Text(
                  ranking.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Détails (commandes et revenus)
                Row(
                  children: [
                    // Nombre de commandes
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ranking.orders}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Revenus
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ranking.formattedRevenue,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Barre de progression (basée sur les commandes)
          if (rankings.isNotEmpty) _buildProgressBar(ranking),
        ],
      ),
    );
  }

  Widget _buildProgressBar(RankingData ranking) {
    // Calculer le pourcentage basé sur le maximum de commandes
    final maxOrders =
        rankings.map((r) => r.orders).reduce((a, b) => a > b ? a : b);
    final percentage = maxOrders > 0 ? ranking.orders / maxOrders : 0.0;

    return Container(
      width: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Pourcentage
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 4),

          // Barre de progression
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: ranking.position <= 3
                      ? ranking.positionColor
                      : const Color(0xFF4A7C59),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
