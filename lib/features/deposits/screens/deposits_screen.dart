import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/enums/investment_enums.dart';
import 'package:my_money/core/models/deposit_model.dart';
import 'package:my_money/features/deposits/providers/deposit_providers.dart';
import 'package:my_money/features/deposits/screens/add_deposit_screen.dart';

class DepositsScreen extends ConsumerWidget {
  const DepositsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depositsAsync = ref.watch(depositsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposits'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Deposit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AddDepositScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: depositsAsync.when(
        data: (deposits) {
          if (deposits.isEmpty) {
            return const _EmptyState();
          }

          return Column(
            children: [
              // Summary Cards
              _DepositSummaryCards(),
              
              // Deposits List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: deposits.length,
                  itemBuilder: (context, index) {
                    final deposit = deposits[index];
                    return _DepositCard(deposit: deposit);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading deposits',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SelectableText(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(depositsStreamProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const AddDepositScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 96,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Deposits Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add your fixed deposits, recurring deposits, and other savings to track your investments.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const AddDepositScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositSummaryCards extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(depositStatsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: statsAsync.when(
        data: (stats) => Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Principal',
                value: '₹${(stats['totalPrincipal'] as double).toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Expected Return',
                value: '₹${(stats['totalInterest'] as double).toStringAsFixed(0)}',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Active Deposits',
                value: '${stats['activeDeposits']}',
                icon: Icons.savings,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositCard extends ConsumerWidget {
  const _DepositCard({required this.deposit});

  final DepositModel deposit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(deposit.color.colorValue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getDepositTypeIcon(deposit.type),
            color: Color(deposit.color.colorValue),
            size: 24,
          ),
        ),
        title: Text(
          deposit.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(deposit.bankName),
            Text(
              '${deposit.interestRate}% p.a. • ${deposit.daysToMaturity} days to maturity',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₹${deposit.principalAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(deposit.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                deposit.status.displayName,
                style: TextStyle(
                  color: _getStatusColor(deposit.status),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DetailItem(
                        label: 'Start Date',
                        value: '${deposit.startDate.day}/${deposit.startDate.month}/${deposit.startDate.year}',
                      ),
                    ),
                    Expanded(
                      child: _DetailItem(
                        label: 'Maturity Date',
                        value: '${deposit.maturityDate.day}/${deposit.maturityDate.month}/${deposit.maturityDate.year}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _DetailItem(
                        label: 'Expected Maturity',
                        value: '₹${deposit.expectedMaturityAmount.toStringAsFixed(0)}',
                      ),
                    ),
                    Expanded(
                      child: _DetailItem(
                        label: 'Total Interest',
                        value: '₹${deposit.totalInterest.toStringAsFixed(0)}',
                      ),
                    ),
                  ],
                ),
                if (deposit.type == DepositType.recurringDeposit) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailItem(
                          label: 'Monthly Installment',
                          value: '₹${deposit.monthlyInstallment?.toStringAsFixed(0) ?? 'N/A'}',
                        ),
                      ),
                      Expanded(
                        child: _DetailItem(
                          label: 'Tenure',
                          value: '${deposit.tenureMonths ?? 'N/A'} months',
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => AddDepositScreen(deposit: deposit),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: deposit.status == DepositStatus.active
                            ? () => _showCloseDialog(context, ref)
                            : null,
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
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

  void _showCloseDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Deposit'),
        content: Text('Are you sure you want to close ${deposit.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(depositNotifierProvider.notifier)
                  .closeDeposit(deposit.id, isPremature: !deposit.isMatured);
            },
            child: const Text('Premature Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(depositNotifierProvider.notifier)
                  .closeDeposit(deposit.id, isPremature: false);
            },
            child: const Text('Matured Close'),
          ),
        ],
      ),
    );
  }

  IconData _getDepositTypeIcon(DepositType type) {
    switch (type) {
      case DepositType.fixedDeposit:
        return Icons.lock;
      case DepositType.recurringDeposit:
        return Icons.repeat;
      case DepositType.savingsAccount:
        return Icons.savings;
      case DepositType.ppf:
        return Icons.security;
      case DepositType.nsc:
        return Icons.article;
      default:
        return Icons.account_balance;
    }
  }

  Color _getStatusColor(DepositStatus status) {
    switch (status) {
      case DepositStatus.active:
        return Colors.green;
      case DepositStatus.matured:
        return Colors.blue;
      case DepositStatus.prematureClosed:
        return Colors.orange;
      case DepositStatus.suspended:
        return Colors.red;
    }
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
