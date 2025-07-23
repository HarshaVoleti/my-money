import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/features/borrow_lend/providers/borrow_lend_riverpod_providers.dart';

class AddBorrowLendScreen extends ConsumerStatefulWidget {
  const AddBorrowLendScreen({super.key});

  @override
  ConsumerState<AddBorrowLendScreen> createState() => _AddBorrowLendScreenState();
}

class _AddBorrowLendScreenState extends ConsumerState<AddBorrowLendScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'lent';
  String _personName = '';
  String _description = '';
  double _amount = 0.0;
  bool _settled = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Add Borrow or Lend')),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Record a Borrow or Lend',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.compare_arrows),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'lent', child: Text('Lent')),
                        DropdownMenuItem(value: 'borrowed', child: Text('Borrowed')),
                      ],
                      onChanged: (val) => setState(() => _type = val ?? 'lent'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Person Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (val) => _personName = val,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                      onChanged: (val) => _description = val,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) => _amount = double.tryParse(val) ?? 0.0,
                      validator: (val) => (val == null || double.tryParse(val) == null || double.parse(val) <= 0) ? 'Enter valid amount' : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      value: _settled,
                      onChanged: (val) => setState(() => _settled = val),
                      title: const Text('Mark as Paid/Settled'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Add Record'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                      // Add record, then mark as settled if needed
                      final provider = ref.read(borrowLendProviderProvider);
                      await provider.addBorrowLendRecord(
                        amount: _amount,
                        type: _type,
                        personName: _personName,
                        description: _description,
                        // status: _settled ? 'completed' : 'pending', // If provider supports status param
                      );
                      if (_settled) {
                        // Find the latest record just added (by personName, amount, type, etc.)
                        final records = provider.borrowLendRecords.where((r) =>
                          r.personName == _personName &&
                          r.amount == _amount &&
                          r.type == _type &&
                          r.status == 'pending'
                        );
                        if (records.isNotEmpty) {
                          final record = records.last;
                          await provider.markAsReturned(recordId: record.id, returnedAmount: record.amount);
                        }
                      }
                      if (mounted) Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
}
