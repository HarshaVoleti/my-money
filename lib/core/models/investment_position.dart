import 'package:my_money/core/models/investment_model.dart';
import 'package:my_money/core/enums/investment_enums.dart';
import 'package:my_money/core/enums/label_enums.dart';

/// Represents a grouped investment position (all orders of the same symbol)
class InvestmentPosition {
  final String symbol;
  final String name;
  final InvestmentType type;
  final double currentPrice;
  final List<InvestmentModel> orders;
  final String? sector;
  final LabelColor color;
  final List<String> tags;

  InvestmentPosition({
    required this.symbol,
    required this.name,
    required this.type,
    required this.currentPrice,
    required this.orders,
    this.sector,
    this.color = LabelColor.blue,
    this.tags = const [],
  });

  /// Create position from a list of orders with the same symbol
  factory InvestmentPosition.fromOrders(List<InvestmentModel> orders) {
    if (orders.isEmpty) {
      throw ArgumentError('Cannot create position from empty orders list');
    }

    final firstOrder = orders.first;
    return InvestmentPosition(
      symbol: firstOrder.symbol ?? firstOrder.name,
      name: firstOrder.name,
      type: firstOrder.type,
      currentPrice: firstOrder.currentPrice, // Use the latest current price
      orders: orders..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate)), // Sort by date desc
      sector: firstOrder.sector,
      color: firstOrder.color,
      tags: firstOrder.tags,
    );
  }

  // create copy with for investment position
  InvestmentPosition copyWith({
    String? symbol,
    String? name,
    InvestmentType? type,
    double? currentPrice,
    List<InvestmentModel>? orders,
    String? sector,
    LabelColor? color,
    List<String>? tags,
  }) {
    return InvestmentPosition(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      currentPrice: currentPrice ?? this.currentPrice,
      orders: orders ?? this.orders,
      sector: sector ?? this.sector,
      color: color ?? this.color,
      tags: tags ?? this.tags,
    );
  }

  // Calculated properties for the aggregated position
  double get totalQuantity => orders.fold(0.0, (sum, order) => sum + order.quantity);
  
  double get totalInvestment => orders.fold(0.0, (sum, order) => sum + order.totalInvestment);
  
  double get averagePrice => totalInvestment / totalQuantity;
  
  double get currentValue => currentPrice * totalQuantity;
  
  double get profitLoss => currentValue - totalInvestment;
  
  double get profitLossPercentage => (profitLoss / totalInvestment) * 100;
  
  bool get isProfit => profitLoss > 0;
  
  DateTime get firstPurchaseDate => orders.map((o) => o.purchaseDate).reduce(
    (a, b) => a.isBefore(b) ? a : b,
  );
  
  DateTime get lastPurchaseDate => orders.map((o) => o.purchaseDate).reduce(
    (a, b) => a.isAfter(b) ? a : b,
  );

  /// Get platforms where this stock is held
  List<String> get platforms => orders.map((o) => o.platform).toSet().toList();

  /// Get order count
  int get orderCount => orders.length;

  @override
  String toString() {
    return 'InvestmentPosition(symbol: $symbol, quantity: $totalQuantity, avgPrice: ${averagePrice.toStringAsFixed(2)}, P&L: ${profitLoss.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvestmentPosition && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;
}
