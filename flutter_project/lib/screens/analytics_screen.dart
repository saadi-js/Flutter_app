import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/charts/pie_chart.dart';
import '../widgets/charts/bar_chart.dart';
import '../widgets/charts/line_chart.dart';

/// Analytics screen showing charts and statistics
/// Demonstrates spending patterns and trends
class AnalyticsScreen extends StatefulWidget {
  final List<Expense> expenses;

  const AnalyticsScreen({Key? key, required this.expenses}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  /// Get category colors
  Color getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Travel':
        return Colors.blue;
      case 'Bills':
        return Colors.red;
      case 'Shopping':
        return Colors.purple;
      case 'Other':
      default:
        return Colors.grey;
    }
  }

  /// Calculate category-wise expenses for pie chart
  Map<String, double> get categoryData {
    final Map<String, double> data = {};
    for (var expense in widget.expenses) {
      data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
    }
    return data;
  }

  /// Get colors for pie chart
  Map<String, Color> get categoryColors {
    return {
      'Food': Colors.orange,
      'Travel': Colors.blue,
      'Bills': Colors.red,
      'Shopping': Colors.purple,
      'Other': Colors.grey,
    };
  }

  /// Get last 7 days data for bar chart
  List<double> get last7DaysData {
    final List<double> data = List.filled(7, 0.0);
    final now = DateTime.now();

    for (var expense in widget.expenses) {
      final daysDiff = now.difference(expense.date).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        data[6 - daysDiff] += expense.amount;
      }
    }

    return data;
  }

  /// Get labels for last 7 days
  List<String> get last7DaysLabels {
    final List<String> labels = [];
    final now = DateTime.now();
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      labels.add(days[date.weekday % 7]);
    }

    return labels;
  }

  /// Get last 30 days data for line chart
  List<double> get last30DaysData {
    final List<double> data = List.filled(30, 0.0);
    final now = DateTime.now();

    for (var expense in widget.expenses) {
      final daysDiff = now.difference(expense.date).inDays;
      if (daysDiff >= 0 && daysDiff < 30) {
        data[29 - daysDiff] += expense.amount;
      }
    }

    return data;
  }

  /// Get labels for last 30 days
  List<String> get last30DaysLabels {
    final List<String> labels = [];
    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      labels.add('${date.day}');
    }

    return labels;
  }

  /// Calculate total for this month
  double get thisMonthTotal {
    final now = DateTime.now();
    return widget.expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Calculate average daily spending
  double get averageDailySpending {
    if (widget.expenses.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final last30Days = widget.expenses.where((e) {
      return now.difference(e.date).inDays < 30;
    });

    if (last30Days.isEmpty) return 0.0;

    final total = last30Days.fold(0.0, (sum, e) => sum + e.amount);
    return total / 30;
  }

  /// Get highest expense
  Expense? get highestExpense {
    if (widget.expenses.isEmpty) return null;
    return widget.expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  /// Get most used category
  String get mostUsedCategory {
    if (widget.expenses.isEmpty) return 'None';

    final categoryCount = <String, int>{};
    for (var expense in widget.expenses) {
      categoryCount[expense.category] = (categoryCount[expense.category] ?? 0) + 1;
    }

    var maxCategory = 'None';
    var maxCount = 0;
    categoryCount.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        maxCategory = category;
      }
    });

    return maxCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: widget.expenses.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Statistics Cards
                  _buildStatisticsCards(),
                  const SizedBox(height: 24),

                  // Category Breakdown (Pie Chart)
                  _buildSectionCard(
                    title: 'Category Breakdown',
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        if (categoryData.isNotEmpty) ...[
                          PieChart(
                            data: categoryData,
                            colors: categoryColors,
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryLegend(),
                        ] else
                          const Text('No data available'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Last 7 Days (Bar Chart)
                  _buildSectionCard(
                    title: 'Last 7 Days Spending',
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            data: last7DaysData,
                            labels: last7DaysLabels,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 30-Day Trend (Line Chart)
                  _buildSectionCard(
                    title: '30-Day Trend',
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            data: last30DaysData,
                            labels: last30DaysLabels,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No data to analyze',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some expenses to see analytics',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'This Month',
                '\$${thisMonthTotal.toStringAsFixed(2)}',
                Icons.calendar_month,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Daily Avg',
                '\$${averageDailySpending.toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Highest',
                highestExpense != null
                    ? '\$${highestExpense!.amount.toStringAsFixed(2)}'
                    : '\$0.00',
                Icons.arrow_upward,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Top Category',
                mostUsedCategory,
                Icons.category,
                getCategoryColor(mostUsedCategory),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildCategoryLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: categoryData.entries.map((entry) {
        final percentage = (entry.value / categoryData.values.fold(0.0, (a, b) => a + b) * 100);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: getCategoryColor(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key} (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
