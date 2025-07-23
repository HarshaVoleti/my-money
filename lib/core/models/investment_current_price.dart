import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for managing current prices of investment symbols
/// This allows multiple orders of the same symbol to share the same current price
class InvestmentCurrentPrice {
  final String symbol;
  final double currentPrice;
  final DateTime lastUpdated;
  final String? source; // Manual, API, etc.

  InvestmentCurrentPrice({
    required this.symbol,
    required this.currentPrice,
    required this.lastUpdated,
    this.source,
  });

  factory InvestmentCurrentPrice.fromMap(Map<String, dynamic> map) => 
      InvestmentCurrentPrice(
        symbol: map['symbol'] as String,
        currentPrice: (map['currentPrice'] as num).toDouble(),
        lastUpdated: DateTime.parse(map['lastUpdated'] as String),
        source: map['source'] as String?,
      );

  factory InvestmentCurrentPrice.fromDocument(DocumentSnapshot doc) =>
      InvestmentCurrentPrice.fromMap(doc.data()! as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
        'symbol': symbol,
        'currentPrice': currentPrice,
        'lastUpdated': lastUpdated.toIso8601String(),
        'source': source,
      };

  InvestmentCurrentPrice copyWith({
    String? symbol,
    double? currentPrice,
    DateTime? lastUpdated,
    String? source,
  }) => InvestmentCurrentPrice(
        symbol: symbol ?? this.symbol,
        currentPrice: currentPrice ?? this.currentPrice,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        source: source ?? this.source,
      );

  @override
  String toString() {
    return 'InvestmentCurrentPrice(symbol: $symbol, price: $currentPrice, updated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvestmentCurrentPrice && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;
}
