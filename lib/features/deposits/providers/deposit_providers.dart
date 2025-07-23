import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/enums/investment_enums.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/deposit_model.dart';
import 'package:my_money/core/providers/service_providers.dart';
import 'package:my_money/core/services/deposit_service.dart';

// Deposit Stream Provider
final depositsStreamProvider = StreamProvider<List<DepositModel>>((ref) {
  final depositService = ref.read(depositServiceProvider);
  return depositService.streamDeposits();
});

// Deposit Notifier Provider
final depositNotifierProvider = AsyncNotifierProvider<DepositNotifier, List<DepositModel>>(
  () => DepositNotifier(),
);

// Deposit Statistics Provider
final depositStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final depositService = ref.read(depositServiceProvider);
  return depositService.getDepositStats();
});

// Maturing Deposits Provider
final maturingDepositsProvider = FutureProvider<List<DepositModel>>((ref) async {
  final depositService = ref.read(depositServiceProvider);
  return depositService.getMaturingDeposits();
});

class DepositNotifier extends AsyncNotifier<List<DepositModel>> {
  DepositService get _depositService => ref.read(depositServiceProvider);

  @override
  Future<List<DepositModel>> build() async {
    return _depositService.getDeposits();
  }

  /// Create a new deposit
  Future<void> createDeposit({
    required String name,
    required String description,
    required DepositType type,
    required double principalAmount,
    required double interestRate,
    required DateTime startDate,
    required DateTime maturityDate,
    required String bankName,
    int? tenureMonths,
    int? tenureDays,
    double? monthlyInstallment,
    String? accountNumber,
    String? certificateNumber,
    LabelColor color = LabelColor.blue,
    bool autoRenewal = false,
    List<String> tags = const [],
  }) async {
    try {
      state = const AsyncValue.loading();
      
      await _depositService.createDeposit(
        name: name,
        description: description,
        type: type,
        principalAmount: principalAmount,
        interestRate: interestRate,
        startDate: startDate,
        maturityDate: maturityDate,
        tenureMonths: tenureMonths,
        tenureDays: tenureDays,
        monthlyInstallment: monthlyInstallment,
        bankName: bankName,
        accountNumber: accountNumber,
        certificateNumber: certificateNumber,
        color: color,
        autoRenewal: autoRenewal,
        tags: tags,
      );
      
      // Refresh the deposits list
      state = AsyncValue.data(await _depositService.getDeposits());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update an existing deposit
  Future<void> updateDeposit(DepositModel deposit) async {
    try {
      state = const AsyncValue.loading();
      
      await _depositService.updateDeposit(deposit);
      
      // Refresh the deposits list
      state = AsyncValue.data(await _depositService.getDeposits());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update deposit current value
  Future<void> updateCurrentValue(String depositId, double currentValue) async {
    try {
      await _depositService.updateCurrentValue(depositId, currentValue);
      
      // Update the current state
      final currentDeposits = state.value ?? [];
      final updatedDeposits = currentDeposits.map((deposit) {
        if (deposit.id == depositId) {
          return deposit.copyWith(
            currentValue: currentValue,
            updatedAt: DateTime.now(),
          );
        }
        return deposit;
      }).toList();
      
      state = AsyncValue.data(updatedDeposits);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Close deposit
  Future<void> closeDeposit(String depositId, {bool isPremature = false}) async {
    try {
      await _depositService.closeDeposit(depositId, isPremature: isPremature);
      
      // Update the current state
      final currentDeposits = state.value ?? [];
      final updatedDeposits = currentDeposits.map((deposit) {
        if (deposit.id == depositId) {
          return deposit.copyWith(
            status: isPremature 
                ? DepositStatus.prematureClosed 
                : DepositStatus.matured,
            updatedAt: DateTime.now(),
          );
        }
        return deposit;
      }).toList();
      
      state = AsyncValue.data(updatedDeposits);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete deposit
  Future<void> deleteDeposit(String depositId) async {
    try {
      state = const AsyncValue.loading();
      
      await _depositService.deleteDeposit(depositId);
      
      // Refresh the deposits list
      state = AsyncValue.data(await _depositService.getDeposits());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh deposits
  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _depositService.getDeposits());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
