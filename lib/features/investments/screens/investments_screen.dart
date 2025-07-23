import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/investment_model.dart';
import 'package:my_money/features/investments/providers/investment_riverpod_providers.dart';
import 'package:my_money/features/investments/providers/investment_provider.dart';
import 'package:my_money/features/investments/screens/add_investment_screen.dart';
import 'package:my_money/core/utils/currency_formatter.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🔧 Building InvestmentsScreen');
    
    final portfolioSummary = ref.watch(portfolioSummaryProvider);
    final investmentProvider = ref.watch(investmentProviderProvider);
    
    print('📊 Portfolio Summary in UI: $portfolioSummary');
    print('📊 Investment Provider State:');
    print('  - Loading: ${investmentProvider.isLoading}');
    print('  - Error: ${investmentProvider.error}');
    print('  - Investments count: ${investmentProvider.investments.length}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              print('🔄 Manual refresh triggered');
              await ref.read(investmentProviderProvider).refreshInvestments();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              print('🔧 Navigate to AddInvestmentScreen');
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
          print('🔄 Pull to refresh triggered');
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
            
            // Show loading, error, investment list or empty state
            _buildInvestmentsList(context, investmentProvider),
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

  Widget _buildInvestmentsList(BuildContext context, InvestmentProvider investmentProvider) {
    print('🔧 Building investments list - Loading: ${investmentProvider.isLoading}, Error: ${investmentProvider.error}, Investments count: ${investmentProvider.investments.length}');

    if (investmentProvider.isLoading == true) {
      print('🔧 Showing loading indicator');
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (investmentProvider.error != null) {
      print('❌ Showing error state: ${investmentProvider.error}');
      final errorMessage = investmentProvider.error?.toString() ?? 'Unknown error';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading investments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('� Retrying investment load');
                // The provider should automatically retry when created
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (investmentProvider.investments.isEmpty == true) {
      print('🔧 Showing empty state');
      return const Center(
        child: Text('No investments found'),
      );
    }

    print('🔧 Showing investments list with ${investmentProvider.investments.length} items');
    return ListView(
      children: investmentProvider.investments.map<Widget>((InvestmentModel investment) {
        print('🔧 Rendering investment: ${investment.name}');
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: investment.profitLoss >= 0 ? Colors.green : Colors.red,
              child: Text(
                investment.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(investment.name),
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
              print('🔧 Investment tapped: ${investment.name}');
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => AddInvestmentScreen(investment: investment),
                ),
              );
            },
          ),
        );
      }).toList(),
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
