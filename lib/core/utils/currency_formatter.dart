import 'package:intl/intl.dart';

/// Utility class for formatting currency values consistently across the app
class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Format a double value as currency string
  /// Example: 1234.56 -> "\$1,234.56"
  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format with sign for positive/negative values
  /// Example: 1234.56 -> "+\$1,234.56", -1234.56 -> "-\$1,234.56"
  static String formatWithSign(double amount) {
    final formatted = _currencyFormat.format(amount.abs());
    if (amount >= 0) {
      return '+$formatted';
    } else {
      return '-$formatted';
    }
  }

  /// Format for compact display (K, M notation)
  /// Example: 1234567 -> "\$1.2M"
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return format(amount);
    }
  }
}
