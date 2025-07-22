import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/bank_account_model.dart';
import 'package:my_money/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:my_money/features/bank_accounts/screens/add_bank_account_screen.dart';

class BankAccountSelector extends ConsumerWidget {
  const BankAccountSelector({
    super.key,
    required this.onAccountSelected,
    this.selectedAccountId,
    this.label = 'Select Bank Account',
    this.isRequired = false,
  });

  final ValueChanged<BankAccountModel?> onAccountSelected;
  final String? selectedAccountId;
  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankAccountsAsync = ref.watch(bankAccountsStreamProvider);

    return bankAccountsAsync.when(
      data: (accounts) {
        final activeAccounts = accounts
            .where((account) => account.status == AccountStatus.active)
            .toList();

        if (activeAccounts.isEmpty) {
          return _EmptyState(label: label);
        }

        final selectedAccount = selectedAccountId != null
            ? activeAccounts.firstWhere(
                (account) => account.id == selectedAccountId,
                orElse: () => activeAccounts.first,
              )
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty) ...[
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: selectedAccountId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                      prefixIcon: selectedAccount != null
                          ? Icon(
                              _getAccountTypeIcon(selectedAccount.type),
                              color: Color(selectedAccount.color.colorValue),
                            )
                          : const Icon(Icons.account_balance),
                    ),
                  hint: Text(
                    'Choose bank account',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  validator: isRequired
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a bank account';
                          }
                          return null;
                        }
                      : null,
                  items: activeAccounts.map((account) {
                    return DropdownMenuItem<String>(
                      value: account.id,
                      child: _AccountDropdownItem(account: account),
                    );
                  }).toList(),
                  onChanged: (accountId) {
                    final account = accountId != null
                        ? activeAccounts.firstWhere((a) => a.id == accountId)
                        : null;
                    onAccountSelected(account);
                  },
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.red[50],
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading accounts',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.invalidate(bankAccountsStreamProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.wallet:
        return Icons.account_balance_wallet;
      case AccountType.cash:
        return Icons.money;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.debitCard:
        return Icons.payment;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No bank accounts found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add a bank account to continue',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const AddBankAccountScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountDropdownItem extends StatelessWidget {
  const _AccountDropdownItem({required this.account});

  final BankAccountModel account;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Color(account.color.colorValue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getAccountTypeIcon(account.type),
            color: Color(account.color.colorValue),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      account.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (account.isDefault) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'DEFAULT',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                account.bankName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      account.maskedAccountNumber,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${account.balance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: account.balance >= 0 ? Colors.green : Colors.red,
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

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.wallet:
        return Icons.account_balance_wallet;
      case AccountType.cash:
        return Icons.money;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.debitCard:
        return Icons.payment;
    }
  }
}
