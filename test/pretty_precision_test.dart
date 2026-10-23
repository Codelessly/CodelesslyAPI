import 'dart:math';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

void main() {
  test('toPrettyPrecision matches the number-format rounding it replaced', () {
    final NumberFormat format = NumberFormat('0.##')..minimumFractionDigits = 0;
    num old(num value, int precision) {
      format.maximumFractionDigits = precision;
      return num.parse(format.format(value));
    }

    final Random random = Random(7);
    final List<num> values = [
      0,
      -0.0,
      1,
      -1,
      2.0001,
      0.0005,
      0.0015,
      12435.6789,
      -3.14159,
      1e9 + 0.25,
      for (int i = 0; i < 200000; i++)
        (random.nextDouble() - 0.5) * pow(10, random.nextInt(8)),
    ];
    int mismatches = 0;
    for (final num value in values) {
      for (final int precision in [0, 2, 3]) {
        final num a = value.toPrettyPrecision(precision);
        final num b = old(value, precision);
        if (a != b || a.runtimeType != b.runtimeType && a != 0) {
          // Halfway cases may round differently in the last digit.
          if ((a - b).abs() > pow(10, -precision) + 1e-9) {
            fail('$value @ $precision: $a vs $b');
          }
          mismatches++;
        }
      }
    }
    expect(mismatches, lessThan(values.length * 3 ~/ 1000));
  });
}
