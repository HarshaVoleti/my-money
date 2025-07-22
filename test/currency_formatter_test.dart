import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('format basic currency', () {
      expect(CurrencyFormatter.format(1234.56), '\$1,234.56');
    });

    test('format with sign - positive', () {
      expect(CurrencyFormatter.formatWithSign(1234.56), '+\$1,234.56');
    });

    test('format with sign - negative', () {
      expect(CurrencyFormatter.formatWithSign(-1234.56), '-\$1,234.56');
    });

    test('format with sign - zero', () {
      expect(CurrencyFormatter.formatWithSign(0), '+\$0.00');
    });

    test('format compact - millions', () {
      expect(CurrencyFormatter.formatCompact(1234567), '\$1.2M');
    });

    test('format compact - thousands', () {
      expect(CurrencyFormatter.formatCompact(12345), '\$12.3K');
    });

    test('format compact - small amounts', () {
      expect(CurrencyFormatter.formatCompact(123.45), '\$123.45');
    });

    test('format compact - billions', () {
      expect(CurrencyFormatter.formatCompact(1234567890), '\$1.2B');
    });
  });
}
