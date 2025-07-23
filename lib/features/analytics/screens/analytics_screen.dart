import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/features/deposits/providers/deposit_providers.dart';
import 'package:my_money/features/investments/providers/investment_riverpod_providers.dart';
import 'package:my_money/features/transactions/providers/transaction_provider.dart';
import 'package:my_money/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:my_money/features/borrow_lend/providers/borrow_lend_riverpod_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0);

    // Providers
    final monthlySummaryAsync = ref.watch(monthlyTransactionSummaryProvider((year: year, month: month)));
    final categoryBreakdownAsync = ref.watch(categoryWiseSpendingProvider((startDate: monthStart, endDate: monthEnd)));
    final investmentsAsync = ref.watch(investmentStreamProvider);
    final depositsAsync = ref.watch(depositsStreamProvider);
    final bankAccountsAsync = ref.watch(bankAccountsStreamProvider);
    final borrowLendAsync = ref.watch(borrowLendProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _SectionTitle('Lending & Borrowing'),
          Builder(
            builder: (context) {
              final provider = borrowLendAsync;
              final lent = provider.totalLentAmount;
              final borrowed = provider.totalBorrowedAmount;
              final net = provider.netPosition;
              return Card(
                elevation: 0,
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Lent: ₹${lent.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Total Borrowed: ₹${borrowed.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Net Position: ₹${net.toStringAsFixed(2)}', style: TextStyle(color: net >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle('Credit Card Utilization'),
          bankAccountsAsync.when(
            data: (accounts) {
              final creditCards = accounts.where((a) => a.type.value == 'credit_card').toList();
              if (creditCards.isEmpty) {
                return const Text('No credit cards found.');
              }
              return Column(
                children: creditCards.map((card) {
                  return Card(
                    elevation: 0,
                    color: Colors.grey[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.credit_card, color: Colors.deepPurple),
                      title: Text(card.name),
                      subtitle: Text('Balance: ₹${card.balance.toStringAsFixed(2)}'),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorChart(message: 'Failed to load credit cards'),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Income vs Expense'),
          monthlySummaryAsync.when(
            data: (summary) {
              final income = summary['income'] ?? 0.0;
              final expense = summary['expense'] ?? 0.0;
              return SizedBox(
                height: 220,
                child: Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final bars = ['Income', 'Expense'];
                                return Text(bars[value.toInt() % bars.length]);
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: income, color: Colors.green, width: 24)]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: expense, color: Colors.red, width: 24)]),
                        ],
                        gridData: FlGridData(show: true),
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorChart(message: 'Failed to load income/expense'),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Expense Breakdown by Category'),
          categoryBreakdownAsync.when(
            data: (categoryMap) {
              final total = categoryMap.values.fold<double>(0.0, (a, b) => a + b);
              final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.red, Colors.teal, Colors.brown, Colors.pink, Colors.indigo];
              int colorIdx = 0;
              return SizedBox(
                height: 220,
                child: Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: PieChart(
                      PieChartData(
                        sections: categoryMap.entries.map((e) {
                          final percent = total > 0 ? (e.value / total * 100) : 0.0;
                          final color = colors[colorIdx++ % colors.length];
                          return PieChartSectionData(
                            value: e.value,
                            color: color,
                            title: '${e.key}\n${percent.toStringAsFixed(1)}%',
                            radius: 40 + (percent > 20 ? 10 : 0),
                            titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 32,
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorChart(message: 'Failed to load category breakdown'),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Investment Growth'),
          investmentsAsync.when(
            data: (investments) {
              // Group by month, sum currentValue
              final Map<String, double> monthValue = {};
              for (final inv in investments) {
                final key = '${inv.purchaseDate.year}-${inv.purchaseDate.month.toString().padLeft(2, '0')}';
                monthValue[key] = (monthValue[key] ?? 0) + inv.currentValue;
              }
              final sortedKeys = monthValue.keys.toList()..sort();
              final spots = <FlSpot>[];
              for (int i = 0; i < sortedKeys.length; i++) {
                spots.add(FlSpot(i.toDouble(), monthValue[sortedKeys[i]] ?? 0));
              }
              return SizedBox(
                height: 220,
                child: Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots.isNotEmpty ? spots : [FlSpot(0, 0)],
                            isCurved: true,
                            color: Colors.indigo,
                            barWidth: 4,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= sortedKeys.length) return const SizedBox();
                                final label = sortedKeys[idx];
                                return Text(label.substring(2), style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: true),
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorChart(message: 'Failed to load investment growth'),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Deposit Maturity Timeline'),
          depositsAsync.when(
            data: (deposits) {
              // Group by maturity month, count deposits
              final Map<String, int> maturityMap = {};
              for (final dep in deposits) {
                final key = '${dep.maturityDate.year}-${dep.maturityDate.month.toString().padLeft(2, '0')}';
                maturityMap[key] = (maturityMap[key] ?? 0) + 1;
              }
              final sortedKeys = maturityMap.keys.toList()..sort();
              final barGroups = <BarChartGroupData>[];
              for (int i = 0; i < sortedKeys.length; i++) {
                barGroups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: maturityMap[sortedKeys[i]]!.toDouble(), color: Colors.teal, width: 18)]));
              }
              return SizedBox(
                height: 180,
                child: Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= sortedKeys.length) return const SizedBox();
                                final label = sortedKeys[idx];
                                return Text(label.substring(2), style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups.isNotEmpty ? barGroups : [BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: Colors.teal, width: 18)])],
                        gridData: FlGridData(show: true),
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorChart(message: 'Failed to load deposit timeline'),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Net Worth Trend'),
          // True net worth trend: investments + deposits + bank accounts
          investmentsAsync.when(
            data: (investments) {
              return depositsAsync.when(
                data: (deposits) {
                  return bankAccountsAsync.when(
                    data: (bankAccounts) {
                      // Group by month, sum currentValue for investments, deposits, and add bank balances
                      final Map<String, double> monthValue = {};
                      for (final inv in investments) {
                        final key = '${inv.purchaseDate.year}-${inv.purchaseDate.month.toString().padLeft(2, '0')}';
                        monthValue[key] = (monthValue[key] ?? 0) + inv.currentValue;
                      }
                      for (final dep in deposits) {
                        final key = '${dep.startDate.year}-${dep.startDate.month.toString().padLeft(2, '0')}';
                        monthValue[key] = (monthValue[key] ?? 0) + dep.currentValue;
                      }
                      // For bank accounts, assume current balance for the latest month
                      if (bankAccounts.isNotEmpty) {
                        final now = DateTime.now();
                        final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
                        final totalBank = bankAccounts.fold<double>(0.0, (sum, acc) => sum + acc.balance);
                        monthValue[key] = (monthValue[key] ?? 0) + totalBank;
                      }
                      final sortedKeys = monthValue.keys.toList()..sort();
                      final spots = <FlSpot>[];
                      for (int i = 0; i < sortedKeys.length; i++) {
                        spots.add(FlSpot(i.toDouble(), monthValue[sortedKeys[i]] ?? 0));
                      }
                      return SizedBox(
                        height: 220,
                        child: Card(
                          elevation: 0,
                          color: Colors.grey[50],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots.isNotEmpty ? spots : [FlSpot(0, 0)],
                                    isCurved: true,
                                    color: Colors.deepOrange,
                                    barWidth: 4,
                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx < 0 || idx >= sortedKeys.length) return const SizedBox();
                                        final label = sortedKeys[idx];
                                        return Text(label.substring(2), style: const TextStyle(fontSize: 10));
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: true),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _ErrorChart(message: 'Failed to load bank accounts'),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorChart(message: 'Failed to load deposits'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorChart(message: 'Failed to load investments'),
          ),
        ],
      ),
    );
  }
}

class _ErrorChart extends StatelessWidget {
  final String message;
  const _ErrorChart({required this.message});
  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.red[400], fontSize: 16),
          ),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );
}


