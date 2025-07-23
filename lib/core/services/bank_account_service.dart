import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/exceptions/app_exceptions.dart';
import 'package:my_money/core/models/bank_account_model.dart';

class BankAccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'bank_accounts';

  // Get bank accounts for a specific user
  Stream<List<BankAccountModel>> getBankAccountsStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('isDefault', descending: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => BankAccountModel.fromDocument(doc)).toList());
  }

  // Get bank accounts (Future version)
  Future<List<BankAccountModel>> getBankAccounts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('isDefault', descending: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => BankAccountModel.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching bank accounts: $e');
      throw FirestoreException('Error fetching bank accounts: $e');
    }
  }

  // Get bank account by ID
  Future<BankAccountModel?> getBankAccountById(String accountId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(accountId).get();
      
      if (doc.exists) {
        return BankAccountModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Error fetching bank account: $e');
    }
  }

  // Create a new bank account
  Future<BankAccountModel> createBankAccount({
    required String userId,
    required String name,
    required String bankName,
    required String accountNumber,
    required AccountType type,
    required LabelColor color,
    String? ifscCode,
    String? branchName,
    String? description,
    String? iconUrl,
    double balance = 0.0,
    bool isDefault = false,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    double? creditLimit,
    DateTime? billingDate,
  }) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final now = DateTime.now();

      // If this is set as default, unset other defaults
      if (isDefault) {
        await _unsetOtherDefaults(userId);
      }
      
      final bankAccount = BankAccountModel(
        id: docRef.id,
        userId: userId,
        name: name,
        bankName: bankName,
        accountNumber: accountNumber,
        type: type,
        status: AccountStatus.active,
        balance: balance,
        ifscCode: ifscCode,
        branchName: branchName,
        description: description,
        iconUrl: iconUrl,
        color: color,
        isDefault: isDefault,
        createdAt: now,
        updatedAt: now,
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cvv: cvv,
        creditLimit: creditLimit,
        billingDate: billingDate,
      );

      await docRef.set(bankAccount.toMap());
      return bankAccount;
    } catch (e) {
      throw FirestoreException('Error creating bank account: $e');
    }
  }

  // Update bank account
  Future<void> updateBankAccount(BankAccountModel bankAccount) async {
    try {
      // If this is set as default, unset other defaults
      if (bankAccount.isDefault) {
        await _unsetOtherDefaults(bankAccount.userId, excludeId: bankAccount.id);
      }

      await _firestore
          .collection(_collectionName)
          .doc(bankAccount.id)
          .update(bankAccount.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw FirestoreException('Error updating bank account: $e');
    }
  }

  // Update bank account balance
  Future<void> updateBalance(String accountId, double newBalance) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(accountId)
          .update({
            'balance': newBalance,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw FirestoreException('Error updating account balance: $e');
    }
  }

  // Deactivate bank account (soft delete)
  Future<void> deactivateBankAccount(String accountId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(accountId)
          .update({
            'status': AccountStatus.inactive.value,
            'isDefault': false,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw FirestoreException('Error deactivating bank account: $e');
    }
  }

  // Delete bank account (hard delete)
  Future<void> deleteBankAccount(String accountId) async {
    try {
      await _firestore.collection(_collectionName).doc(accountId).delete();
    } catch (e) {
      throw FirestoreException('Error deleting bank account: $e');
    }
  }

  // Set account as default
  Future<void> setAsDefault(String userId, String accountId) async {
    try {
      // Unset other defaults
      await _unsetOtherDefaults(userId, excludeId: accountId);
      
      // Set this account as default
      await _firestore
          .collection(_collectionName)
          .doc(accountId)
          .update({
            'isDefault': true,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw FirestoreException('Error setting default account: $e');
    }
  }

  // Get default bank account
  Future<BankAccountModel?> getDefaultBankAccount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return BankAccountModel.fromDocument(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Error fetching default account: $e');
    }
  }

  // Search bank accounts
  Future<List<BankAccountModel>> searchBankAccounts(String userId, String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      final accounts = snapshot.docs
          .map((doc) => BankAccountModel.fromDocument(doc))
          .where((account) => 
              account.name.toLowerCase().contains(query.toLowerCase()) ||
              account.bankName.toLowerCase().contains(query.toLowerCase()) ||
              account.accountNumber.contains(query))
          .toList();

      return accounts;
    } catch (e) {
      throw FirestoreException('Error searching bank accounts: $e');
    }
  }

  // Create default accounts for new user
  Future<void> createDefaultAccounts(String userId) async {
    try {
      // Create a default cash account
      await createBankAccount(
        userId: userId,
        name: 'Cash',
        bankName: 'Cash',
        accountNumber: 'CASH001',
        type: AccountType.cash,
        color: LabelColor.green,
        description: 'Default cash account',
        isDefault: true,
      );
    } catch (e) {
      throw FirestoreException('Error creating default accounts: $e');
    }
  }

  // Helper method to unset other default accounts
  Future<void> _unsetOtherDefaults(String userId, {String? excludeId}) async {
    final query = _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isDefault', isEqualTo: true);

    final snapshot = await query.get();
    
    final batch = _firestore.batch();
    
    for (final doc in snapshot.docs) {
      if (excludeId == null || doc.id != excludeId) {
        batch.update(doc.reference, {
          'isDefault': false,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    }
    
    await batch.commit();
  }

  // Get account types for dropdown
  List<AccountType> getAccountTypes() {
    return AccountType.values;
  }

  // Get account colors for selection
  List<LabelColor> getAccountColors() {
    return LabelColor.values;
  }
}
