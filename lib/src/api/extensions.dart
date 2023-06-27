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
}
