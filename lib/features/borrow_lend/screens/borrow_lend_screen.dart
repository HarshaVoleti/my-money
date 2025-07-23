import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/utils/currency_formatter.dart';
import 'package:my_money/features/borrow_lend/providers/borrow_lend_riverpod_providers.dart';
import 'package:my_money/features/borrow_lend/screens/add_borrow_lend_screen.dart';

class BorrowLendScreen extends ConsumerWidget {
  const BorrowLendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowLendProvider = ref.watch(borrowLendProviderProvider);
    final lent = borrowLendProvider.totalLentAmount;
    final borrowed = borrowLendProvider.totalBorrowedAmount;
    final net = borrowLendProvider.netPosition;
    final lentRecords = borrowLendProvider.lentRecords;
    final borrowedRecords = borrowLendProvider.borrowedRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lending & Borrowing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.compare_arrows, color: Theme.of(context).colorScheme.primary, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lending & Borrowing',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.arrow_upward, color: Colors.green, size: 18),
                            const SizedBox(width: 4),
                            Text('Lent: ', style: Theme.of(context).textTheme.bodySmall),
                            Text(
                              '₹${CurrencyFormatter.format(lent)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.arrow_downward, color: Colors.red, size: 18),
                            const SizedBox(width: 4),
                            Text('Borrowed: ', style: Theme.of(context).textTheme.bodySmall),
                            Text(
                              '₹${CurrencyFormatter.format(borrowed)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              net >= 0 ? Icons.trending_up : Icons.trending_down,
                              color: net >= 0 ? Colors.green : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text('Net Position: ', style: Theme.of(context).textTheme.bodySmall),
                            Text(
                              '₹${CurrencyFormatter.format(net)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: net >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Lent Records', style: Theme.of(context).textTheme.titleMedium),
          ...lentRecords.map((record) => ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.green),
                title: Text(record.personName),
                subtitle: Text('Amount: ₹${CurrencyFormatter.format(record.amount)}'),
                trailing: record.status == 'pending'
                    ? ElevatedButton(
                        onPressed: () async {
                          await ref.read(borrowLendProviderProvider).markAsReturned(
                            recordId: record.id,
                            returnedAmount: record.amount,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Settle'),
                      )
                    : const Text('Settled', style: TextStyle(color: Colors.grey)),
              )),
          const SizedBox(height: 24),
          Text('Borrowed Records', style: Theme.of(context).textTheme.titleMedium),
          ...borrowedRecords.map((record) => ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.red),
                title: Text(record.personName),
                subtitle: Text('Amount: ₹${CurrencyFormatter.format(record.amount)}'),
                trailing: record.status == 'pending'
                    ? ElevatedButton(
                        onPressed: () async {
                          await ref.read(borrowLendProviderProvider).markAsReturned(
                            recordId: record.id,
                            returnedAmount: record.amount,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Settle'),
                      )
                    : const Text('Settled', style: TextStyle(color: Colors.grey)),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const AddBorrowLendScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Borrow/Lend',
      ),
    );
  }
}
