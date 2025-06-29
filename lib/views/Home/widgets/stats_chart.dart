// features/restaurant/widgets/stats_chart.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class StatsChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool isLoading;

  const StatsChart({
    Key? key,
    required this.data,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
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
        children: [
          // Légende
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Orders', const Color(0xFF4A7C59)),
            ],
          ),

          const SizedBox(height: 16),

          // Graphique
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return CustomPaint(
      painter: LineChartPainter(data),
      child: const SizedBox.expand(),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Marges
    const double leftMargin = 40;
    const double rightMargin = 20;
    const double topMargin = 20;
    const double bottomMargin = 40;

    final double chartWidth = size.width - leftMargin - rightMargin;
    final double chartHeight = size.height - topMargin - bottomMargin;

    // Récupérer seulement les orders
    final orders = data.map((d) => d['orders'] as int).toList();

    final maxValue = orders.reduce(math.max).toDouble();
    final minValue = orders.reduce(math.min).toDouble();

    // Ajouter un peu de marge en haut et en bas
    final valueRange = maxValue - minValue;
    final adjustedMaxValue = maxValue + (valueRange * 0.1);
    final adjustedMinValue = math.max(0.0, minValue - (valueRange * 0.1));

    // Dessiner la grille
    _drawGrid(canvas, size, leftMargin, topMargin, chartWidth, chartHeight,
        adjustedMaxValue);

    // Dessiner les axes
    _drawAxes(canvas, size, leftMargin, topMargin, chartWidth, chartHeight,
        adjustedMaxValue);

    // Dessiner la courbe
    _drawOrdersLine(canvas, leftMargin, topMargin, chartWidth, chartHeight,
        orders, adjustedMaxValue, adjustedMinValue);

    // Dessiner les points
    _drawOrdersPoints(canvas, leftMargin, topMargin, chartWidth, chartHeight,
        orders, adjustedMaxValue, adjustedMinValue);

    // Dessiner les labels des mois
    _drawMonthLabels(
        canvas, size, leftMargin, topMargin, chartWidth, chartHeight);
  }

  void _drawGrid(Canvas canvas, Size size, double leftMargin, double topMargin,
      double chartWidth, double chartHeight, double maxValue) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;

    // Lignes horizontales (5 lignes)
    for (int i = 0; i <= 4; i++) {
      final y = topMargin + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(leftMargin + chartWidth, y),
        gridPaint,
      );
    }

    // Lignes verticales
    final stepX = chartWidth / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      final x = leftMargin + stepX * i;
      canvas.drawLine(
        Offset(x, topMargin),
        Offset(x, topMargin + chartHeight),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size, double leftMargin, double topMargin,
      double chartWidth, double chartHeight, double maxValue) {
    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    // Axe Y (gauche)
    canvas.drawLine(
      Offset(leftMargin, topMargin),
      Offset(leftMargin, topMargin + chartHeight),
      axisPaint,
    );

    // Axe X (bas)
    canvas.drawLine(
      Offset(leftMargin, topMargin + chartHeight),
      Offset(leftMargin + chartWidth, topMargin + chartHeight),
      axisPaint,
    );

    // Labels de l'axe Y
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 4; i++) {
      final value = (maxValue / 4) * (4 - i);
      final y = topMargin + (chartHeight / 4) * i;

      textPainter.text = TextSpan(
        text: value.toInt().toString(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftMargin - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  void _drawOrdersLine(
      Canvas canvas,
      double leftMargin,
      double topMargin,
      double chartWidth,
      double chartHeight,
      List<int> orders,
      double maxValue,
      double minValue) {
    if (orders.length < 2) return;

    final linePaint = Paint()
      ..color = const Color(0xFF4A7C59)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = chartWidth / (orders.length - 1);

    for (int i = 0; i < orders.length; i++) {
      final x = leftMargin + stepX * i;
      final normalizedY = (orders[i] - minValue) / (maxValue - minValue);
      final y = topMargin + chartHeight - (normalizedY * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Courbe lisse avec des points de contrôle
        final prevX = leftMargin + stepX * (i - 1);
        final prevNormalizedY =
            (orders[i - 1] - minValue) / (maxValue - minValue);
        final prevY = topMargin + chartHeight - (prevNormalizedY * chartHeight);

        final controlX1 = prevX + (x - prevX) / 3;
        final controlY1 = prevY;
        final controlX2 = prevX + 2 * (x - prevX) / 3;
        final controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Ajouter un dégradé sous la courbe
    _drawAreaUnderCurve(canvas, leftMargin, topMargin, chartWidth, chartHeight,
        orders, maxValue, minValue);
  }

  void _drawAreaUnderCurve(
      Canvas canvas,
      double leftMargin,
      double topMargin,
      double chartWidth,
      double chartHeight,
      List<int> orders,
      double maxValue,
      double minValue) {
    if (orders.length < 2) return;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A7C59).withOpacity(0.3),
          const Color(0xFF4A7C59).withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromLTWH(leftMargin, topMargin, chartWidth, chartHeight));

    final path = Path();
    final stepX = chartWidth / (orders.length - 1);

    // Commencer du bas gauche
    path.moveTo(leftMargin, topMargin + chartHeight);

    // Dessiner la courbe
    for (int i = 0; i < orders.length; i++) {
      final x = leftMargin + stepX * i;
      final normalizedY = (orders[i] - minValue) / (maxValue - minValue);
      final y = topMargin + chartHeight - (normalizedY * chartHeight);

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final prevX = leftMargin + stepX * (i - 1);
        final prevNormalizedY =
            (orders[i - 1] - minValue) / (maxValue - minValue);
        final prevY = topMargin + chartHeight - (prevNormalizedY * chartHeight);

        final controlX1 = prevX + (x - prevX) / 3;
        final controlY1 = prevY;
        final controlX2 = prevX + 2 * (x - prevX) / 3;
        final controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    // Fermer le chemin vers le bas droite
    path.lineTo(leftMargin + chartWidth, topMargin + chartHeight);
    path.close();

    canvas.drawPath(path, gradientPaint);
  }

  void _drawOrdersPoints(
      Canvas canvas,
      double leftMargin,
      double topMargin,
      double chartWidth,
      double chartHeight,
      List<int> orders,
      double maxValue,
      double minValue) {
    final pointPaint = Paint()
      ..color = const Color(0xFF4A7C59)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final stepX = chartWidth / (orders.length - 1);

    for (int i = 0; i < orders.length; i++) {
      final x = leftMargin + stepX * i;
      final normalizedY = (orders[i] - minValue) / (maxValue - minValue);
      final y = topMargin + chartHeight - (normalizedY * chartHeight);

      // Bordure blanche
      canvas.drawCircle(Offset(x, y), 5, borderPaint);
      // Point coloré
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  void _drawMonthLabels(Canvas canvas, Size size, double leftMargin,
      double topMargin, double chartWidth, double chartHeight) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final stepX = chartWidth / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final month = data[i]['month'] as String;
      final x = leftMargin + stepX * i;

      textPainter.text = TextSpan(
        text: month,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, topMargin + chartHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
