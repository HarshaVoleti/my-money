import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:my_money/core/models/investment_position.dart';

const alphaVantageApiKey = 'LSSBUCDFL2QMC3H0';

/// StreamProvider to fetch live price for a given symbol and exchange (default BSE)
final livePriceStreamProvider = StreamProvider.family<double, InvestmentPosition>((ref, position) async* {
  final symbol = position.symbol;
  // TODO: Optionally store exchange in InvestmentPosition, for now default to BSE
  final exchange = 'BSE';
  while (true) {
    try {
      final url = Uri.parse(
        'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol.$exchange&apikey=$alphaVantageApiKey'
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quote = data['Global Quote'] as Map<String, dynamic>?;
        if (quote != null && quote['05. price'] != null) {
          final price = double.tryParse(quote['05. price'].toString()) ?? position.currentPrice;
          yield price;
        } else {
          yield position.currentPrice;
        }
      } else {
        yield position.currentPrice;
      }
    } catch (e) {
      yield position.currentPrice;
    }
    await Future<void>.delayed(const Duration(seconds: 10));
  }
});
