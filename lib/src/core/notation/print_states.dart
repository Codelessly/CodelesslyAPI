// A node's states (what changes while it is hovered, pressed, focused,
// selected, disabled) in the notation's words, for printNodeLine
// (print_fields.dart).
import '../json.dart';
import 'print_fields.dart';

/// The words for node [id]'s `states`, each written after the line's
/// fields; empty when it has none or the notation has no word for them
/// (they stay in the line's `{…}` tail).
List<String> printStates(String id, Json node, PrintContext context) => const [];
