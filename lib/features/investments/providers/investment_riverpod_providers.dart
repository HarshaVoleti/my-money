import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/investment_model.dart';
import 'package:my_money/core/providers/service_providers.dart';
import 'package:my_money/features/investments/providers/investment_provider.dart';

// Investment Provider
final investmentProviderProvider = ChangeNotifierProvider<InvestmentProvider>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  const userId = 'demo-user'; // This would come from auth
  
  return InvestmentProvider(
    firestoreService: firestoreService,
    userId: userId,
  );
});

// Investment Stream Provider - directly connect to Firebase stream
final investmentStreamProvider = StreamProvider<List<InvestmentModel>>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  const userId = 'demo-user'; // This would come from auth
  
  return firestoreService.getUserInvestments(userId);
});

// Portfolio Summary Provider
final portfolioSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final provider = ref.watch(investmentProviderProvider);
  
  return {
    'totalInvestment': provider.totalInvestment,
    'currentValue': provider.currentValue,
    'totalProfitLoss': provider.totalProfitLoss,
    'profitLossPercentage': provider.portfolioProfitLossPercentage,
    'activeInvestments': provider.activeInvestments.length,
    'soldInvestments': provider.soldInvestments.length,
    'watchlistInvestments': provider.watchlistInvestments.length,
  };
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
