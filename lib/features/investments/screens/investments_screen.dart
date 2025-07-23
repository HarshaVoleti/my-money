import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/investment_model.dart';
import 'package:my_money/core/models/investment_position.dart';
import 'package:my_money/features/investments/providers/investment_riverpod_providers.dart';
import 'package:my_money/features/investments/providers/investment_provider.dart';
import 'package:my_money/features/investments/providers/investment_live_price_provider.dart';
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
    print('  - Positions count: ${investmentProvider.positions.length}');
    
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
    
    if (investmentProvider.positions.isEmpty == true) {
      print('🔧 Showing empty state');
      return const Center(
        child: Text('No investments found'),
      );
    }

    print('🔧 Showing positions list with ${investmentProvider.positions.length} positions');
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: investmentProvider.positions.map<Widget>((InvestmentPosition position) {
        print('🔧 Rendering position: ${position.symbol} (${position.orderCount} orders)');
        return Consumer(
          builder: (context, ref, _) {
            final livePriceAsync = ref.watch(livePriceStreamProvider(position));
            return livePriceAsync.when(
              data: (livePrice) {
                final liveCurrentValue = livePrice * position.totalQuantity;
                final liveProfitLoss = liveCurrentValue - position.totalInvestment;
                final liveProfitLossPercentage = position.totalInvestment > 0 ? (liveProfitLoss / position.totalInvestment) * 100 : 0.0;
                final isProfit = liveProfitLoss > 0;
                return _buildPositionExpansionTile(
                  context,
                  position.copyWith(currentPrice: livePrice),
                  investmentProvider,
                  liveCurrentValue: liveCurrentValue,
                  liveProfitLoss: liveProfitLoss,
                  liveProfitLossPercentage: liveProfitLossPercentage,
                  isProfit: isProfit,
                );
              },
              loading: () => _buildPositionExpansionTile(
                context,
                position,
                investmentProvider,
                isLoading: true,
              ),
              error: (e, _) => _buildPositionExpansionTile(
                context,
                position,
                investmentProvider,
                error: e.toString(),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPositionExpansionTile(
    BuildContext context,
    InvestmentPosition position,
    InvestmentProvider investmentProvider, {
    double? liveCurrentValue,
    double? liveProfitLoss,
    double? liveProfitLossPercentage,
    bool? isProfit,
    bool isLoading = false,
    String? error,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: (isProfit ?? position.isProfit) ? Colors.green : Colors.red,
          child: Text(
            position.symbol.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    position.symbol,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    position.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        CurrencyFormatter.format(liveCurrentValue ?? position.currentValue),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                Text(
                  '${(liveProfitLoss ?? position.profitLoss) >= 0 ? '+' : ''}${CurrencyFormatter.format(liveProfitLoss ?? position.profitLoss)}',
                  style: TextStyle(
                    color: (isProfit ?? position.isProfit) ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${position.totalQuantity} units @ ₹${position.averagePrice.toStringAsFixed(2)} avg',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${position.orderCount} order(s) • Current: ₹${(liveCurrentValue != null ? (liveCurrentValue / position.totalQuantity).toStringAsFixed(2) : position.currentPrice.toStringAsFixed(2))}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showEditCurrentPriceDialog(context, position),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Error fetching live price: $error', style: const TextStyle(color: Colors.red)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orders History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...position.orders.map((order) => _buildOrderTile(context, order)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => AddInvestmentScreen(
                              investment: position.orders.first.copyWith(
                                symbol: position.symbol,
                                currentPrice: position.currentPrice,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Order'),
                    ),
                    TextButton.icon(
                      onPressed: () => _showEditCurrentPriceDialog(context, position),
                      icon: const Icon(Icons.trending_up, size: 16),
                      label: const Text('Update Price'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(BuildContext context, InvestmentModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.quantity} units @ ₹${order.purchasePrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${order.purchaseDate.day}/${order.purchaseDate.month}/${order.purchaseDate.year} • ${order.platform}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(order.totalInvestment),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Invested',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => AddInvestmentScreen(investment: order),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.edit,
                size: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCurrentPriceDialog(BuildContext context, InvestmentPosition position) {
    final TextEditingController priceController = TextEditingController(
      text: position.currentPrice.toStringAsFixed(2),
    );

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Current Price for ${position.symbol}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This will update the current price for all ${position.orderCount} order(s) of ${position.symbol}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Current Price',
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(priceController.text);
                if (newPrice != null && newPrice > 0) {
                  // TODO: Implement current price update
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Current price updated to ₹${newPrice.toStringAsFixed(2)}'),
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
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
