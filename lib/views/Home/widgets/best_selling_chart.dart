// features/restaurant/widgets/best_selling_chart.dart

import 'package:flutter/material.dart';
import 'package:odrive_restaurant/model/top_food.dart';
import 'dart:math' as math;

class BestSellingChart extends StatelessWidget {
  final List<BestSellingProduct> products;
  final List<Color> colors;
  final bool isLoading;

  const BestSellingChart({
    Key? key,
    required this.products,
    required this.colors,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
      child: isLoading
          ? _buildLoadingWidget()
          : products.isEmpty
              ? _buildEmptyWidget()
              : _buildChart(),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            'Chargement des produits populaires...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'Aucun produit populaire disponible',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Column(
      children: [
        // Graphique en secteurs
        Expanded(
          flex: 3,
          child: CustomPaint(
            painter: PieChartPainter(products, colors),
            child: const SizedBox.expand(),
          ),
        ),

        const SizedBox(height: 16),

        // Légende avec détails
        Expanded(
          flex: 2,
          child: _buildLegend(),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return SingleChildScrollView(
      child: Column(
        children: products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          final color = index < colors.length ? colors[index] : Colors.grey;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                // Indicateur de couleur
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 8),

                // Informations du produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${product.orders} commandes',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pourcentage
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${product.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<BestSellingProduct> products;
  final List<Color> colors;

  PieChartPainter(this.products, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    if (products.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    double startAngle = -math.pi / 2; // Commencer en haut

    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      final color = i < colors.length ? colors[i] : Colors.grey;

      // Calculer l'angle du secteur
      final sweepAngle = (product.percentage / 100) * 2 * math.pi;

      // Dessiner le secteur
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Dessiner une bordure blanche fine
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Dessiner le pourcentage au centre du secteur (si assez grand)
      if (product.percentage > 5) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius * 0.7;
        final labelX = center.dx + math.cos(labelAngle) * labelRadius;
        final labelY = center.dy + math.sin(labelAngle) * labelRadius;

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${product.percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            labelX - textPainter.width / 2,
            labelY - textPainter.height / 2,
          ),
        );
      }

      startAngle += sweepAngle;
    }

    // Dessiner un cercle central pour créer un effet de donut (optionnel)
    final innerRadius = radius * 0.4;
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, innerPaint);

    // Afficher le total au centre
    final totalOrders =
        products.fold<int>(0, (sum, product) => sum + product.orders);

    final centerTextPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$totalOrders\n',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(
            text: 'Total',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    centerTextPainter.layout();
    centerTextPainter.paint(
      canvas,
      Offset(
        center.dx - centerTextPainter.width / 2,
        center.dy - centerTextPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
