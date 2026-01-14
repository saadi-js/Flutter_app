import 'dart:math';
import 'package:flutter/material.dart';

/// Custom pie chart painted using CustomPainter
/// Shows category-wise expense breakdown with tap interaction
class PieChart extends StatefulWidget {
  final Map<String, double> data; // category -> amount
  final Map<String, Color> colors;

  const PieChart({
    Key? key,
    required this.data,
    required this.colors,
  }) : super(key: key);

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _selectedCategory;

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

  /// Handle tap on chart to detect which segment was tapped
  void _handleTap(TapDownDetails details) {
    setState(() {
      _selectedCategory = _detectTappedSegment(details.localPosition);
    });

    // Show details dialog if a segment was tapped
    if (_selectedCategory != null) {
      _showCategoryDetails(_selectedCategory!);
    }
  }

  /// Detect which pie segment was tapped based on tap position
  String? _detectTappedSegment(Offset tapPosition) {
    if (widget.data.isEmpty) return null;

    const chartSize = Size(200, 200);
    final center = Offset(chartSize.width / 2, chartSize.height / 2);
    final radius = min(chartSize.width, chartSize.height) / 2;
    final innerRadius = radius * 0.5; // Donut hole

    // Calculate distance from center
    final dx = tapPosition.dx - center.dx;
    final dy = tapPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    // Check if tap is within the donut ring
    if (distance < innerRadius || distance > radius) {
      return null;
    }

    // Calculate angle of tap (0 = right, pi/2 = down, pi = left, -pi/2 = up)
    var tapAngle = atan2(dy, dx);
    
    // Convert to start from top (adjust by -pi/2)
    tapAngle = tapAngle + pi / 2;
    if (tapAngle < 0) tapAngle += 2 * pi;

    // Find which segment the tap is in
    final total = widget.data.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return null;

    double currentAngle = 0;
    for (var entry in widget.data.entries) {
      final sweepAngle = (entry.value / total) * 2 * pi;
      if (tapAngle >= currentAngle && tapAngle < currentAngle + sweepAngle) {
        return entry.key;
      }
      currentAngle += sweepAngle;
    }

    return null;
  }

  /// Show category details dialog
  void _showCategoryDetails(String category) {
    final amount = widget.data[category] ?? 0;
    final total = widget.data.values.fold(0.0, (sum, value) => sum + value);
    final percentage = ((amount / total) * 100).toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: widget.colors[category] ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(category),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Percentage: $percentage%',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: amount / total,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(widget.colors[category] ?? Colors.grey),
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
            size: const Size(200, 200),
            painter: PieChartPainter(
              data: widget.data,
              colors: widget.colors,
              progress: _animation.value,
              selectedCategory: _selectedCategory,
            ),
          );
        },
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double progress;
  final String? selectedCategory;

  PieChartPainter({
    required this.data,
    required this.colors,
    required this.progress,
    this.selectedCategory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    
    // Calculate total
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return;

    double startAngle = -pi / 2; // Start from top

    data.forEach((category, amount) {
      final sweepAngle = (amount / total) * 2 * pi * progress;
      
      // Slightly enlarge selected segment
      final isSelected = category == selectedCategory;
      final segmentRadius = isSelected ? radius * 1.05 : radius;
      
      final paint = Paint()
        ..color = colors[category] ?? Colors.grey
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: segmentRadius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw stroke for separation
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3 : 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: segmentRadius),
        startAngle,
        sweepAngle,
        true,
        strokePaint,
      );

      startAngle += sweepAngle;
    });

    // Draw center circle for donut effect
    final centerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerCirclePaint);
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.data != data ||
        oldDelegate.selectedCategory != selectedCategory;
  }
}
