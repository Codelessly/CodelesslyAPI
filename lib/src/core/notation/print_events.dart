// A node's events and their actions (`onTap={…}`) in the notation's words, for
// printNodeLine (print_fields.dart).
import '../json.dart';
import 'print_fields.dart';

/// The words for node [id]'s events and their actions, each written after the line's fields;
/// empty when it has none or the notation has no word for them (they stay
/// in the line's `{…}` tail).
List<String> printEvents(String id, Json node, PrintContext context) => const [];
