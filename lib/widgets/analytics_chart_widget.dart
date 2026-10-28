import 'dart:math';
import 'package:flutter/material.dart';
import '../models/expense_category.dart';

/// Native CustomPainter Donut Chart for category breakdown visualization.
class DonutCategoryChart extends StatelessWidget {
  final Map<ExpenseCategory, double> breakdown;
  final double totalAmount;

  const DonutCategoryChart({
    super.key,
    required this.breakdown,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (totalAmount <= 0 || breakdown.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text('No expense data available for chart visualization.'),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _DonutChartPainter(
          breakdown: breakdown,
          totalAmount: totalAmount,
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<ExpenseCategory, double> breakdown;
  final double totalAmount;

  _DonutChartPainter({
    required this.breakdown,
    required this.totalAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12;
    final strokeWidth = 24.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    for (var entry in breakdown.entries) {
      final category = entry.key;
      final amount = entry.value;
      final sweepAngle = (amount / totalAmount) * 2 * pi;

      paint.color = category.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.breakdown != breakdown || oldDelegate.totalAmount != totalAmount;
  }
}

/// Native CustomPainter Bar Chart displaying spending over recent days with day labels.
class DailySpendingBarChart extends StatelessWidget {
  final List<double> dailyAmounts; // Last 7 days
  final List<String> dayLabels;

  const DailySpendingBarChart({
    super.key,
    required this.dailyAmounts,
    required this.dayLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVal = dailyAmounts.fold(0.0, (max, v) => v > max ? v : max);

    return SizedBox(
      height: 170,
      child: CustomPaint(
        painter: _BarChartPainter(
          dailyAmounts: dailyAmounts,
          dayLabels: dayLabels,
          maxVal: maxVal > 0 ? maxVal : 1.0,
          barColor: theme.colorScheme.primary,
          textColor: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> dailyAmounts;
  final List<String> dayLabels;
  final double maxVal;
  final Color barColor;
  final Color textColor;

  _BarChartPainter({
    required this.dailyAmounts,
    required this.dayLabels,
    required this.maxVal,
    required this.barColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = barColor;
    final barWidth = (size.width / dailyAmounts.length) - 16;

    for (int i = 0; i < dailyAmounts.length; i++) {
      final x = (i * (size.width / dailyAmounts.length)) + 8;
      final heightFactor = (dailyAmounts[i] / maxVal).clamp(0.0, 1.0);
      final barHeight = (size.height - 36) * heightFactor;
      final y = size.height - 24 - barHeight;

      final RRect rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight > 4 ? barHeight : 4),
        const Radius.circular(6),
      );

      canvas.drawRRect(rect, paint);

      // Draw Day Label
      if (i < dayLabels.length) {
        final textSpan = TextSpan(
          text: dayLabels[i],
          style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(x + (barWidth / 2) - (textPainter.width / 2), size.height - 18),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.dailyAmounts != dailyAmounts || oldDelegate.maxVal != maxVal;
  }
}
