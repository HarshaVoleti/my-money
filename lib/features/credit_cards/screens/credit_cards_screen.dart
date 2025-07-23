import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/bank_account_model.dart';
import 'package:my_money/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:my_money/features/bank_accounts/screens/add_bank_account_screen.dart';
import 'package:my_money/features/credit_cards/screens/credit_card_overview_screen.dart';

class CreditCardsScreen extends ConsumerWidget {
  const CreditCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditCardsAsync = ref.watch(bankAccountsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Cards'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Credit Card',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AddBankAccountScreen(
                    // Optionally, you can pass a flag to preselect credit card type
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: creditCardsAsync.when(
        data: (accounts) {
          final creditCards = accounts.where((a) => a.type == AccountType.creditCard).toList();
          if (creditCards.isEmpty) {
            return const _EmptyCreditCardState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: creditCards.length,
            itemBuilder: (context, index) {
              final card = creditCards[index];
              return _CreditCardTile(
                card: card,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreditCardOverviewScreen(card: card),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('Error loading credit cards', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SelectableText(error.toString(), style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(bankAccountsStreamProvider),
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
              builder: (context) => const AddBankAccountScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Credit Card',
      ),
    );
  }
}

class _CreditCardTile extends StatelessWidget {
  final BankAccountModel card;
  final VoidCallback? onTap;
  const _CreditCardTile({required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardBgColor = Color(card.color.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardBgColor.withOpacity(0.95),
              cardBgColor.withOpacity(0.7),
              cardBgColor.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardBgColor.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Icon(Icons.credit_card, size: 100, color: Colors.white.withOpacity(0.08)),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.white.withOpacity(0.85), size: 28),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        tooltip: 'Edit Credit Card',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => AddBankAccountScreen(account: card),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.bankName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    card.maskedAccountNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (card.expiryDate != null && card.expiryDate!.isNotEmpty)
                        Text(
                          'Exp: ${card.expiryDate}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      const Spacer(),
                      if (card.creditLimit != null)
                        Text(
                          'Limit: ₹${card.creditLimit!.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, size: 18, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        '₹${card.balance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      if (card.creditLimit != null)
                        Text(
                          'Used: ₹${((card.creditLimit ?? 0) - card.balance).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCreditCardState extends StatelessWidget {
  const _EmptyCreditCardState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card, size: 96, color: Colors.deepPurple),
            const SizedBox(height: 24),
            Text(
              'No Credit Cards Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Text(
              'Add your credit cards to easily track your spending, limits, and payments.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const AddBankAccountScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Credit Card'),
            ),
          ],
        ),
      ),
    );
  }
}
