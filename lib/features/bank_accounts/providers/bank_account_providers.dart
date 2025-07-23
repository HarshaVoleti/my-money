import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/bank_account_model.dart';
import 'package:my_money/core/providers/service_providers.dart';
import 'package:my_money/features/auth/providers/auth_provider.dart';

// Stream provider for user's bank accounts
final bankAccountsStreamProvider = StreamProvider<List<BankAccountModel>>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final user = authState.valueOrNull;
  
  if (user == null) {
    return Stream.value([]);
  }

  return ref.read(bankAccountServiceProvider).getBankAccountsStream(user.id);
});

// Provider for default bank account
final defaultBankAccountProvider = FutureProvider<BankAccountModel?>((ref) async {
  final authState = ref.read(authNotifierProvider);
  final user = authState.valueOrNull;
  
  if (user == null) return null;

  return ref.read(bankAccountServiceProvider).getDefaultBankAccount(user.id);
});

// State notifier for managing bank account operations
class BankAccountNotifier extends StateNotifier<AsyncValue<BankAccountModel?>> {
  BankAccountNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> createBankAccount({
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
    final authState = ref.read(authNotifierProvider);
    final user = authState.valueOrNull;
    
    if (user == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final bankAccount = await ref.read(bankAccountServiceProvider).createBankAccount(
        userId: user.id,
        name: name,
        bankName: bankName,
        accountNumber: accountNumber,
        type: type,
        color: color,
        ifscCode: ifscCode,
        branchName: branchName,
        description: description,
        iconUrl: iconUrl,
        balance: balance,
        isDefault: isDefault,
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cvv: cvv,
        creditLimit: creditLimit,
        billingDate: billingDate,
      );
      
      state = AsyncValue.data(bankAccount);
      
      // Refresh the stream
      ref.invalidate(bankAccountsStreamProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateBankAccount(BankAccountModel bankAccount) async {
    state = const AsyncValue.loading();

    try {
      await ref.read(bankAccountServiceProvider).updateBankAccount(bankAccount);
      state = AsyncValue.data(bankAccount);
      
      // Refresh the stream
      ref.invalidate(bankAccountsStreamProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateBalance(String accountId, double newBalance) async {
    state = const AsyncValue.loading();

    try {
      await ref.read(bankAccountServiceProvider).updateBalance(accountId, newBalance);
      state = const AsyncValue.data(null);
      
      // Refresh the stream
      ref.invalidate(bankAccountsStreamProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> setAsDefault(String accountId) async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.valueOrNull;
    
    if (user == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await ref.read(bankAccountServiceProvider).setAsDefault(user.id, accountId);
      state = const AsyncValue.data(null);
      
      // Refresh the streams
      ref.invalidate(bankAccountsStreamProvider);
      ref.invalidate(defaultBankAccountProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deactivateBankAccount(String accountId) async {
    state = const AsyncValue.loading();

    try {
      await ref.read(bankAccountServiceProvider).deactivateBankAccount(accountId);
      state = const AsyncValue.data(null);
      
      // Refresh the stream
      ref.invalidate(bankAccountsStreamProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteBankAccount(String accountId) async {
    state = const AsyncValue.loading();

    try {
      await ref.read(bankAccountServiceProvider).deleteBankAccount(accountId);
      state = const AsyncValue.data(null);
      
      // Refresh the stream
      ref.invalidate(bankAccountsStreamProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createDefaultAccounts() async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.valueOrNull;
    
    if (user == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await ref.read(bankAccountServiceProvider).createDefaultAccounts(user.id);
      state = const AsyncValue.data(null);
      
      // Refresh the stream
      ref.invalidate(bankAccountsStreamProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final bankAccountNotifierProvider = StateNotifierProvider<BankAccountNotifier, AsyncValue<BankAccountModel?>>((ref) {
  return BankAccountNotifier(ref);
});

// Provider for searching bank accounts
final bankAccountSearchProvider = FutureProvider.family<List<BankAccountModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final authState = ref.read(authNotifierProvider);
  final user = authState.valueOrNull;
  
  if (user == null) return [];

  return ref.read(bankAccountServiceProvider).searchBankAccounts(user.id, query);
});

// Provider for account types
final accountTypesProvider = Provider<List<AccountType>>((ref) {
  return ref.read(bankAccountServiceProvider).getAccountTypes();
});

// Provider for account colors
final accountColorsProvider = Provider<List<LabelColor>>((ref) {
  return ref.read(bankAccountServiceProvider).getAccountColors();
});
