import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/label_model.dart';
import 'package:my_money/core/providers/service_providers.dart';
import 'package:my_money/features/auth/providers/auth_provider.dart';

// Stream provider for all labels of a user
final labelsStreamProvider = StreamProvider.family<List<LabelModel>, LabelType>((ref, type) {
  final authState = ref.watch(authNotifierProvider);
  final user = authState.valueOrNull;
  
  if (user == null) {
    return Stream.value([]);
  }

  return ref.read(labelServiceProvider).getLabelsStream(user.id, type: type);
});

// Provider for getting labels by IDs
final labelsByIdsProvider = FutureProvider.family<List<LabelModel>, List<String>>((ref, ids) async {
  if (ids.isEmpty) return [];
  
  final labelService = ref.read(labelServiceProvider);
  return labelService.getLabelsByIds(ids);
});

// Provider for labels by type
final incomeLabelsProvider = Provider<AsyncValue<List<LabelModel>>>((ref) {
  return ref.watch(labelsStreamProvider(LabelType.income));
});

final expenseLabelsProvider = Provider<AsyncValue<List<LabelModel>>>((ref) {
  return ref.watch(labelsStreamProvider(LabelType.expense));
});

final investmentLabelsProvider = Provider<AsyncValue<List<LabelModel>>>((ref) {
  return ref.watch(labelsStreamProvider(LabelType.investment));
});

// State notifier for managing label creation/editing
class LabelNotifier extends StateNotifier<AsyncValue<LabelModel?>> {
  LabelNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> createLabel({
    required String name,
    required LabelType type,
    required LabelColor color,
    String? icon,
    String? description,
  }) async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.valueOrNull;
    
    if (user == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final label = await ref.read(labelServiceProvider).createLabel(
        userId: user.id,
        name: name,
        type: type,
        color: color,
        icon: icon,
        description: description,
      );
      
      state = AsyncValue.data(label);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateLabel(LabelModel label) async {
    state = const AsyncValue.loading();

    try {
      await ref.read(labelServiceProvider).updateLabel(label);
      state = AsyncValue.data(label);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteLabel(String labelId) async {
    state = const AsyncValue.loading();

    try {
      await ref.read(labelServiceProvider).deleteLabel(labelId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createDefaultLabels() async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.valueOrNull;
    
    if (user == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await ref.read(labelServiceProvider).createDefaultLabels(user.id);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final labelNotifierProvider = StateNotifierProvider<LabelNotifier, AsyncValue<LabelModel?>>((ref) {
  return LabelNotifier(ref);
});

// Provider for searching labels
final labelSearchProvider = FutureProvider.family<List<LabelModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final authState = ref.read(authNotifierProvider);
  final user = authState.valueOrNull;
  
  if (user == null) return [];

  return ref.read(labelServiceProvider).searchLabels(user.id, query);
});
