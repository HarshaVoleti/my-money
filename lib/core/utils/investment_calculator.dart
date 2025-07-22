import 'dart:math';
import 'package:my_money/core/models/investment_model.dart';

class InvestmentCalculator {
  // Calculate total investment value
  static double calculateTotalInvestment(List<InvestmentModel> investments) => investments.fold(
        0, (sum, investment) => sum + investment.totalInvestment,);

  // Calculate current portfolio value
  static double calculateCurrentValue(List<InvestmentModel> investments) => investments.fold(
        0, (sum, investment) => sum + investment.currentValue,);

  // Calculate total profit/loss
  static double calculateTotalProfitLoss(List<InvestmentModel> investments) => investments.fold(
        0, (sum, investment) => sum + investment.profitLoss,);

  // Calculate portfolio profit/loss percentage
  static double calculatePortfolioProfitLossPercentage(
      List<InvestmentModel> investments,) {
    final totalInvestment = calculateTotalInvestment(investments);
    if (totalInvestment == 0) return 0;

    final totalProfitLoss = calculateTotalProfitLoss(investments);
    return (totalProfitLoss / totalInvestment) * 100;
  }

  // Calculate required profit to break even
  static Map<String, dynamic> calculateBreakEvenAnalysis(
      List<InvestmentModel> investments,) {
    final losingStocks =
        investments.where((inv) => inv.profitLoss < 0).toList();
    final profitableStocks =
        investments.where((inv) => inv.profitLoss > 0).toList();

    final totalLoss = losingStocks.fold<double>(
        0.0, (sum, inv) => sum + inv.profitLoss.abs());
    final totalProfit = profitableStocks.fold<double>(
        0.0, (sum, inv) => sum + inv.profitLoss);

    final netPosition = totalProfit - totalLoss;
    final requiredProfit = netPosition < 0 ? netPosition.abs() : 0.0;

    return {
      'totalLoss': totalLoss,
      'totalProfit': totalProfit,
      'netPosition': netPosition,
      'requiredProfitToBreakEven': requiredProfit,
      'isInProfit': netPosition >= 0,
      'losingStocksCount': losingStocks.length,
      'profitableStocksCount': profitableStocks.length,
    };
  }

  // Calculate sector-wise performance
  static Map<String, Map<String, dynamic>> calculateSectorWisePerformance(
    List<InvestmentModel> investments,
  ) {
    final sectorMap = <String, Map<String, dynamic>>{};

    for (final investment in investments) {
      if (!sectorMap.containsKey(investment.sector)) {
        sectorMap[investment.sector ?? 'Unknown'] = {
          'totalInvestment': 0.0,
          'currentValue': 0.0,
          'profitLoss': 0.0,
          'profitLossPercentage': 0.0,
          'count': 0,
        };
      }

      sectorMap[investment.sector]!['totalInvestment'] +=
          investment.totalInvestment;
      sectorMap[investment.sector]!['currentValue'] += investment.currentValue;
      sectorMap[investment.sector]!['profitLoss'] += investment.profitLoss;
      sectorMap[investment.sector]!['count']++;
    }

    // Calculate profit/loss percentage for each sector
    sectorMap.forEach((sector, data) {
      final totalInvestment = data['totalInvestment'] as double;
      if (totalInvestment > 0) {
        data['profitLossPercentage'] =
            ((data['profitLoss'] as double) / totalInvestment) * 100;
      }
    });

    return sectorMap;
  }

