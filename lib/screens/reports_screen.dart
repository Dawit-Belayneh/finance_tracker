import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../widgets/settings_action.dart';

/// Time granularity for financial reports.
enum ReportPeriod { weekly, monthly }

/// Displays weekly and monthly reports with income vs. expenses and category breakdown.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({
    super.key,
    required this.transactions,
    this.initialDate,
    this.onOpenSettings,
  });

  final List<Transaction> transactions;
  final DateTime? initialDate;
  final VoidCallback? onOpenSettings;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const List<Color> _categoryColors = [
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
  ];

  static const List<String> _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  ReportPeriod _period = ReportPeriod.monthly;
  bool _breakdownExpenses = true;
  late DateTime _anchorDate;

  @override
  void initState() {
    super.initState();
    _anchorDate = _resolveInitialDate();
  }

  DateTime _resolveInitialDate() {
    if (widget.initialDate != null) {
      return DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
        widget.initialDate!.day,
      );
    }

    final now = DateTime.now();
    final hasCurrentMonth = widget.transactions.any(
      (t) => t.date.year == now.year && t.date.month == now.month,
    );
    if (hasCurrentMonth || widget.transactions.isEmpty) {
      return DateTime(now.year, now.month, now.day);
    }

    final latest = widget.transactions.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );
    return DateTime(latest.date.year, latest.date.month, latest.date.day);
  }

  DateTime get _weekStart {
    final normalized =
        DateTime(_anchorDate.year, _anchorDate.month, _anchorDate.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  void _shiftPeriod(int delta) {
    setState(() {
      if (_period == ReportPeriod.weekly) {
        _anchorDate = _anchorDate.add(Duration(days: 7 * delta));
      } else {
        _anchorDate = DateTime(_anchorDate.year, _anchorDate.month + delta, 1);
      }
    });
  }

  List<Transaction> get _periodTransactions {
    if (_period == ReportPeriod.weekly) {
      final start = _weekStart;
      final end = start.add(const Duration(days: 7));
      return widget.transactions.where((t) {
        final d = DateTime(t.date.year, t.date.month, t.date.day);
        return !d.isBefore(start) && d.isBefore(end);
      }).toList();
    }

    return widget.transactions
        .where(
          (t) =>
              t.date.year == _anchorDate.year &&
              t.date.month == _anchorDate.month,
        )
        .toList();
  }

  List<_PeriodBucket> _buildBuckets(List<Transaction> items) {
    if (_period == ReportPeriod.weekly) {
      final start = _weekStart;
      return List.generate(7, (index) {
        final day = start.add(Duration(days: index));
        double income = 0;
        double expense = 0;
        for (final t in items) {
          if (t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day) {
            if (t.isExpense) {
              expense += t.amount;
            } else {
              income += t.amount;
            }
          }
        }
        return _PeriodBucket(
          label: _weekdayLabels[index],
          income: income,
          expense: expense,
        );
      });
    }

    final daysInMonth =
        DateUtils.getDaysInMonth(_anchorDate.year, _anchorDate.month);
    final weekCount = ((daysInMonth - 1) ~/ 7) + 1;

    return List.generate(weekCount, (index) {
      final startDay = index * 7 + 1;
      final endDay = math.min((index + 1) * 7, daysInMonth);
      double income = 0;
      double expense = 0;
      for (final t in items) {
        if (t.date.day >= startDay && t.date.day <= endDay) {
          if (t.isExpense) {
            expense += t.amount;
          } else {
            income += t.amount;
          }
        }
      }
      return _PeriodBucket(
        label: 'W${index + 1}',
        income: income,
        expense: expense,
      );
    });
  }

  List<MapEntry<String, double>> _categoryTotals(List<Transaction> items) {
    final Map<String, double> totals = {};
    for (final t in items.where((t) => t.isExpense == _breakdownExpenses)) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final items = _periodTransactions;
    final totalIncome = items
        .where((t) => !t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpenses = items
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final net = totalIncome - totalExpenses;
    final buckets = _buildBuckets(items);
    final categories = _categoryTotals(items);
    final breakdownTotal =
        categories.fold<double>(0, (sum, e) => sum + e.value);

    final periodLabel = _period == ReportPeriod.weekly
        ? formatWeekRange(_weekStart)
        : formatMonthYear(_anchorDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: buildSettingsActions(widget.onOpenSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<ReportPeriod>(
            key: const Key('report_period_selector'),
            segments: const [
              ButtonSegment(
                value: ReportPeriod.weekly,
                label: Text('Weekly'),
              ),
              ButtonSegment(
                value: ReportPeriod.monthly,
                label: Text('Monthly'),
              ),
            ],
            selected: {_period},
            onSelectionChanged: (selection) {
              setState(() => _period = selection.first);
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Previous period',
                    onPressed: () => _shiftPeriod(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Flexible(
                    child: Text(
                      periodLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next period',
                    onPressed: () => _shiftPeriod(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReportMetricCard(
                  label: 'Income',
                  value: money(totalIncome),
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReportMetricCard(
                  label: 'Expenses',
                  value: money(totalExpenses),
                  color: Colors.red,
                  icon: Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReportMetricCard(
                  label: 'Net',
                  value: '${net >= 0 ? '+' : '-'}${money(net.abs())}',
                  color: net >= 0 ? Colors.green : Colors.red,
                  icon: Icons.balance,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _IncomeVsExpensesCard(
            buckets: buckets,
            hasData: totalIncome > 0 || totalExpenses > 0,
          ),
          const SizedBox(height: 12),
          _CategoryBreakdownCard(
            categories: categories,
            total: breakdownTotal,
            showExpenses: _breakdownExpenses,
            colors: _categoryColors,
            onToggleType: (isExpense) {
              setState(() => _breakdownExpenses = isExpense);
            },
          ),
        ],
      ),
    );
  }
}

class _PeriodBucket {
  const _PeriodBucket({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;
}

class _ReportMetricCard extends StatelessWidget {
  const _ReportMetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeVsExpensesCard extends StatelessWidget {
  const _IncomeVsExpensesCard({
    required this.buckets,
    required this.hasData,
  });

  final List<_PeriodBucket> buckets;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    double maxVal = 0;
    for (final b in buckets) {
      maxVal = math.max(maxVal, math.max(b.income, b.expense));
    }
    final chartMaxY = maxVal > 0 ? maxVal * 1.2 : 100.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  const Text(
                    'Income vs Expenses',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _LegendDot(color: Colors.green, label: 'Income'),
                      SizedBox(width: 12),
                      _LegendDot(color: Colors.red, label: 'Expenses'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!hasData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No transactions in this period')),
              )
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: chartMaxY,
                    barTouchData: BarTouchData(enabled: true),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value >= 1000
                                    ? '\$${(value / 1000).toStringAsFixed(1)}k'
                                    : '\$${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= buckets.length) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                buckets[index].label,
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < buckets.length; i++)
                        BarChartGroupData(
                          x: i,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: buckets[i].income,
                              color: Colors.green,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: buckets[i].expense,
                              color: Colors.red,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({
    required this.categories,
    required this.total,
    required this.showExpenses,
    required this.colors,
    required this.onToggleType,
  });

  final List<MapEntry<String, double>> categories;
  final double total;
  final bool showExpenses;
  final List<Color> colors;
  final ValueChanged<bool> onToggleType;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 6,
                    children: [
                      ChoiceChip(
                        label: const Text('Expenses'),
                        selected: showExpenses,
                        onSelected: (_) => onToggleType(true),
                      ),
                      ChoiceChip(
                        label: const Text('Income'),
                        selected: !showExpenses,
                        onSelected: (_) => onToggleType(false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty || total <= 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    showExpenses
                        ? 'No expenses in this period'
                        : 'No income in this period',
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    sections: [
                      for (var i = 0; i < categories.length; i++)
                        PieChartSectionData(
                          value: categories[i].value,
                          color: colors[i % colors.length],
                          title:
                              '${(categories[i].value / total * 100).toStringAsFixed(0)}%',
                          radius: 54,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < categories.length; i++) ...[
                _CategoryBreakdownRow(
                  name: categories[i].key,
                  amount: categories[i].value,
                  share: categories[i].value / total,
                  color: colors[i % colors.length],
                ),
                if (i < categories.length - 1) const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdownRow extends StatelessWidget {
  const _CategoryBreakdownRow({
    required this.name,
    required this.amount,
    required this.share,
    required this.color,
  });

  final String name;
  final double amount;
  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percentText = '${(share * 100).toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Text(
              '$percentText • ${money(amount)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: share.clamp(0.0, 1.0),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
          color: color,
          backgroundColor: color.withValues(alpha: 0.15),
        ),
      ],
    );
  }
}
