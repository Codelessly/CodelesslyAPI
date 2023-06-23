import 'dart:convert';

import '../../codelessly_api.dart';

/// Declares extensions [String].
extension StringExtensions on String {
  /// Converts given string to a typed value if possible.
  /// Returns [defaultValue] or null otherwise.
  R? typedValue<R>({R? defaultValue}) {
    final value = this;
    if (R == String) {
      return value as R;
    } else if (R == int) {
      return (int.tryParse(value) ?? defaultValue) as R?;
    } else if (R == double) {
      return (double.tryParse(value) ?? defaultValue) as R;
    } else if (R == num) {
      return (num.tryParse(value) ?? defaultValue) as R;
    } else if (R == bool) {
      final boolValue = bool.tryParse(value, caseSensitive: false);
      if (boolValue == null) return defaultValue;
      return (boolValue || value == '1') as R;
    } else if (R == Map) {
      try {
        return jsonDecode(value) as R?;
      } catch (e) {
        return defaultValue;
      }
    } else if (R == List) {
      try {
        return value
            .substring(1, value.length - 1)
            .split(',')
            .map((e) => e.trim().parsedValue())
            .toList() as R?;
      } catch (e) {
        return defaultValue;
      }
    } else {
      return value as R?;
    }
  }

  /// Parse given string to a compatible dart primitive type.
  dynamic parsedValue() {
    return num.tryParse(this) ?? bool.tryParse(this) ?? this;
  }

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
}
