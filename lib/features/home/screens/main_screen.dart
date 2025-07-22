import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/transaction_model.dart';
import 'package:my_money/core/utils/currency_formatter.dart';
import 'package:my_money/features/bank_accounts/screens/bank_accounts_screen.dart';
import 'package:my_money/features/deposits/screens/deposits_screen.dart';
import 'package:my_money/features/home/providers/home_providers.dart';
import 'package:my_money/features/investments/screens/investments_screen.dart';
import 'package:my_money/features/settings/screens/settings_screen.dart';
import 'package:my_money/features/transactions/screens/add_income_screen.dart';
import 'package:my_money/features/transactions/screens/transactions_screen.dart';
import 'package:my_money/shared/widgets/dashboard_widgets.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Money'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.blueAccent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'My Money',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Bank Accounts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const BankAccountsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Deposits'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const DepositsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Transactions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Investments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const InvestmentsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to analytics
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Financial Overview Cards
            _FinancialOverviewSection(),
            SizedBox(height: 24),
            
            // Quick Actions
            _QuickActionsSection(),
            SizedBox(height: 24),
            
            // Recent Transactions
            _RecentTransactionsSection(),
            SizedBox(height: 24),
            
            // Investment Summary
            _InvestmentSummarySection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const AddIncomeScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FinancialOverviewSection extends ConsumerWidget {
  const _FinancialOverviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        dashboardSummaryAsync.when(
          data: (summary) => Column(
            children: [
              // Total Balance and Bank Account Balance
              Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      title: 'Total Balance',
                      amount: CurrencyFormatter.format(summary.totalBalance),
                      icon: Icons.account_balance_wallet,
                      color: summary.totalBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OverviewCard(
                      title: 'Bank Balance',
                      amount: CurrencyFormatter.format(summary.bankAccountBalance),
                      icon: Icons.account_balance,
                      color: summary.bankAccountBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Transaction Balance and Monthly Income
              Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      title: 'Transactions',
                      amount: CurrencyFormatter.formatWithSign(summary.transactionBalance),
                      icon: summary.transactionBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: summary.transactionBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OverviewCard(
                      title: 'This Month',
                      amount: CurrencyFormatter.formatWithSign(summary.monthlyIncome - summary.monthlyExpense),
                      icon: (summary.monthlyIncome - summary.monthlyExpense) >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: (summary.monthlyIncome - summary.monthlyExpense) >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          loading: () => const Column(
            children: [
              Row(
                children: [
                  Expanded(child: DashboardLoadingCard(title: 'Total Balance')),
                  SizedBox(width: 12),
                  Expanded(child: DashboardLoadingCard(title: 'Bank Balance')),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: DashboardLoadingCard(title: 'Transactions')),
                  SizedBox(width: 12),
                  Expanded(child: DashboardLoadingCard(title: 'This Month')),
                ],
              ),
            ],
          ),
          error: (error, stack) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DashboardErrorCard(
                      title: 'Total Balance',
                      error: error.toString(),
                      onRetry: () => ref.invalidate(dashboardSummaryProvider),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardErrorCard(
                      title: 'Bank Balance',
                      error: error.toString(),
                      onRetry: () => ref.invalidate(dashboardSummaryProvider),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DashboardErrorCard(
                      title: 'Transactions',
                      error: error.toString(),
                      onRetry: () => ref.invalidate(dashboardSummaryProvider),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardErrorCard(
                      title: 'This Month',
                      error: error.toString(),
                      onRetry: () => ref.invalidate(dashboardSummaryProvider),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
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
              amount,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'Add Income',
              color: Colors.green,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const AddIncomeScreen(),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.remove_circle_outline,
              label: 'Add Expense',
              color: Colors.red,
              onTap: () {
                // TODO: Navigate to add expense
              },
            ),
            _QuickActionButton(
              icon: Icons.savings,
              label: 'Deposits',
              color: Colors.purple,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const DepositsScreen(),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.receipt_long,
              label: 'View All',
              color: Colors.grey,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsSection extends ConsumerWidget {
  const _RecentTransactionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTransactions = ref.watch(recentTransactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentTransactions.isEmpty)
          DashboardEmptyCard(
            title: 'No transactions yet',
            message: 'Start by adding your first transaction',
            icon: Icons.receipt_long_outlined,
            onAction: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AddIncomeScreen(),
                ),
              );
            },
            actionText: 'Add Transaction',
          )
        else
          Column(
            children: recentTransactions
                .map((transaction) => _TransactionTile(transaction: transaction))
                .toList(),
          ),
      ],
    );
  }
}

class _InvestmentSummarySection extends ConsumerWidget {
  const _InvestmentSummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentStreamAsync = ref.watch(investmentStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Investment Portfolio',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const InvestmentsScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        investmentStreamAsync.when(
          data: (investments) {
            // Calculate investment summary
            final totalInvestment = investments.fold<double>(
              0.0, (sum, inv) => sum + inv.totalInvestment,
            );
            final currentValue = investments.fold<double>(
              0.0, (sum, inv) => sum + inv.currentValue,
            );
            final profitLoss = currentValue - totalInvestment;
            final profitLossPercentage = totalInvestment > 0 ? (profitLoss / totalInvestment) * 100 : 0.0;

            if (investments.isEmpty) {
              return DashboardEmptyCard(
                title: 'No investments yet',
                message: 'Start building your investment portfolio',
                icon: Icons.trending_up_outlined,
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const InvestmentsScreen(),
                    ),
                  );
                },
                actionText: 'Add Investment',
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Investment Value',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(currentValue),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Invested: ${CurrencyFormatter.format(totalInvestment)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${profitLossPercentage >= 0 ? '+' : ''}${profitLossPercentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: profitLossPercentage >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatWithSign(profitLoss),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: profitLoss >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          'Overall',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const DashboardLoadingCard(title: 'Investment Portfolio'),
          error: (error, stack) => DashboardErrorCard(
            title: 'Investment Portfolio',
            error: error.toString(),
            onRetry: () => ref.invalidate(investmentStreamProvider),
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          transaction.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${transaction.category} • ${_formatDate(transaction.date)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          CurrencyFormatter.formatWithSign(isIncome ? transaction.amount : -transaction.amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';
    
    return '${date.day}/${date.month}';
  }
}

class _TransactionPlaceholder extends StatelessWidget {
  const _TransactionPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding your first transaction',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
