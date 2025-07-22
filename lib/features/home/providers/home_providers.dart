import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/investment_model.dart';
import 'package:my_money/core/models/transaction_model.dart';
import 'package:my_money/core/models/bank_account_model.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/providers/service_providers.dart';
import 'package:my_money/features/auth/providers/auth_provider.dart';
import 'package:my_money/features/investments/providers/investment_provider.dart';
import 'package:my_money/features/transactions/providers/transaction_provider.dart';
import 'package:my_money/features/bank_accounts/providers/bank_account_providers.dart';

// Home dashboard providers for real data integration

class DashboardSummary {
  final double totalBalance;
  final double bankAccountBalance;
  final double transactionBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double totalInvestments;
  final double monthlyProfit;
  final List<TransactionModel> recentTransactions;
  final List<BankAccountModel> bankAccounts;

  DashboardSummary({
    required this.totalBalance,
    required this.bankAccountBalance,
    required this.transactionBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.totalInvestments,
    required this.monthlyProfit,
    required this.recentTransactions,
    required this.bankAccounts,
  });
}

// Provider for comprehensive dashboard summary data
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final transactionState = ref.watch(transactionNotifierProvider);
  final bankAccountsAsync = ref.watch(bankAccountsStreamProvider);
  final investmentSummary = ref.watch(investmentSummaryFromStreamProvider);
  
  // Calculate bank account total balance
  final bankAccounts = await bankAccountsAsync.when(
    data: (accounts) => accounts,
    loading: () => <BankAccountModel>[],
    error: (_, __) => <BankAccountModel>[],
  );
  final bankAccountBalance = bankAccounts.fold<double>(0.0, (double sum, BankAccountModel account) => sum + account.balance);
  
  // Get transaction-based balance (income - expenses)
  final transactionBalance = transactionState.balance;
  
  // Combined total balance (bank accounts + transaction balance)
  final totalBalance = bankAccountBalance + transactionBalance;
  
  // Recent transactions
  final transactions = transactionState.transactions;
  final sortedTransactions = List<TransactionModel>.from(transactions);
  sortedTransactions.sort((a, b) => b.date.compareTo(a.date));
  final recentTransactions = sortedTransactions.take(5).toList();
  
  // Current month calculations
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 0);
  
  final monthlyTransactions = transactions.where((t) => 
    t.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
    t.date.isBefore(monthEnd.add(const Duration(days: 1)))
  ).toList();
  
  final monthlyIncome = monthlyTransactions
    .where((t) => t.type == TransactionType.income)
    .fold<double>(0.0, (sum, t) => sum + t.amount);
    
  final monthlyExpense = monthlyTransactions
    .where((t) => t.type == TransactionType.expense)
    .fold<double>(0.0, (sum, t) => sum + t.amount);

  return DashboardSummary(
    totalBalance: totalBalance,
    bankAccountBalance: bankAccountBalance,
    transactionBalance: transactionBalance,
    monthlyIncome: monthlyIncome,
    monthlyExpense: monthlyExpense,
    totalInvestments: investmentSummary['totalValue'] ?? 0.0,
    monthlyProfit: investmentSummary['profitLoss'] ?? 0.0,
    recentTransactions: recentTransactions,
    bankAccounts: bankAccounts,
  );
});

// Current month summary provider
final currentMonthSummaryProvider = FutureProvider<Map<String, double>>((ref) async {
  final user = ref.watch(authNotifierProvider).value;
  if (user == null) return {'income': 0.0, 'expense': 0.0, 'balance': 0.0};

  final now = DateTime.now();
  return ref.watch(monthlyTransactionSummaryProvider((
    year: now.year,
    month: now.month,
  )).future);
});

// Recent transactions provider (last 5 transactions)
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactionState = ref.watch(transactionNotifierProvider);
  final transactions = transactionState.transactions;
  
  // Sort by date and take the first 5
  final sortedTransactions = List<TransactionModel>.from(transactions);
  sortedTransactions.sort((a, b) => b.date.compareTo(a.date));
  
  return sortedTransactions.take(5).toList();
});

// Investment summary provider
final investmentSummaryProvider = Provider<Map<String, double>>((ref) {
  final user = ref.watch(authNotifierProvider).value;
  if (user == null) return {'totalValue': 0.0, 'totalInvestment': 0.0, 'profitLoss': 0.0, 'profitLossPercentage': 0.0};

  // Create investment provider instance
  final investmentProvider = InvestmentProvider(
    firestoreService: ref.read(firestoreServiceProvider),
    userId: user.id,
  );

  return {
    'totalValue': investmentProvider.currentValue,
    'totalInvestment': investmentProvider.totalInvestment,
    'profitLoss': investmentProvider.totalProfitLoss,
    'profitLossPercentage': investmentProvider.portfolioProfitLossPercentage,
  };
});

// Investment stream provider
final investmentStreamProvider = StreamProvider<List<InvestmentModel>>((ref) {
  final user = ref.watch(authNotifierProvider).value;
  if (user == null) return Stream.value([]);

  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getUserInvestments(user.id);
});

// Computed investment summary from stream
final investmentSummaryFromStreamProvider = Provider<Map<String, double>>((ref) {
  final investmentsAsync = ref.watch(investmentStreamProvider);
  
  return investmentsAsync.when(
    data: (investments) {
      if (investments.isEmpty) {
        return {'totalValue': 0.0, 'totalInvestment': 0.0, 'profitLoss': 0.0, 'profitLossPercentage': 0.0};
      }

      final totalInvestment = investments.fold<double>(
        0.0, (sum, inv) => sum + inv.totalInvestment,
      );
      final currentValue = investments.fold<double>(
        0.0, (sum, inv) => sum + inv.currentValue,
      );
      final profitLoss = currentValue - totalInvestment;
      final profitLossPercentage = totalInvestment > 0 ? (profitLoss / totalInvestment) * 100 : 0.0;

      return {
        'totalValue': currentValue,
        'totalInvestment': totalInvestment,
        'profitLoss': profitLoss,
        'profitLossPercentage': profitLossPercentage,
      };
    },
    loading: () => {'totalValue': 0.0, 'totalInvestment': 0.0, 'profitLoss': 0.0, 'profitLossPercentage': 0.0},
    error: (_, __) => {'totalValue': 0.0, 'totalInvestment': 0.0, 'profitLoss': 0.0, 'profitLossPercentage': 0.0},
  );
});

// Bank accounts total balance provider
final bankAccountsTotalBalanceProvider = FutureProvider<double>((ref) async {
  final bankAccountsAsync = ref.watch(bankAccountsStreamProvider);
  final bankAccounts = await bankAccountsAsync.when(
    data: (accounts) => accounts,
    loading: () => <BankAccountModel>[],
    error: (_, __) => <BankAccountModel>[],
  );
  return bankAccounts.fold<double>(0.0, (double sum, BankAccountModel account) => sum + account.balance);
});
