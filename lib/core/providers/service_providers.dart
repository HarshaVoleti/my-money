import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/services/auth_service.dart';
import 'package:my_money/core/services/bank_account_service.dart';
import 'package:my_money/core/services/bill_attachment_service.dart';
import 'package:my_money/core/services/deposit_service.dart';
import 'package:my_money/core/services/firestore_service.dart';
import 'package:my_money/core/services/label_service.dart';
import 'package:my_money/core/services/notification_service.dart';

// Service Providers for dependency injection

// Authentication Service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firestore Service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Label Service
final labelServiceProvider = Provider<LabelService>((ref) {
  return LabelService();
});

// Bank Account Service
final bankAccountServiceProvider = Provider<BankAccountService>((ref) {
  return BankAccountService();
});

// Bill Attachment Service
final billAttachmentServiceProvider = Provider<BillAttachmentService>((ref) {
  return BillAttachmentService();
});

// Deposit Service
final depositServiceProvider = Provider<DepositService>((ref) {
  return DepositService();
});

// Notification Service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
