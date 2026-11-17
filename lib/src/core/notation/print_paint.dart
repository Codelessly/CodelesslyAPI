// A node's custom paint, animations and charts in the notation's words, for
// printNodeLine (print_fields.dart).
import '../json.dart';
import 'print_fields.dart';

/// The words for node [id]'s custom paint, animations and charts, each written after the line's fields;
/// empty when it has none or the notation has no word for them (they stay
/// in the line's `{…}` tail).
List<String> printPaint(String id, Json node, PrintContext context) => const [];
