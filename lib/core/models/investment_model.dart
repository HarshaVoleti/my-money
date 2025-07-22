import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_money/core/enums/investment_enums.dart';
import 'package:my_money/core/enums/label_enums.dart';

class InvestmentModel {
  final String id;
  final String userId;
  final String name; // Changed from stockName
  final String? symbol; // Changed from stockSymbol, made optional
  final InvestmentType type; // Added investment type
  final double purchasePrice;
  final double quantity; // Changed from int to double for fractional units
  final double currentPrice;
  final DateTime purchaseDate;
  final String platform; // Upstox, Groww, etc.
  final String? sector;
  final InvestmentStatus status; // Changed to enum
  final DateTime? soldDate;
  final double? soldPrice;
  final LabelColor color; // Added color
  final List<String> tags; // Added tags
  final DateTime createdAt;
  final DateTime? updatedAt;

  InvestmentModel({
    required this.id,
    required this.userId,
    required this.name,
    this.symbol,
    required this.type,
    required this.purchasePrice,
    required this.quantity,
    required this.currentPrice,
    required this.purchaseDate,
    required this.platform,
    this.sector,
    required this.status,
    required this.createdAt,
    this.soldDate,
    this.soldPrice,
    this.color = LabelColor.blue,
    this.tags = const [],
    this.updatedAt,
  });

  factory InvestmentModel.fromMap(Map<String, dynamic> map) => 
      InvestmentModel(
        id: map['id'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        name: map['name'] as String? ?? map['stockName'] as String? ?? '', // Support old field
        symbol: map['symbol'] as String? ?? map['stockSymbol'] as String?, // Support old field
        type: InvestmentType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => InvestmentType.stocks, // Default to stocks for old records
        ),
        purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0,
        quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
        currentPrice: (map['currentPrice'] as num?)?.toDouble() ?? 0.0,
        purchaseDate: DateTime.parse(map['purchaseDate'] as String),
        platform: map['platform'] as String? ?? '',
        sector: map['sector'] as String?,
        status: InvestmentStatus.values.firstWhere(
          (s) => s.name == map['status'] || map['status'] == s.displayName,
          orElse: () => InvestmentStatus.active,
        ),
        soldDate: map['soldDate'] != null 
            ? DateTime.parse(map['soldDate'] as String) 
            : null,
        soldPrice: (map['soldPrice'] as num?)?.toDouble(),
        color: LabelColor.values.firstWhere(
          (c) => c.name == map['color'],
          orElse: () => LabelColor.blue,
        ),
        tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null 
            ? DateTime.parse(map['updatedAt'] as String) 
            : null,
      );

  factory InvestmentModel.fromDocument(DocumentSnapshot doc) => 
      InvestmentModel.fromMap(doc.data()! as Map<String, dynamic>);

  // Calculated properties
  double get totalInvestment => purchasePrice * quantity;
  double get currentValue => currentPrice * quantity;
  double get profitLoss => currentValue - totalInvestment;
  double get profitLossPercentage => (profitLoss / totalInvestment) * 100;
  bool get isProfit => profitLoss > 0;

  Map<String, dynamic> toMap() => {
      'id': id,
      'userId': userId,
      'name': name,
      'symbol': symbol,
      'type': type.name,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
      'currentPrice': currentPrice,
      'purchaseDate': purchaseDate.toIso8601String(),
      'platform': platform,
      'sector': sector,
      'status': status.name,
      'soldDate': soldDate?.toIso8601String(),
      'soldPrice': soldPrice,
      'color': color.name,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

  InvestmentModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? symbol,
    InvestmentType? type,
    double? purchasePrice,
    double? quantity, // Changed from int to double
    double? currentPrice,
    DateTime? purchaseDate,
    String? platform,
    String? sector,
    InvestmentStatus? status,
    DateTime? soldDate,
    double? soldPrice,
    LabelColor? color,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => InvestmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      quantity: quantity ?? this.quantity,
      currentPrice: currentPrice ?? this.currentPrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      platform: platform ?? this.platform,
      sector: sector ?? this.sector,
      status: status ?? this.status,
      soldDate: soldDate ?? this.soldDate,
      soldPrice: soldPrice ?? this.soldPrice,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  @override
  String toString() {
    return 'InvestmentModel(id: $id, name: $name, type: $type, totalInvestment: $totalInvestment, currentValue: $currentValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvestmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
