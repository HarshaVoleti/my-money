import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/transaction_model.dart';
import 'package:my_money/core/providers/service_providers.dart';
import 'package:my_money/features/auth/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

// Transaction state class
@immutable
class TransactionState {

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) => TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );

  // Filtered transactions
  List<TransactionModel> get incomeTransactions =>
      transactions.where((t) => t.type == TransactionType.income).toList();

  List<TransactionModel> get expenseTransactions =>
      transactions.where((t) => t.type == TransactionType.expense).toList();

  // Statistics
  double get totalIncome => incomeTransactions.fold(
      0, (sum, transaction) => sum + transaction.amount,);

  double get totalExpense => expenseTransactions.fold(
      0, (sum, transaction) => sum + transaction.amount,);

  double get balance => totalIncome - totalExpense;
}

// Transaction notifier
class TransactionNotifier extends StateNotifier<TransactionState> {

  TransactionNotifier(this.ref) : super(const TransactionState()) {
    _init();
  }
  final Ref ref;

  void _init() {
    // Watch for auth changes and listen to transactions when user is available
    ref.listen(authNotifierProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          _listenToTransactions(user.id);
        } else {
          state = const TransactionState(); // Reset state when user logs out
        }
      });
    });

    // Initial setup if user is already authenticated
    final authState = ref.read(authNotifierProvider);
    authState.whenData((user) {
      if (user != null) {
        _listenToTransactions(user.id);
      }
    });
  }

  void _listenToTransactions(String userId) {
    final firestoreService = ref.read(firestoreServiceProvider);

    firestoreService.getUserTransactions(userId).listen(
      (transactions) {
        state = state.copyWith(
          transactions: transactions,
        );
      },
      onError: (Object error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required String category,
    required String description,
    required String paymentMethod,
    String? accountName,
    List<String>? tags,
    List<String>? labelIds,
    DateTime? date,
  }) async {
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) return;

    try {
      state = state.copyWith(isLoading: true);

      final transaction = TransactionModel(
        id: const Uuid().v4(),
        userId: userId,
        amount: amount,
        type: type,
        category: category,
        description: description,
        paymentMethod: paymentMethod,
        accountName: accountName,
        tags: tags ?? [],
        labelIds: labelIds ?? [],
        date: date ?? DateTime.now(),
        createdAt: DateTime.now(),
      );

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.addTransaction(transaction);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      state = state.copyWith(isLoading: true);

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateTransaction(transaction);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      state = state.copyWith(isLoading: true);

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteTransaction(transactionId);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith();
  }
}

// Transaction provider
final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(TransactionNotifier.new);

// Helper providers for filtered data
final transactionsByCategoryProvider =
    Provider.family<List<TransactionModel>, String>((ref, category) {
  final transactions = ref.watch(transactionNotifierProvider).transactions;
  return transactions.where((t) => t.category == category).toList();
});

final transactionsByDateRangeProvider = Provider.family<List<TransactionModel>,
    ({DateTime startDate, DateTime endDate})>((ref, params) {
  final transactions = ref.watch(transactionNotifierProvider).transactions;
  return transactions
      .where((t) =>
          t.date.isAfter(params.startDate.subtract(const Duration(days: 1))) &&
          t.date.isBefore(params.endDate.add(const Duration(days: 1))),)
      .toList();
});

final categoryTotalsProvider =
    Provider.family<Map<String, double>, TransactionType>((ref, type) {
  final transactions = ref.watch(transactionNotifierProvider).transactions;
  final filteredTransactions = transactions.where((t) => t.type == type);
  final categoryTotals = <String, double>{};

  for (final transaction in filteredTransactions) {
    categoryTotals[transaction.category] =
        (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
  }

  return categoryTotals;
});

// Async providers for Firestore operations
final transactionsByDateRangeAsyncProvider = FutureProvider.family<
    List<TransactionModel>,
    ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final userId = ref.watch(authNotifierProvider).value?.id;
  if (userId == null) return [];

  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getTransactionsByDateRange(
    userId,
    params.startDate,
    params.endDate,
  );
});

final monthlyTransactionSummaryProvider =
    FutureProvider.family<Map<String, double>, ({int year, int month})>(
        (ref, params) async {
  final userId = ref.watch(authNotifierProvider).value?.id;
  if (userId == null) return {'income': 0.0, 'expense': 0.0, 'balance': 0.0};

  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getMonthlyTransactionSummary(
    userId,
    params.year,
    params.month,
  );
});

final categoryWiseSpendingProvider = FutureProvider.family<Map<String, double>,
    ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final userId = ref.watch(authNotifierProvider).value?.id;
  if (userId == null) return {};

  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getCategoryWiseSpending(
    userId,
    params.startDate,
    params.endDate,
  );
});
