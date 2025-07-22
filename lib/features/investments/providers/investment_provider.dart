import 'package:flutter/foundation.dart';
import 'package:my_money/core/models/investment_model.dart';
import 'package:my_money/core/services/firestore_service.dart';
import 'package:my_money/core/utils/investment_calculator.dart';
import 'package:my_money/core/enums/investment_enums.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:uuid/uuid.dart';

class InvestmentProvider extends ChangeNotifier {

  InvestmentProvider({
    required FirestoreService firestoreService,
    required String userId,
  })  : _firestoreService = firestoreService,
        _userId = userId {
    if (_userId.isNotEmpty) {
      _listenToInvestments();
    }
  }
  final FirestoreService _firestoreService;
  final String _userId;

  List<InvestmentModel> _investments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<InvestmentModel> get investments => _investments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter investments
  List<InvestmentModel> get activeInvestments =>
      _investments.where((inv) => inv.status == InvestmentStatus.active).toList();

  List<InvestmentModel> get soldInvestments =>
      _investments.where((inv) => inv.status == InvestmentStatus.sold).toList();

  List<InvestmentModel> get watchlistInvestments =>
      _investments.where((inv) => inv.status == InvestmentStatus.watchlist).toList();

  // Portfolio calculations
  double get totalInvestment =>
      InvestmentCalculator.calculateTotalInvestment(_investments);

  double get currentValue =>
      InvestmentCalculator.calculateCurrentValue(_investments);

  double get totalProfitLoss =>
      InvestmentCalculator.calculateTotalProfitLoss(_investments);

  double get portfolioProfitLossPercentage =>
      InvestmentCalculator.calculatePortfolioProfitLossPercentage(_investments);

  Map<String, dynamic> get breakEvenAnalysis =>
      InvestmentCalculator.calculateBreakEvenAnalysis(_investments);

  Map<String, Map<String, dynamic>> get sectorWisePerformance =>
      InvestmentCalculator.calculateSectorWisePerformance(_investments);

  Map<String, Map<String, dynamic>> get platformWisePerformance =>
      InvestmentCalculator.calculatePlatformWisePerformance(_investments);

  Map<String, double> get portfolioAllocation =>
      InvestmentCalculator.calculatePortfolioAllocation(_investments);

  Map<String, List<InvestmentModel>> get topPerformers =>
      InvestmentCalculator.getTopPerformers(_investments);

  double get diversificationScore =>
      InvestmentCalculator.calculateDiversificationScore(_investments);

  void _listenToInvestments() {
    _firestoreService.getUserInvestments(_userId).listen(
      (investments) {
        _investments = investments;
        notifyListeners();
      },
      onError: (Object error) {
        _setError(error.toString());
      },
    );
  }

  Future<void> addInvestment({
    required String name,
    String? symbol,
    required InvestmentType type,
    required double purchasePrice,
    required double quantity, // Changed from int to double
    required double currentPrice,
    required DateTime purchaseDate,
    required String platform,
    String? sector,
    List<String> tags = const [],
    LabelColor color = LabelColor.blue,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final investment = InvestmentModel(
        id: const Uuid().v4(),
        userId: _userId,
        name: name,
        symbol: symbol,
        type: type,
        purchasePrice: purchasePrice,
        quantity: quantity,
        currentPrice: currentPrice,
        purchaseDate: purchaseDate,
        platform: platform,
        sector: sector,
        status: InvestmentStatus.active,
        tags: tags,
        color: color,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addInvestment(investment);
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateInvestment(InvestmentModel investment) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.updateInvestment(investment);
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCurrentPrice(String investmentId, double newPrice) async {
    try {
      final investment =
          _investments.firstWhere((inv) => inv.id == investmentId);
      final updatedInvestment = investment.copyWith(
        currentPrice: newPrice,
        updatedAt: DateTime.now(),
      );

      await updateInvestment(updatedInvestment);
    } on Exception catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> sellInvestment({
    required String investmentId,
    required double soldPrice,
    required DateTime soldDate,
  }) async {
    try {
      final investment =
          _investments.firstWhere((inv) => inv.id == investmentId);
      final updatedInvestment = investment.copyWith(
        status: InvestmentStatus.sold,
        soldPrice: soldPrice,
        soldDate: soldDate,
        updatedAt: DateTime.now(),
      );

      await updateInvestment(updatedInvestment);
    } on Exception catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteInvestment(String investmentId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.deleteInvestment(investmentId);
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get investments by platform
  List<InvestmentModel> getInvestmentsByPlatform(String platform) => 
      _investments.where((inv) => inv.platform == platform).toList();

  // Get investments by sector
  List<InvestmentModel> getInvestmentsBySector(String sector) => 
      _investments.where((inv) => inv.sector == sector).toList();

  // Get investments by type
  List<InvestmentModel> getInvestmentsByType(InvestmentType type) => 
      _investments.where((inv) => inv.type == type).toList();

  // Get profitable investments
  List<InvestmentModel> getProfitableInvestments() => 
      _investments.where((inv) => inv.profitLoss > 0).toList();

  // Get losing investments
  List<InvestmentModel> getLosingInvestments() => 
      _investments.where((inv) => inv.profitLoss < 0).toList();

  // Calculate time period returns
  Map<String, double> getTimePeriodReturns() => InvestmentCalculator.calculateTimePeriodReturns(
      _investments,
      DateTime.now(),
    );

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Manual refresh method
  Future<void> refreshInvestments() async {
    try {
      _setLoading(true);
      _setError(null);
      
      // The stream listener will automatically update the investments
      // This method is mainly for UI feedback
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
