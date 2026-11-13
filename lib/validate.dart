/// Strict validation of layout documents: what the lenient decoders would
/// silently drop, replace or ignore, as typed diagnostics.
library;

export 'src/validate/diagnostic.dart' show Codes, Diagnostic, DiagnosticCode, Severity;
export 'src/validate/expressions.dart' show FormulaChecker, FormulaReport, runtimeScopes, scanExpressions;
export 'src/validate/validator.dart'
    show ValidateOptions, canvasRouteKeys, documentKeys, pageVariablesScope, themeKeys, validateDocument, validateProject, validateTheme;
export 'src/validate/values.dart' show valueForms;
