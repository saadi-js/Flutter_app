import 'dart:math';
import 'package:flutter/material.dart';

/// Custom bar chart painted using CustomPainter
/// Shows daily spending for last 7 days with tap interaction
class BarChart extends StatefulWidget {
  final List<double> data; // amounts for each day
  final List<String> labels; // day labels

  const BarChart({
    Key? key,
    required this.data,
    required this.labels,
  }) : super(key: key);

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedBarIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handle tap on chart to detect which bar was tapped
  void _handleTap(TapDownDetails details) {
    setState(() {
      _selectedBarIndex = _detectTappedBar(details.localPosition);
    });

    // Show details dialog if a bar was tapped
    if (_selectedBarIndex != null && _selectedBarIndex! >= 0 && _selectedBarIndex! < widget.data.length) {
      _showDayDetails(_selectedBarIndex!);
    }
  }

  /// Detect which bar was tapped based on tap position
  int? _detectTappedBar(Offset tapPosition) {
    if (widget.data.isEmpty) return null;

    const chartWidth = 350.0; // Approximate chart width
    const chartHeight = 200.0;
    
    final barWidth = (chartWidth - 40) / widget.data.length - 10;
    
    // Check if tap is within chart bounds
    if (tapPosition.dy < 0 || tapPosition.dy > chartHeight - 30) {
      return null;
    }

    // Find which bar was tapped
    for (int i = 0; i < widget.data.length; i++) {
      final x = 20 + i * (barWidth + 10);
      if (tapPosition.dx >= x && tapPosition.dx <= x + barWidth) {
        return i;
      }
    }

    return null;
  }

  /// Show day details dialog
  void _showDayDetails(int index) {
    final amount = widget.data[index];
    final label = widget.labels[index];
    
    // Calculate statistics
    final total = widget.data.fold(0.0, (sum, value) => sum + value);
    final average = total / widget.data.length;
    final percentage = ((amount / total) * 100).toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('$label Spending'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Total:', style: TextStyle(color: Colors.grey[600])),
                Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daily Average:', style: TextStyle(color: Colors.grey[600])),
                Text('\$${average.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('% of Week:', style: TextStyle(color: Colors.grey[600])),
                Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: amount / total,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
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
            painter: BarChartPainter(
              data: widget.data,
              labels: widget.labels,
              progress: _animation.value,
              selectedBarIndex: _selectedBarIndex,
            ),
          );
        },
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final double progress;
  final int? selectedBarIndex;

  BarChartPainter({
    required this.data,
    required this.labels,
    required this.progress,
    this.selectedBarIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.reduce(max);
    if (maxValue == 0) return;

    final barWidth = (size.width - 40) / data.length - 10;
    final chartHeight = size.height - 40;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxValue) * chartHeight * progress;
      final x = 20 + i * (barWidth + 10);
      final y = size.height - 30 - barHeight;

      final isSelected = i == selectedBarIndex;

      // Draw bar with highlight for selected
      final barPaint = Paint()
        ..color = isSelected ? const Color(0xFF8B7FFF) : const Color(0xFF6C63FF)
        ..style = PaintingStyle.fill;

      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );

      canvas.drawRRect(barRect, barPaint);

      // Draw selection highlight border
      if (isSelected) {
        final borderPaint = Paint()
          ..color = const Color(0xFF6C63FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(barRect, borderPaint);
      }

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.black54,
            fontSize: isSelected ? 11 : 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 20),
      );

      // Draw value on top if progress is complete
      if (progress > 0.9 && data[i] > 0) {
        final valuePainter = TextPainter(
          text: TextSpan(
            text: '\$${data[i].toStringAsFixed(0)}',
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.black87,
              fontSize: isSelected ? 11 : 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        valuePainter.layout();
        valuePainter.paint(
          canvas,
          Offset(x + (barWidth - valuePainter.width) / 2, y - 15),
        );
      }
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.selectedBarIndex != selectedBarIndex;
  }
}
