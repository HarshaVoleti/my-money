import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';
import '../enums/label_enums.dart';
import '../exceptions/app_exceptions.dart';
import '../models/borrow_lend_model.dart';
import '../models/emi_model.dart';
import '../models/investment_model.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TRANSACTIONS CRUD OPERATIONS

  // Add transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transaction.id)
          .set(transaction.toMap());
    } on Exception catch (e) {
      throw FirestoreException('Error adding transaction: $e');
    }
  }

  // Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transaction.id)
          .update(transaction.copyWith(updatedAt: DateTime.now()).toMap());
    } on Exception catch (e) {
      throw FirestoreException('Error updating transaction: $e');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId)
          .delete();
    } on Exception catch (e) {
      throw FirestoreException('Error deleting transaction: $e');
    }
  }

  // Get user transactions stream
  Stream<List<TransactionModel>> getUserTransactions(String userId) => _firestore
        .collection(AppConstants.transactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(TransactionModel.fromDocument)
            .toList(),);

  // Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map(TransactionModel.fromDocument)
          .toList();
    } on Exception catch (e) {
      throw FirestoreException('Error fetching transactions: $e');
    }
  }

  // INVESTMENTS CRUD OPERATIONS

  // Add investment
  Future<void> addInvestment(InvestmentModel investment) async {
    try {
      await _firestore
          .collection(AppConstants.investmentsCollection)
          .doc(investment.id)
          .set(investment.toMap());
    } on Exception catch (e) {
      throw FirestoreException('Error adding investment: $e');
    }
  }

  // Update investment
  Future<void> updateInvestment(InvestmentModel investment) async {
    try {
      await _firestore
          .collection(AppConstants.investmentsCollection)
          .doc(investment.id)
          .update(investment.copyWith(updatedAt: DateTime.now()).toMap());
    } on Exception catch (e) {
      throw FirestoreException('Error updating investment: $e');
    }
  }

  // Delete investment
  Future<void> deleteInvestment(String investmentId) async {
    try {
      await _firestore
          .collection(AppConstants.investmentsCollection)
          .doc(investmentId)
          .delete();
    } on Exception catch (e) {
      throw FirestoreException('Error deleting investment: $e');
    }
  }

  // Get user investments stream
  Stream<List<InvestmentModel>> getUserInvestments(String userId) => _firestore
        .collection(AppConstants.investmentsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(InvestmentModel.fromDocument)
            .toList(),);

  // BORROW/LEND CRUD OPERATIONS

  // Add borrow/lend record
  Future<void> addBorrowLend(BorrowLendModel borrowLend) async {
    try {
      await _firestore
          .collection(AppConstants.borrowLendCollection)
          .doc(borrowLend.id)
          .set(borrowLend.toMap());
    } on Exception catch (e) {
      throw FirestoreException('Error adding borrow/lend record: $e');
    }
  }

  // Update borrow/lend record
  Future<void> updateBorrowLend(BorrowLendModel borrowLend) async {
    try {
      await _firestore
          .collection(AppConstants.borrowLendCollection)
          .doc(borrowLend.id)
          .update(borrowLend.copyWith(updatedAt: DateTime.now()).toMap());
    } on Exception catch (e) {
      throw FirestoreException('Error updating borrow/lend record: $e');
    }
  }

  // Delete borrow/lend record
  Future<void> deleteBorrowLend(String borrowLendId) async {
    try {
      await _firestore
          .collection(AppConstants.borrowLendCollection)
          .doc(borrowLendId)
          .delete();
    } on Exception catch (e) {
      throw FirestoreException('Error deleting borrow/lend record: $e');
    }
  }

  // Get user borrow/lend records stream
  Stream<List<BorrowLendModel>> getUserBorrowLend(String userId) => _firestore
        .collection(AppConstants.borrowLendCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(BorrowLendModel.fromDocument)
            .toList(),);

  // EMI CRUD OPERATIONS

  // Add EMI
  Future<void> addEmi(EmiModel emi) async {
    try {
      await _firestore
          .collection(AppConstants.emissCollection)
          .doc(emi.id)
          .set(emi.toMap());
    } on Exception catch (e) {
      throw FirestoreException('Error adding EMI: $e');
    }
  }

  // Update EMI
  Future<void> updateEmi(EmiModel emi) async {
    try {
      await _firestore
          .collection(AppConstants.emissCollection)
          .doc(emi.id)
          .update(emi.copyWith(updatedAt: DateTime.now()).toMap());
    } on Exception catch (e) {
      throw FirestoreException('Error updating EMI: $e');
    }
  }

  // Delete EMI
  Future<void> deleteEmi(String emiId) async {
    try {
      await _firestore
          .collection(AppConstants.emissCollection)
          .doc(emiId)
          .delete();
    } on Exception catch (e) {
      throw FirestoreException('Error deleting EMI: $e');
    }
  }

  // Get user EMIs stream
  Stream<List<EmiModel>> getUserEmis(String userId) => _firestore
        .collection(AppConstants.emissCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(EmiModel.fromDocument).toList(),);

  // ANALYTICS HELPER METHODS

  // Get monthly transaction summary
  Future<Map<String, double>> getMonthlyTransactionSummary(
    String userId,
    int year,
    int month,
  ) async {
    try {
      final startDate = DateTime(year, month);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      final transactions = await getTransactionsByDateRange(
        userId,
        startDate,
        endDate,
      );

      var totalIncome = 0.0;
      var totalExpense = 0.0;

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpense += transaction.amount;
        }
      }

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense,
      };
    } on Exception catch (e) {
      throw FirestoreException('Error getting monthly summary: $e');
    }
  }

  // Get category-wise spending
  Future<Map<String, double>> getCategoryWiseSpending(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactions = await getTransactionsByDateRange(
        userId,
        startDate,
        endDate,
      );

      final categorySpending = <String, double>{};

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.expense) {
          categorySpending[transaction.category] =
              (categorySpending[transaction.category] ?? 0.0) +
                  transaction.amount;
        }
      }

      return categorySpending;
    } on Exception catch (e) {
      throw FirestoreException('Error getting category spending: $e');
    }
  }
}
