import 'package:my_money/features/borrow_lend/screens/borrow_lend_screen.dart';
import 'package:my_money/features/borrow_lend/screens/add_borrow_lend_screen.dart';
import 'package:flutter/material.dart';
import 'package:my_money/features/transactions/screens/add_income_screen.dart';
import 'package:my_money/features/transactions/screens/add_expense_screen.dart';
import 'package:my_money/features/deposits/screens/add_deposit_screen.dart';
import 'package:my_money/features/investments/screens/add_investment_screen.dart';
import 'package:my_money/features/investments/screens/investments_screen.dart';
import 'package:my_money/features/deposits/screens/deposits_screen.dart';
import 'package:my_money/features/bank_accounts/screens/bank_accounts_screen.dart';
import 'package:my_money/features/bank_accounts/screens/add_bank_account_screen.dart';

class AllQuickActionsScreen extends StatelessWidget {
  const AllQuickActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionButton(
        icon: Icons.compare_arrows,
        label: 'Lending & Borrowing',
        color: Colors.brown,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BorrowLendScreen()),
        ),
      ),
      _ActionButton(
        icon: Icons.add_card,
        label: 'Add Borrow/Lend',
        color: Colors.amber,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddBorrowLendScreen()),
        ),
      ),
      _ActionButton(
        icon: Icons.add_circle_outline,
        label: 'Add Income',
        color: Colors.green,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddIncomeScreen()),
        ),
      ),
      _ActionButton(
        icon: Icons.remove_circle_outline,
        label: 'Add Expense',
        color: Colors.red,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddExpenseScreen()),
        ),
      ),
      _ActionButton(
        icon: Icons.savings,
        label: 'Add Deposit',
        color: Colors.purple,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddDepositScreen()),
        ),
      ),
      _ActionButton(
        icon: Icons.trending_up,
        label: 'Add Investment',
        color: Colors.blue,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddInvestmentScreen()),
        ),
      ),
      _ActionButton(
        icon: Icons.account_balance,
        label: 'Banks',
        color: Colors.teal,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BankAccountsScreen()),
        ),
      ),
      _ActionButton(
        icon: Icons.add_business,
        label: 'Add Bank',
        color: Colors.indigo,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddBankAccountScreen()),
        ),
      ),
      _ActionButton(
        icon: Icons.receipt_long,
        label: 'Investments',
        color: Colors.orange,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const InvestmentsScreen()),
        ),
      ),
      _ActionButton(
        icon: Icons.account_balance_wallet,
        label: 'Deposits',
        color: Colors.deepPurple,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const DepositsScreen()),
        ),
      ),
      // Add more actions as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Quick Actions'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: actions,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.cardColor;
    final borderColor = theme.dividerColor.withOpacity(0.18);
    final textColor = theme.textTheme.bodySmall?.color ?? Colors.black87;
    return Material(
      color: bgColor,
      elevation: 1.5,
      shadowColor: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
