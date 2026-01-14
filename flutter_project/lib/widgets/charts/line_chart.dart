import 'dart:math';
import 'package:flutter/material.dart';

/// Custom line chart painted using CustomPainter
/// Shows spending trend over time with tap interaction
class LineChart extends StatefulWidget {
  final List<double> data; // amounts over time
  final List<String> labels; // time labels

  const LineChart({
    Key? key,
    required this.data,
    required this.labels,
  }) : super(key: key);

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedPointIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handle tap on chart to detect which point was tapped
  void _handleTap(TapDownDetails details) {
    setState(() {
      _selectedPointIndex = _detectTappedPoint(details.localPosition);
    });

    // Show details dialog if a point was tapped
    if (_selectedPointIndex != null && _selectedPointIndex! >= 0 && _selectedPointIndex! < widget.data.length) {
      _showPointDetails(_selectedPointIndex!);
    }
  }

  /// Detect which point was tapped based on tap position
  int? _detectTappedPoint(Offset tapPosition) {
    if (widget.data.isEmpty || widget.data.length < 2) return null;

    const chartHeight = 200.0 - 60;
    const chartWidth = 350.0 - 40; // Approximate
    final pointSpacing = chartWidth / (widget.data.length - 1);

    final maxValue = widget.data.reduce(max);
    if (maxValue == 0) return null;

    // Calculate all point positions
    final points = <Offset>[];
    for (int i = 0; i < widget.data.length; i++) {
      final x = 20 + i * pointSpacing;
      final y = 20 + chartHeight - (widget.data[i] / maxValue * chartHeight);
      points.add(Offset(x, y));
    }

    // Find closest point to tap
    int? closestIndex;
    double closestDistance = double.infinity;

    for (int i = 0; i < points.length; i++) {
      final dx = tapPosition.dx - points[i].dx;
      final dy = tapPosition.dy - points[i].dy;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < 20 && distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  /// Show point details dialog
  void _showPointDetails(int index) {
    final amount = widget.data[index];
    final label = widget.labels[index];
    
    // Calculate statistics
    final total = widget.data.fold(0.0, (sum, value) => sum + value);
    final average = total / widget.data.length;
    final maxValue = widget.data.reduce(max);
    final minValue = widget.data.reduce(min);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
            ),
            const SizedBox(height: 16),
            const Text('Period Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Period Total:', style: TextStyle(color: Colors.grey[600])),
                Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Average:', style: TextStyle(color: Colors.grey[600])),
                Text('\$${average.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Highest:', style: TextStyle(color: Colors.grey[600])),
                Text('\$${maxValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lowest:', style: TextStyle(color: Colors.grey[600])),
                Text('\$${minValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  amount > average ? Icons.trending_up : Icons.trending_down,
                  color: amount > average ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  amount > average 
                      ? '${((amount / average - 1) * 100).toStringAsFixed(1)}% above average'
                      : '${((1 - amount / average) * 100).toStringAsFixed(1)}% below average',
                  style: TextStyle(
                    color: amount > average ? Colors.red : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 200),
            painter: LineChartPainter(
              data: widget.data,
              labels: widget.labels,
              progress: _animation.value,
              selectedPointIndex: _selectedPointIndex,
            ),
          );
        },
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final double progress;
  final int? selectedPointIndex;

  LineChartPainter({
    required this.data,
    required this.labels,
    required this.progress,
    this.selectedPointIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.length < 2) return;

    final maxValue = data.reduce(max);
    if (maxValue == 0) return;

    final chartHeight = size.height - 60;
    final chartWidth = size.width - 40;
    final pointSpacing = chartWidth / (data.length - 1);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withAlpha(25)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = 20 + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(20, y),
        Offset(size.width - 20, y),
        gridPaint,
      );
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = 20 + i * pointSpacing;
      final y = 20 + chartHeight - (data[i] / maxValue * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw filled area under line
    if (progress > 0) {
      final areaPath = Path();
      areaPath.moveTo(points.first.dx, size.height - 40);
      
      for (int i = 0; i < (points.length * progress).floor(); i++) {
        areaPath.lineTo(points[i].dx, points[i].dy);
      }
      
      if (progress < 1.0) {
        final lastIndex = (points.length * progress).floor();
        if (lastIndex < points.length - 1) {
          final interpolated = Offset.lerp(
            points[lastIndex],
            points[lastIndex + 1],
            (points.length * progress) - lastIndex,
          )!;
          areaPath.lineTo(interpolated.dx, interpolated.dy);
          areaPath.lineTo(interpolated.dx, size.height - 40);
        }
      } else {
        areaPath.lineTo(points.last.dx, size.height - 40);
      }
      
      areaPath.close();

      final areaPaint = Paint()
        ..color = const Color(0xFF6C63FF).withAlpha(50)
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, areaPaint);
    }

    // Draw line
    if (points.length > 1 && progress > 0) {
      final linePaint = Paint()
        ..color = const Color(0xFF6C63FF)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);

      final visiblePoints = (points.length * progress).floor();
      for (int i = 1; i < visiblePoints; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }

      if (progress < 1.0 && visiblePoints < points.length - 1) {
        final interpolated = Offset.lerp(
          points[visiblePoints],
          points[visiblePoints + 1],
          (points.length * progress) - visiblePoints,
        )!;
        linePath.lineTo(interpolated.dx, interpolated.dy);
      }

      canvas.drawPath(linePath, linePaint);
    }

    // Draw points
    final visiblePointsCount = (points.length * progress).ceil();
    for (int i = 0; i < min(visiblePointsCount, points.length); i++) {
      final isSelected = i == selectedPointIndex;
      
      // Larger circle for selected point
      final pointRadius = isSelected ? 7.0 : 4.0;
      final borderRadius = isSelected ? 9.0 : 5.0;
      
      final pointBorderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final pointPaint = Paint()
        ..color = isSelected ? const Color(0xFF8B7FFF) : const Color(0xFF6C63FF)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points[i], borderRadius, pointBorderPaint);
      canvas.drawCircle(points[i], pointRadius, pointPaint);

      // Draw value label for selected point
      if (isSelected && progress > 0.9) {
        final valuePainter = TextPainter(
          text: TextSpan(
            text: '\$${data[i].toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        valuePainter.layout();
        valuePainter.paint(
          canvas,
          Offset(points[i].dx - valuePainter.width / 2, points[i].dy - 25),
        );
      }
    }

    // Draw labels (only show every nth label to avoid crowding)
    final labelInterval = (labels.length / 7).ceil();
    for (int i = 0; i < labels.length; i += labelInterval) {
      if (i < labels.length) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(
              color: i == selectedPointIndex ? Colors.black87 : Colors.black54,
              fontSize: i == selectedPointIndex ? 11 : 10,
              fontWeight: i == selectedPointIndex ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            20 + i * pointSpacing - textPainter.width / 2,
            size.height - 25,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.selectedPointIndex != selectedPointIndex;
  }
}
