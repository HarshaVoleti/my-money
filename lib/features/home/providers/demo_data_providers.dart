// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:my_money/core/models/transaction_model.dart';
// import 'package:my_money/core/models/investment_model.dart';

// /// Demo data providers for testing dashboard without real user data
// /// This is useful for development and demonstration purposes

// // Demo transactions
// final demoTransactionsProvider = Provider<List<TransactionModel>>((ref) {
//   return [
//     // TransactionModel(
//     //   id: 'demo1',
//     //   userId: 'demo_user',
//     //   amount: 5000.0,
//     //   type: 'income',
//     //   category: 'Salary',
//     //   description: 'Monthly salary payment',
//     //   paymentMethod: 'Bank Transfer',
//     //   tags: ['salary', 'monthly'],
//     //   date: DateTime.now().subtract(const Duration(days: 1)),
//     //   createdAt: DateTime.now().subtract(const Duration(days: 1)),
//     // ),
//     // TransactionModel(
//     //   id: 'demo2',
//     //   userId: 'demo_user',
//     //   amount: 150.75,
//     //   type: 'expense',
//     //   category: 'Groceries',
//     //   description: 'Weekly grocery shopping',
//     //   paymentMethod: 'Credit Card',
//     //   tags: ['food', 'weekly'],
//     //   date: DateTime.now().subtract(const Duration(days: 2)),
//     //   createdAt: DateTime.now().subtract(const Duration(days: 2)),
//     // ),
//     // TransactionModel(
//     //   id: 'demo3',
//     //   userId: 'demo_user',
//     //   amount: 2500.0,
//     //   type: 'income',
//     //   category: 'Freelance',
//     //   description: 'Client project payment',
//     //   paymentMethod: 'PayPal',
//     //   tags: ['freelance', 'project'],
//     //   date: DateTime.now().subtract(const Duration(days: 3)),
//     //   createdAt: DateTime.now().subtract(const Duration(days: 3)),
//     // ),
//     // TransactionModel(
//     //   id: 'demo4',
//     //   userId: 'demo_user',
//     //   amount: 89.99,
//     //   type: 'expense',
//     //   category: 'Entertainment',
//     //   description: 'Movie tickets and dinner',
//     //   paymentMethod: 'Debit Card',
//     //   tags: ['entertainment', 'date'],
//     //   date: DateTime.now().subtract(const Duration(days: 4)),
//     //   createdAt: DateTime.now().subtract(const Duration(days: 4)),
//     // ),
//     // TransactionModel(
//     //   id: 'demo5',
//     //   userId: 'demo_user',
//     //   amount: 45.20,
//     //   type: 'expense',
//     //   category: 'Transportation',
//     //   description: 'Uber rides',
//     //   paymentMethod: 'Credit Card',
//     //   tags: ['transport', 'uber'],
//     //   date: DateTime.now().subtract(const Duration(days: 5)),
//     //   createdAt: DateTime.now().subtract(const Duration(days: 5)),
//     // ),
//   ];
// });

// // Demo investments
// final demoInvestmentsProvider = Provider<List<InvestmentModel>>((ref) {
//   return [
//     InvestmentModel(
//       id: 'inv1',
//       userId: 'demo_user',
//       stockName: 'Apple Inc.',
//       stockSymbol: 'AAPL',
//       purchasePrice: 150.00,
//       quantity: 10,
//       currentPrice: 175.50,
//       purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
//       platform: 'Robinhood',
//       sector: 'Technology',
//       status: 'active',
//       createdAt: DateTime.now().subtract(const Duration(days: 30)),
//     ),
//     InvestmentModel(
//       id: 'inv2',
//       userId: 'demo_user',
//       stockName: 'Tesla, Inc.',
//       stockSymbol: 'TSLA',
//       purchasePrice: 800.00,
//       quantity: 5,
//       currentPrice: 750.25,
//       purchaseDate: DateTime.now().subtract(const Duration(days: 60)),
//       platform: 'E*TRADE',
//       sector: 'Automotive',
//       status: 'active',
//       createdAt: DateTime.now().subtract(const Duration(days: 60)),
//     ),
//     InvestmentModel(
//       id: 'inv3',
//       userId: 'demo_user',
//       stockName: 'Microsoft Corporation',
//       stockSymbol: 'MSFT',
//       purchasePrice: 300.00,
//       quantity: 8,
//       currentPrice: 335.75,
//       purchaseDate: DateTime.now().subtract(const Duration(days: 45)),
//       platform: 'Fidelity',
//       sector: 'Technology',
//       status: 'active',
//       createdAt: DateTime.now().subtract(const Duration(days: 45)),
//     ),
//   ];
// });

// // Demo dashboard summary
// final demoDashboardSummaryProvider = Provider<Map<String, double>>((ref) {
//   final transactions = ref.watch(demoTransactionsProvider);
  
//   double totalIncome = 0;
//   double totalExpense = 0;
  
//   for (final transaction in transactions) {
//     if (transaction.type == 'income') {
//       totalIncome += transaction.amount;
//     } else {
//       totalExpense += transaction.amount;
//     }
//   }
  
//   return {
//     'totalBalance': totalIncome - totalExpense,
//     'totalIncome': totalIncome,
//     'totalExpense': totalExpense,
//   };
// });

// // Demo investment summary
// final demoInvestmentSummaryProvider = Provider<Map<String, double>>((ref) {
//   final investments = ref.watch(demoInvestmentsProvider);
  
//   double totalInvestment = 0;
//   double currentValue = 0;
  
//   for (final investment in investments) {
//     totalInvestment += investment.totalInvestment;
//     currentValue += investment.currentValue;
//   }
  
//   final profitLoss = currentValue - totalInvestment;
//   final profitLossPercentage = totalInvestment > 0 ? (profitLoss / totalInvestment) * 100 : 0.0;
  
//   return {
//     'totalValue': currentValue,
//     'totalInvestment': totalInvestment,
//     'profitLoss': profitLoss,
//     'profitLossPercentage': profitLossPercentage,
//   };
// });

// // Recent demo transactions (last 3)
// final demoRecentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
//   final transactions = ref.watch(demoTransactionsProvider);
//   final sortedTransactions = List<TransactionModel>.from(transactions);
//   sortedTransactions.sort((a, b) => b.date.compareTo(a.date));
//   return sortedTransactions.take(3).toList();
// });
