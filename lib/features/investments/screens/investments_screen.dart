import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/investment_model.dart';
import 'package:my_money/features/investments/providers/investment_riverpod_providers.dart';
import 'package:my_money/features/investments/screens/add_investment_screen.dart';
import 'package:my_money/core/utils/currency_formatter.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioSummary = ref.watch(portfolioSummaryProvider);
    final investmentProvider = ref.watch(investmentProviderProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.read(investmentProviderProvider).refreshInvestments();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AddInvestmentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(investmentProviderProvider).refreshInvestments();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portfolio Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Total Investment',
                            CurrencyFormatter.format((portfolioSummary['totalInvestment'] as num?)?.toDouble() ?? 0),
                            Colors.blue,
                            Icons.account_balance_wallet,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Current Value',
                            CurrencyFormatter.format((portfolioSummary['currentValue'] as num?)?.toDouble() ?? 0),
                            Colors.green,
                            Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Total P&L',
                            CurrencyFormatter.format((portfolioSummary['totalProfitLoss'] as num?)?.toDouble() ?? 0),
                            ((portfolioSummary['totalProfitLoss'] as num?)?.toDouble() ?? 0) >= 0 ? Colors.green : Colors.red,
                            Icons.analytics,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'P&L %',
                            '${((portfolioSummary['profitLossPercentage'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}%',
                            ((portfolioSummary['profitLossPercentage'] as num?)?.toDouble() ?? 0) >= 0 ? Colors.green : Colors.red,
                            Icons.percent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Investment Type Filter
            Text(
              'Investment Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Stocks', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Mutual Funds', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Bonds', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('ETF', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Crypto', false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Investments List
            Text(
              'Your Investments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Show investment list or empty state
            (investmentProvider.investments as List).isEmpty
                ? _buildEmptyState(context)
                : _buildInvestmentsList(investmentProvider.investments as List<InvestmentModel>),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Investments Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your portfolio by adding your first investment',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const AddInvestmentScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Investment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentsList(List<InvestmentModel> investments) {
    return Column(
      children: investments.map((investment) => 
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(investment.color.colorValue),
              child: Text(
                investment.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              investment.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${investment.quantity} units @ ${CurrencyFormatter.format(investment.purchasePrice)}'),
                Text(
                  investment.type.displayName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  CurrencyFormatter.format(investment.currentValue),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${investment.profitLoss >= 0 ? '+' : ''}${CurrencyFormatter.format(investment.profitLoss)}',
                  style: TextStyle(
                    color: investment.profitLoss >= 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Navigate to investment details
            },
          ),
        )
      ).toList(),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Handle filter selection
      },
    );
  }
}
