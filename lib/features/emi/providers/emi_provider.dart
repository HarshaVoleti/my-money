import 'package:flutter/foundation.dart';
import 'package:my_money/core/models/emi_model.dart';
import 'package:my_money/core/services/firestore_service.dart';
import 'package:my_money/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class EmiProvider extends ChangeNotifier {

  EmiProvider({
    required FirestoreService firestoreService,
    required NotificationService notificationService,
    required String userId,
  })  : _firestoreService = firestoreService,
        _notificationService = notificationService,
        _userId = userId {
    if (_userId.isNotEmpty) {
      _listenToEmis();
    }
  }
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;
  final String _userId;

  List<EmiModel> _emis = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<EmiModel> get emis => _emis;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter EMIs
  List<EmiModel> get activeEmis =>
      _emis.where((emi) => emi.status == 'active').toList();

  List<EmiModel> get upcomingEmis {
    final now = DateTime.now();
    final upcoming = <EmiModel>[];

    for (final emi in activeEmis) {
      final nextDue = emi.nextDueDate;
      if (nextDue != null && nextDue.isAfter(now)) {
        upcoming.add(emi);
      }
    }

    upcoming.sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
    return upcoming;
  }

  List<EmiModel> get overdueEmis {
    final now = DateTime.now();
    final overdue = <EmiModel>[];

    for (final emi in activeEmis) {
      final hasOverduePayments = emi.payments.any((payment) =>
          payment.status == 'pending' && payment.dueDate.isBefore(now),);

      if (hasOverduePayments) {
        overdue.add(emi);
      }
    }

    return overdue;
  }

  // Statistics
  double get totalMonthlyEmi =>
      activeEmis.fold(0, (sum, emi) => sum + emi.amount);

  double get totalOutstandingAmount =>
      activeEmis.fold(0, (sum, emi) => sum + emi.remainingAmount);

  double get totalPaidAmount =>
      _emis.fold(0, (sum, emi) => sum + emi.totalPaid);

  void _listenToEmis() {
    _firestoreService.getUserEmis(_userId).listen(
      (emis) {
        _emis = emis;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  Future<void> addEmi({
    required String title,
    required String type,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    required String frequency,
    required int dayOfMonth,
    required double totalLoanAmount,
    required double interestRate,
    bool reminderEnabled = true,
    int reminderDaysBefore = 3,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final emiId = const Uuid().v4();

      // Generate payment schedule
      final payments = _generatePaymentSchedule(
        startDate: startDate,
        endDate: endDate,
        amount: amount,
        frequency: frequency,
        dayOfMonth: dayOfMonth,
      );

      final emi = EmiModel(
        id: emiId,
        userId: _userId,
        title: title,
        type: type,
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        frequency: frequency,
        dayOfMonth: dayOfMonth,
        totalLoanAmount: totalLoanAmount,
        interestRate: interestRate,
        status: 'active',
        payments: payments,
        reminderEnabled: reminderEnabled,
        reminderDaysBefore: reminderDaysBefore,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addEmi(emi);

      // Schedule reminders for upcoming payments
      if (reminderEnabled) {
        await _scheduleEmiReminders(emi);
      }
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEmi(EmiModel emi) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.updateEmi(emi);
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markPaymentAsPaid({
    required String emiId,
    required String paymentId,
    double? paidAmount,
    DateTime? paidDate,
  }) async {
    try {
      final emi = _emis.firstWhere((e) => e.id == emiId);
      final paymentIndex = emi.payments.indexWhere((p) => p.id == paymentId);

      if (paymentIndex == -1) return;

      final updatedPayment = emi.payments[paymentIndex].copyWith(
        status: 'paid',
        paidDate: paidDate ?? DateTime.now(),
        paidAmount: paidAmount ?? emi.payments[paymentIndex].amount,
      );

      final updatedPayments = List<EmiPayment>.from(emi.payments);
      updatedPayments[paymentIndex] = updatedPayment;

      final updatedEmi = emi.copyWith(
        payments: updatedPayments,
        updatedAt: DateTime.now(),
      );

      await updateEmi(updatedEmi);
    } on Exception catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteEmi(String emiId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.deleteEmi(emiId);

      // Cancel any associated reminders
      await _notificationService.cancelNotification(emiId.hashCode);
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  List<EmiPayment> _generatePaymentSchedule({
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
    required String frequency,
    required int dayOfMonth,
  }) {
    final payments = <EmiPayment>[];
    var currentDate =
        DateTime(startDate.year, startDate.month, dayOfMonth);

    // Adjust if the day is invalid for the month
    if (currentDate.day != dayOfMonth) {
      currentDate =
          DateTime(startDate.year, startDate.month + 1, 0); // Last day of month
    }

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      payments.add(
        EmiPayment(
          id: const Uuid().v4(),
          dueDate: currentDate,
          amount: amount,
          status: 'pending',
        ),
      );

      // Move to next payment date based on frequency
      switch (frequency) {
        case 'Monthly':
          currentDate =
              DateTime(currentDate.year, currentDate.month + 1, dayOfMonth);
        case 'Quarterly':
          currentDate =
              DateTime(currentDate.year, currentDate.month + 3, dayOfMonth);
        case 'Yearly':
          currentDate =
              DateTime(currentDate.year + 1, currentDate.month, dayOfMonth);
        default:
          currentDate =
              DateTime(currentDate.year, currentDate.month + 1, dayOfMonth);
      }

      // Adjust if the day is invalid for the month
      if (currentDate.day != dayOfMonth) {
        currentDate = DateTime(currentDate.year, currentDate.month + 1, 0);
      }
    }

    return payments;
  }

  Future<void> _scheduleEmiReminders(EmiModel emi) async {
    if (!emi.reminderEnabled) return;

    for (final payment in emi.payments) {
      if (payment.status == 'pending' &&
          payment.dueDate.isAfter(DateTime.now())) {
        await _notificationService.scheduleEmiReminder(
          emiId: emi.id,
          title: emi.title,
          dueDate: payment.dueDate,
          daysBefore: emi.reminderDaysBefore,
          amount: payment.amount,
        );
      }
    }
  }

  // Get EMIs by type
  List<EmiModel> getEmisByType(String type) => _emis.where((emi) => emi.type == type).toList();

  // Get upcoming payments for next N days
  List<Map<String, dynamic>> getUpcomingPayments(int days) {
    final now = DateTime.now();
    final cutoffDate = now.add(Duration(days: days));
    final upcomingPayments = <Map<String, dynamic>>[];

    for (final emi in activeEmis) {
      for (final payment in emi.payments) {
        if (payment.status == 'pending' &&
            payment.dueDate.isAfter(now) &&
            payment.dueDate.isBefore(cutoffDate)) {
          upcomingPayments.add({
            'emi': emi,
            'payment': payment,
            'daysLeft': payment.dueDate.difference(now).inDays,
          });
        }
      }
    }

    upcomingPayments.sort((a, b) => 
        (a['payment'] as EmiPayment).dueDate.compareTo(
            (b['payment'] as EmiPayment).dueDate));
    return upcomingPayments;
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
