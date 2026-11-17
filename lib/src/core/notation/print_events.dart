// A node's events and their actions (`onTap={…}`) in the notation's words, for
// printNodeLine (print_fields.dart).
import '../json.dart';
import 'print_fields.dart';

/// The words for node [id]'s events and their actions, each written after the line's fields;
/// empty when it has none or the notation has no word for them (they stay
/// in the line's `{…}` tail).
List<String> printEvents(String id, Json node, PrintContext context) => const [];

/// The screen's own reactions as lines of their own, at the margin: `every
/// 1s onTick={…}`, `key mod+k onPress={…}` (the canvas's timer and keyDown
/// reactions). A stub on the document family's branch, called by the walk
/// (print.dart); the events family writes it.
List<String> printCanvasEvents(Json document, PrintContext context) => const [];
