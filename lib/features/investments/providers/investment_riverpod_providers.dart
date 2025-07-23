import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/investment_model.dart';
import 'package:my_money/core/providers/service_providers.dart';
import 'package:my_money/features/auth/providers/auth_provider.dart';
import 'package:my_money/features/investments/providers/investment_provider.dart';

// Helper provider to get current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.asData?.value?.id;
});

// Investment Provider
final investmentProviderProvider = ChangeNotifierProvider<InvestmentProvider>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  print('🔧 Creating InvestmentProvider for user: $userId');
  
  if (userId == null) {
    print('❌ No authenticated user found in investmentProviderProvider');
  }
  
  return InvestmentProvider(
    firestoreService: firestoreService,
    userId: userId ?? '',
  );
});

// Investment Stream Provider - directly connect to Firebase stream
final investmentStreamProvider = StreamProvider<List<InvestmentModel>>((ref) {
  try {
    final firestoreService = ref.read(firestoreServiceProvider);
    final userId = ref.watch(currentUserIdProvider);
    
    print('🔧 Investment Stream Provider - User: $userId');
    
    if (userId == null || userId.isEmpty) {
      print('❌ Investment Stream: No user ID available');
      return Stream.value(<InvestmentModel>[]);
    }
    
    print('🔧 Getting investments stream for user: $userId');
    return firestoreService.getUserInvestments(userId).handleError((Object error, StackTrace stackTrace) {
      print('❌ Investment Stream Error: $error');
      print('Stack trace: $stackTrace');
    });
  } catch (e, stackTrace) {
    print('❌ Investment Stream Provider Error: $e');
    print('Stack trace: $stackTrace');
    return Stream.value(<InvestmentModel>[]);
  }
});

// Portfolio Summary Provider
final portfolioSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  try {
    final provider = ref.watch(investmentProviderProvider);
    
    print('🔧 Portfolio Summary - Investment count: ${provider.investments.length}');
    print('🔧 Portfolio Summary - Loading: ${provider.isLoading}');
    print('🔧 Portfolio Summary - Error: ${provider.error}');
    
    if (provider.investments.isEmpty) {
      print('⚠️ Portfolio Summary: No investments found');
    }
    
    final summary = {
      'totalInvestment': provider.totalInvestment,
      'currentValue': provider.currentValue,
      'totalProfitLoss': provider.totalProfitLoss,
      'profitLossPercentage': provider.portfolioProfitLossPercentage,
      'activeInvestments': provider.activeInvestments.length,
      'soldInvestments': provider.soldInvestments.length,
      'watchlistInvestments': provider.watchlistInvestments.length,
    };
    
    print('📊 Portfolio Summary: $summary');
    return summary;
  } catch (e, stackTrace) {
    print('❌ Portfolio Summary Error: $e');
    print('Stack trace: $stackTrace');
    return {
      'totalInvestment': 0.0,
      'currentValue': 0.0,
      'totalProfitLoss': 0.0,
      'profitLossPercentage': 0.0,
      'activeInvestments': 0,
      'soldInvestments': 0,
      'watchlistInvestments': 0,
    };
  }
});

// Top Performers Provider
final topPerformersProvider = Provider<Map<String, List<InvestmentModel>>>((ref) {
  final provider = ref.watch(investmentProviderProvider);
  return provider.topPerformers;
});

// Portfolio Allocation Provider
final portfolioAllocationProvider = Provider<Map<String, double>>((ref) {
  final provider = ref.watch(investmentProviderProvider);
  return provider.portfolioAllocation;
});
