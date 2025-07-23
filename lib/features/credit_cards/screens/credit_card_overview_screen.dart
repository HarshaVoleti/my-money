import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/bank_account_model.dart';
import 'package:my_money/core/models/transaction_model.dart';
import 'package:my_money/features/transactions/providers/transaction_provider.dart';


class CreditCardOverviewScreen extends ConsumerStatefulWidget {
  final BankAccountModel card;
  const CreditCardOverviewScreen({super.key, required this.card});

  @override
  ConsumerState<CreditCardOverviewScreen> createState() => _CreditCardOverviewScreenState();
}

class _CreditCardOverviewScreenState extends ConsumerState<CreditCardOverviewScreen> with SingleTickerProviderStateMixin {
  bool isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
      if (isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final double used = (card.creditLimit ?? 0) - (card.balance);
    final double left = (card.creditLimit ?? 0) - used;
    final double percentUsed = (card.creditLimit ?? 0) > 0 ? (used / (card.creditLimit ?? 1)) : 0;
    final cardBgColor = Color(card.color.colorValue);

    final List<TransactionModel> transactions = ref.watch(transactionNotifierProvider).transactions
        .where((TransactionModel t) => t.accountName == card.name)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final isBack = _animation.value > 0.5;
                    final angle = _animation.value * pi;
                    Widget cardWidget;
                    if (!isBack) {
                      cardWidget = _buildCardFront(context, cardBgColor, card);
                    } else {
                      cardWidget = Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _buildCardBack(context, cardBgColor, card),
                      );
                    }
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: cardWidget,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text('Tap card to flip and view sensitive info', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Text('Utilization', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: used,
                        color: Colors.redAccent,
                        title: 'Used',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        value: left,
                        color: Colors.green,
                        title: 'Left',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('Used', style: Theme.of(context).textTheme.bodyMedium),
                      Text('₹${used.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Left', style: Theme.of(context).textTheme.bodyMedium),
                      Text('₹${left.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Utilization', style: Theme.of(context).textTheme.bodyMedium),
                      Text('${(percentUsed * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Recent transactions for this card
              if (transactions.isNotEmpty) ...[
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    itemCount: transactions.length > 5 ? 5 : transactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final tx = transactions[idx];
                      final isIncome = tx.type.value == 'income';
                      return ListTile(
                        leading: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.redAccent,
                        ),
                        title: Text(
                          tx.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${tx.category} • ${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Text(
                          (isIncome ? '+' : '-') + '₹${tx.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isIncome ? Colors.green : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Text('No transactions for this card yet.', style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _maskAccountNumber(String number) {
    if (number.length <= 4) return number;
    return '*' * (number.length - 4) + number.substring(number.length - 4);
  }

  String _maskCVV(String? cvv) {
    if (cvv == null || cvv.isEmpty) return '';
    return '*' * cvv.length;
  }

  String _maskExpiry(String? expiry) {
    if (expiry == null || expiry.isEmpty) return '';
    return '**/**';
  }

  Widget _buildCardFront(BuildContext context, Color cardBgColor, BankAccountModel card) => Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                  _maskAccountNumber(card.accountNumber),
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
                        'Exp: ${_maskExpiry(card.expiryDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    const Spacer(),
                    if (card.cvv != null && card.cvv!.isNotEmpty)
                      Text(
                        'CVV: ${_maskCVV(card.cvv)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    if (card.creditLimit != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          'Limit: ₹${card.creditLimit!.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
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
                if (card.billingDate != null)
                  const SizedBox(height: 12),
                if (card.billingDate != null)
                  Row(
                    children: [
                      Text('Billing Date:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      const SizedBox(width: 8),
                      Text(card.billingDate is DateTime ? '${card.billingDate?.day.toString().padLeft(2, '0')}/${card.billingDate?.month.toString().padLeft(2, '0')}' : card.billingDate.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildCardBack(BuildContext context, Color cardBgColor, BankAccountModel card) => Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                    Icon(Icons.lock, color: Colors.white.withOpacity(0.85), size: 28),
                    const Spacer(),
                    Text('Sensitive Info', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
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
                  card.accountNumber,
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
                    if (card.cvv != null && card.cvv!.isNotEmpty)
                      Text(
                        'CVV: ${card.cvv}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    if (card.creditLimit != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          'Limit: ₹${card.creditLimit!.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
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
                if (card.billingDate != null)
                  const SizedBox(height: 12),
                if (card.billingDate != null)
                  Row(
                    children: [
                      Text('Billing Date:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      const SizedBox(width: 8),
                      Text(card.billingDate is DateTime ? '${card.billingDate?.day.toString().padLeft(2, '0')}/${card.billingDate?.month.toString().padLeft(2, '0')}' : card.billingDate.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
}
