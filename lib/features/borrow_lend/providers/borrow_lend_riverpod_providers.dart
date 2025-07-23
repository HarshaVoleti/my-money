import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/features/borrow_lend/providers/borrow_lend_provider.dart';
import 'package:my_money/core/providers/service_providers.dart';
import 'package:my_money/features/auth/providers/auth_provider.dart';

final borrowLendProviderProvider = ChangeNotifierProvider<BorrowLendProvider>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final user = authState.valueOrNull;
  final firestoreService = ref.read(firestoreServiceProvider);
  final notificationService = ref.read(notificationServiceProvider);
  return BorrowLendProvider(
    firestoreService: firestoreService,
    notificationService: notificationService,
    userId: user?.id ?? '',
  );
});
