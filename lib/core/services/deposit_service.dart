import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_money/core/enums/investment_enums.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/deposit_model.dart';

class DepositService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _depositsCollection = 'deposits';

  /// Create a new deposit
  Future<String> createDeposit({
    required String name,
    required String description,
    required DepositType type,
    required double principalAmount,
    required double interestRate,
    required DateTime startDate,
    required DateTime maturityDate,
    required String bankName,
    int? tenureMonths,
    double? monthlyInstallment,
    String? accountNumber,
    String? certificateNumber,
    LabelColor color = LabelColor.blue,
    bool autoRenewal = false,
    List<String> tags = const [],
  }) async {
    try {
      final deposit = DepositModel(
        id: '', // Will be set by Firestore
        name: name,
        description: description,
        type: type,
        principalAmount: principalAmount,
        currentValue: principalAmount,
        interestRate: interestRate,
        startDate: startDate,
        maturityDate: maturityDate,
        tenureMonths: tenureMonths,
        monthlyInstallment: monthlyInstallment,
        bankName: bankName,
        accountNumber: accountNumber,
        certificateNumber: certificateNumber,
        status: DepositStatus.active,
        color: color,
        autoRenewal: autoRenewal,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_depositsCollection)
          .add(deposit.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create deposit: $e');
    }
  }

  /// Get all deposits
  Future<List<DepositModel>> getDeposits() async {
    try {
      final querySnapshot = await _firestore
          .collection(_depositsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DepositModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get deposits: $e');
    }
  }

  /// Get deposit by ID
  Future<DepositModel?> getDepositById(String depositId) async {
    try {
      final doc = await _firestore
          .collection(_depositsCollection)
          .doc(depositId)
          .get();

      if (doc.exists) {
        return DepositModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get deposit: $e');
    }
  }

  /// Update deposit
  Future<void> updateDeposit(DepositModel deposit) async {
    try {
      final updatedDeposit = deposit.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_depositsCollection)
          .doc(deposit.id)
          .update(updatedDeposit.toMap());
    } catch (e) {
      throw Exception('Failed to update deposit: $e');
    }
  }

  /// Update deposit current value
  Future<void> updateCurrentValue(String depositId, double currentValue) async {
    try {
      await _firestore
          .collection(_depositsCollection)
          .doc(depositId)
          .update({
        'currentValue': currentValue,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update deposit value: $e');
    }
  }

  /// Close deposit (premature or matured)
  Future<void> closeDeposit(String depositId, {bool isPremature = false}) async {
    try {
      await _firestore
          .collection(_depositsCollection)
          .doc(depositId)
          .update({
        'status': isPremature 
            ? DepositStatus.prematureClosed.name 
            : DepositStatus.matured.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to close deposit: $e');
    }
  }

  /// Delete deposit
  Future<void> deleteDeposit(String depositId) async {
    try {
      await _firestore
          .collection(_depositsCollection)
          .doc(depositId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete deposit: $e');
    }
  }

  /// Stream deposits
  Stream<List<DepositModel>> streamDeposits() {
    return _firestore
        .collection(_depositsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DepositModel.fromDocument(doc))
            .toList());
  }

  /// Get deposits by type
  Future<List<DepositModel>> getDepositsByType(DepositType type) async {
    try {
      final querySnapshot = await _firestore
          .collection(_depositsCollection)
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DepositModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get deposits by type: $e');
    }
  }

  /// Get maturing deposits (within next 30 days)
  Future<List<DepositModel>> getMaturingDeposits({int days = 30}) async {
    try {
      final futureDate = DateTime.now().add(Duration(days: days));
      
      final querySnapshot = await _firestore
          .collection(_depositsCollection)
          .where('status', isEqualTo: DepositStatus.active.name)
          .get();

      final deposits = querySnapshot.docs
          .map((doc) => DepositModel.fromDocument(doc))
          .where((deposit) => 
              deposit.maturityDate.isBefore(futureDate) &&
              deposit.maturityDate.isAfter(DateTime.now()))
          .toList();

      deposits.sort((a, b) => a.maturityDate.compareTo(b.maturityDate));
      return deposits;
    } catch (e) {
      throw Exception('Failed to get maturing deposits: $e');
    }
  }

  /// Get deposit statistics
  Future<Map<String, dynamic>> getDepositStats() async {
    try {
      final querySnapshot = await _firestore
          .collection(_depositsCollection)
          .get();

      final deposits = querySnapshot.docs
          .map((doc) => DepositModel.fromDocument(doc))
          .toList();

      double totalPrincipal = 0;
      double totalCurrentValue = 0;
      double totalExpectedMaturity = 0;
      int activeCount = 0;
      int maturedCount = 0;

      for (final deposit in deposits) {
        totalPrincipal += deposit.principalAmount;
        totalCurrentValue += deposit.currentValue;
        totalExpectedMaturity += deposit.expectedMaturityAmount;
        
        if (deposit.status == DepositStatus.active) {
          activeCount++;
        } else if (deposit.status == DepositStatus.matured) {
          maturedCount++;
        }
      }

      return {
        'totalDeposits': deposits.length,
        'activeDeposits': activeCount,
        'maturedDeposits': maturedCount,
        'totalPrincipal': totalPrincipal,
        'totalCurrentValue': totalCurrentValue,
        'totalExpectedMaturity': totalExpectedMaturity,
        'totalInterest': totalExpectedMaturity - totalPrincipal,
      };
    } catch (e) {
      throw Exception('Failed to get deposit statistics: $e');
    }
  }
}
