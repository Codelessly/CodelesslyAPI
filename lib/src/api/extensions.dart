import 'dart:math';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import '../../codelessly_api.dart';

/// Declares extensions [String].
extension StringExtensions on String {
  /// Replaces [oldName] variable name with [newName] if this string happens
  /// to be a variable path.
  /// This string must be wrapped with ${} for this to work.
  String replaceVariableName(String oldName, String newName) {
    if (isEmpty) return this;

    return splitMapJoin(variableSyntaxIdentifierRegex, onMatch: (match) {
      final String variablePath = match[0]!;
      if (!variablePath.startsWith('\${$oldName')) return variablePath;
      return variablePath.replaceFirst('\${$oldName', '\${$newName');
    });
  }

  /// Returns true if this string exactly matches the given [pattern].
  bool hasExactMatch(Pattern pattern) => pattern.hasExactMatch(this);
}

/// A helper extension that adds additional functionality to [Iterable].
extension IterableExt<E> on Iterable<E> {
  /// Returns a new list containing the elements between [start] and [end].
  List<E> sublist(int start, [int? end]) {
    int listLength = length;
    end ??= listLength;

    RangeError.checkValidRange(start, end, listLength);
    return List.from(_getRange(start, end));
  }

  Iterable<E> _getRange(int start, int end) sync* {
    for (int i = start; i < end; i++) {
      yield elementAt(i);
    }
  }
}

final NumberFormat _formatter = NumberFormat('0.##')..minimumFractionDigits = 0;

/// A helper extension that adds additional functionality to [double].
extension RoundNum on num {
  /// Rounds the double to the [precision]'th decimal place.
  ///
  /// Example:
  /// 12435.6789.roundToPrecision(3)
  ///
  /// Step 1: pow decimal: 10^3 = 1000
  /// Step 2: 12435.6789 * 1000 = 12435678.9
  /// Step 3: round(12435678.9) = 12435679
  /// Step 4: 12435679 / 1000 = 12435.679
  double roundToPrecision(int decimal) {
    if (isNaN || isInfinite) return toDouble();
    final double precision = pow(10, decimal).toDouble();
    return (this * precision).round() / precision;
  }

  /// Returns the double as a pretty rounded double.
  num toPrettyPrecision(int precision) {
    if (isNaN || isInfinite) return this;
    _formatter.maximumFractionDigits = precision;
    return num.parse(_formatter.format(this));
  }
}

/// A helper extension that adds additional functionality to [Pattern].
extension PatternExt on Pattern {
  /// Returns true if [input] exactly matches the patten.
  bool hasExactMatch(String? input) {
    final Match? match = matchAsPrefix(input ??= '');
    if (match == null) return false;
    return match.start == 0 && match.end == input.length;
  }
}

/// A helper extension that adds additional functionality to
/// [TextInputValidatorModel] iterable.
extension TextInputValidatorModelIterableExt<T extends TextInputValidatorModel>
    on Iterable<T> {
  /// Returns the first [TextInputValidatorModel] with the given [name].
  /// Returns null if no validator is found.
  T? byNameOrNull(String name) =>
      firstWhereOrNull((model) => model.name == name);

  /// Returns the first [TextInputValidatorModel] with the given [name].
  T byName(String name) {
    final T? model = byNameOrNull(name);
    if (model == null) {
      throw ArgumentError('No validator found with the name: $name');
    }
    return model;
  }
}

/// A helper extension that adds additional functionality to
/// [TextInputValidatorModel] iterable.
extension TextInputFormatterModelIterableExt<T extends TextInputFormatterModel>
    on Iterable<T> {
  /// Returns the first [TextInputFormatterModel] with the given [name].
  /// Returns null if no validator is found.
  T? byNameOrNull(String name) =>
      firstWhereOrNull((model) => model.name == name);

  /// Returns the first [TextInputValidatorModel] with the given [name].
  T byName(String name) {
    final T? model = byNameOrNull(name);
    if (model == null) {
      throw ArgumentError('No validator found with the name: $name');
    }
    return model;
  }
}