  // Calculate platform-wise performance
  static Map<String, Map<String, dynamic>> calculatePlatformWisePerformance(
    List<InvestmentModel> investments,
  ) {
    final platformMap = <String, Map<String, dynamic>>{};

    for (final investment in investments) {
      if (!platformMap.containsKey(investment.platform)) {
        platformMap[investment.platform] = {
          'totalInvestment': 0.0,
          'currentValue': 0.0,
          'profitLoss': 0.0,
          'profitLossPercentage': 0.0,
          'count': 0,
        };
      }

      platformMap[investment.platform]!['totalInvestment'] +=
          investment.totalInvestment;
      platformMap[investment.platform]!['currentValue'] +=
          investment.currentValue;
      platformMap[investment.platform]!['profitLoss'] += investment.profitLoss;
      platformMap[investment.platform]!['count']++;
    }

    // Calculate profit/loss percentage for each platform
    platformMap.forEach((platform, data) {
      final totalInvestment = data['totalInvestment'] as double;
      if (totalInvestment > 0) {
        data['profitLossPercentage'] =
            ((data['profitLoss'] as double) / totalInvestment) * 100;
      }
    });

    return platformMap;
  }

  // Calculate investment allocation (percentage of each stock in portfolio)
  static Map<String, double> calculatePortfolioAllocation(
      List<InvestmentModel> investments,) {
    final totalValue = calculateCurrentValue(investments);
    if (totalValue == 0) return {};

    final allocation = <String, double>{};

    for (final investment in investments) {
      allocation[investment.symbol ?? 'Unknown'] =
          (investment.currentValue / totalValue) * 100;
    }

    return allocation;
  }

  // Calculate top performers (best and worst)
  static Map<String, List<InvestmentModel>> getTopPerformers(
    List<InvestmentModel> investments, {
    int topCount = 5,
  }) {
    final sortedByPerformance = [...investments];
    sortedByPerformance.sort(
        (a, b) => b.profitLossPercentage.compareTo(a.profitLossPercentage),);

    return {
      'topPerformers': sortedByPerformance.take(topCount).toList(),
      'worstPerformers': sortedByPerformance.reversed.take(topCount).toList(),
    };
  }

  // Calculate portfolio diversification score (0-100)
  static double calculateDiversificationScore(
      List<InvestmentModel> investments,) {
    if (investments.isEmpty) return 0;

    final sectorDistribution = calculateSectorWisePerformance(investments);
    final sectorCount = sectorDistribution.keys.length;

    // Calculate how evenly distributed the investments are across sectors
    final totalValue = calculateCurrentValue(investments);
    if (totalValue == 0) return 0;

    var entropySum = 0.0;
    sectorDistribution.forEach((sector, data) {
      final proportion = (data['currentValue'] as double) / totalValue;
      if (proportion > 0) {
        entropySum += proportion * log(proportion) / log(2);
      }
    });

    final maxEntropy = log(sectorCount) / log(2);
    final diversificationScore =
        maxEntropy > 0 ? (-entropySum / maxEntropy) * 100 : 0.0;

    return diversificationScore.clamp(0.0, 100.0);
  }

  // Calculate investment performance over time periods
  static Map<String, double> calculateTimePeriodReturns(
    List<InvestmentModel> investments,
    DateTime currentDate,
  ) {
    final now = currentDate;

    // For simplicity, we'll calculate based on purchase date
    // In a real app, you'd need historical price data
    final returns = <String, double>{
      '1W': 0.0,
      '1M': 0.0,
      '3M': 0.0,
      '6M': 0.0,
      '1Y': 0.0,
    };

    for (final investment in investments) {
      final daysSincePurchase = now.difference(investment.purchaseDate).inDays;
      final returnPercentage = investment.profitLossPercentage;

      if (daysSincePurchase >= 7) {
        returns['1W'] = returns['1W']! + returnPercentage;
      }
      if (daysSincePurchase >= 30) {
        returns['1M'] = returns['1M']! + returnPercentage;
      }
      if (daysSincePurchase >= 90) {
        returns['3M'] = returns['3M']! + returnPercentage;
      }
      if (daysSincePurchase >= 180) {
        returns['6M'] = returns['6M']! + returnPercentage;
      }
      if (daysSincePurchase >= 365) {
        returns['1Y'] = returns['1Y']! + returnPercentage;
      }
    }

    // Average the returns
    final investmentCount = investments.length;
    if (investmentCount > 0) {
      returns.updateAll((key, value) => value / investmentCount);
    }

    return returns;
  }
}
