import 'package:flutter/foundation.dart';
import 'package:my_money/core/models/borrow_lend_model.dart';
import 'package:my_money/core/services/firestore_service.dart';
import 'package:my_money/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class BorrowLendProvider extends ChangeNotifier {

  BorrowLendProvider({
    required FirestoreService firestoreService,
    required NotificationService notificationService,
    required String userId,
  })  : _firestoreService = firestoreService,
        _notificationService = notificationService,
        _userId = userId {
    if (_userId.isNotEmpty) {
      _listenToBorrowLend();
    }
  }
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;
  final String _userId;

  List<BorrowLendModel> _borrowLendRecords = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BorrowLendModel> get borrowLendRecords => _borrowLendRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter records
  List<BorrowLendModel> get borrowedRecords =>
      _borrowLendRecords.where((record) => record.type == 'borrowed').toList();

  List<BorrowLendModel> get lentRecords =>
      _borrowLendRecords.where((record) => record.type == 'lent').toList();

  List<BorrowLendModel> get pendingRecords =>
      _borrowLendRecords.where((record) => record.status == 'pending').toList();

  List<BorrowLendModel> get overdueRecords =>
      _borrowLendRecords.where((record) => record.isOverdue).toList();

  // Statistics
  double get totalBorrowedAmount => borrowedRecords
      .where((record) => record.status == 'pending')
      .fold(0, (sum, record) => sum + record.pendingAmount);

  double get totalLentAmount => lentRecords
      .where((record) => record.status == 'pending')
      .fold(0, (sum, record) => sum + record.pendingAmount);

  double get netPosition => totalLentAmount - totalBorrowedAmount;

  void _listenToBorrowLend() {
    _firestoreService.getUserBorrowLend(_userId).listen(
      (records) {
        _borrowLendRecords = records;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  Future<void> addBorrowLendRecord({
    required double amount,
    required String type,
    required String personName,
    required String description, String? personContact,
    DateTime? date,
    DateTime? dueDate,
    bool setReminder = true,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final record = BorrowLendModel(
        id: const Uuid().v4(),
        userId: _userId,
        amount: amount,
        type: type,
        personName: personName,
        personContact: personContact,
        description: description,
        date: date ?? DateTime.now(),
        dueDate: dueDate,
        status: 'pending',
        reminderDates: [],
        createdAt: DateTime.now(),
      );

      await _firestoreService.addBorrowLend(record);

      // Schedule reminder if due date is set and reminder is enabled
      if (setReminder && dueDate != null) {
        await _scheduleBorrowLendReminder(record);
      }
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBorrowLendRecord(BorrowLendModel record) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.updateBorrowLend(record);
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsReturned({
    required String recordId,
    required double returnedAmount,
    DateTime? returnedDate,
  }) async {
    try {
      final record = _borrowLendRecords.firstWhere((r) => r.id == recordId);
      final updatedRecord = record.copyWith(
        returnedAmount: (record.returnedAmount ?? 0.0) + returnedAmount,
        returnedDate: returnedDate ?? DateTime.now(),
        status: (record.returnedAmount ?? 0.0) + returnedAmount >= record.amount
            ? 'completed'
            : 'pending',
        updatedAt: DateTime.now(),
      );

      await updateBorrowLendRecord(updatedRecord);

      // Cancel reminder if fully returned
      if (updatedRecord.status == 'completed') {
        await _notificationService.cancelNotification(recordId.hashCode);
      }
    } on Exception catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteBorrowLendRecord(String recordId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.deleteBorrowLend(recordId);

      // Cancel any associated reminders
      await _notificationService.cancelNotification(recordId.hashCode);
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _scheduleBorrowLendReminder(BorrowLendModel record) async {
    if (record.dueDate == null) return;

    await _notificationService.scheduleBorrowLendReminder(
      borrowLendId: record.id,
      personName: record.personName,
      type: record.type,
      dueDate: record.dueDate!,
      amount: record.pendingAmount,
    );
  }

  // Get records by person
  List<BorrowLendModel> getRecordsByPerson(String personName) => _borrowLendRecords
        .where((record) =>
            record.personName.toLowerCase().contains(personName.toLowerCase()),)
        .toList();

  // Get records by status
  List<BorrowLendModel> getRecordsByStatus(String status) => _borrowLendRecords
        .where((record) => record.status == status)
        .toList();

  // Get records by date range
  List<BorrowLendModel> getRecordsByDateRange(
      DateTime startDate, DateTime endDate,) => _borrowLendRecords
        .where((record) =>
            record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            record.date.isBefore(endDate.add(const Duration(days: 1))),)
        .toList();

  // Get top borrowers/lenders
  Map<String, Map<String, dynamic>> getTopPersons() {
    final personTotals = <String, Map<String, dynamic>>{};

    for (final record in _borrowLendRecords) {
      if (!personTotals.containsKey(record.personName)) {
        personTotals[record.personName] = {
          'totalBorrowed': 0.0,
          'totalLent': 0.0,
          'pendingBorrowed': 0.0,
          'pendingLent': 0.0,
          'recordCount': 0,
        };
      }

      final personData = personTotals[record.personName]!;
      personData['recordCount']++;

      if (record.type == 'borrowed') {
        personData['totalBorrowed'] += record.amount;
        if (record.status == 'pending') {
          personData['pendingBorrowed'] += record.pendingAmount;
        }
      } else {
        personData['totalLent'] += record.amount;
        if (record.status == 'pending') {
          personData['pendingLent'] += record.pendingAmount;
        }
      }
    }

    return personTotals;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
