// Universal words (docs/design/21-universal-words.md): the parameters, flags
// and events that mean the same on every line, in one table. The parser asks
// it what a word is (notation.dart reads each where a line is read), a
// defined word passes a use's universal words to its root by it (define.dart),
// and the SDK's counting tool resolves by it.

/// Whether a universal word is written key=value, as a bare word, or as an
/// on… event.
enum UniversalKind { parameter, flag, event }

/// A word every line understands.
final class UniversalWord {
  const UniversalWord(this.kind, this.meaning, {this.grammar = false, this.on = const {}, this.of});

  /// key=value, a bare word or an event. A word written both ways (`hidden`,
  /// `sticky`, `grow`, `selected`) is in the table under the kind it is most
  /// often written as, and read in both.
  final UniversalKind kind;

  /// What it means, in a line.
  final String meaning;

  /// One of the grammar's own words (they predate the universal words).
  final bool grammar;

  /// The kinds of line it is universal on (`container`, `text`, `icon`,
  /// `control`); empty: every line.
  final Set<String> on;

  /// Another name of the same word (`sortable` is `reorder`).
  final String? of;
}

/// The words every line understands: the grammar's own, and the universal
/// words of docs/design/21-universal-words.md.
const Map<String, UniversalWord> notationUniversal = {
  // --- the grammar's own: layout and look ----------------------------------
  'w': UniversalWord(UniversalKind.parameter, 'its width: a number, fill or hug', grammar: true),
  'h': UniversalWord(UniversalKind.parameter, 'its height', grammar: true),
  'width': UniversalWord(UniversalKind.parameter, 'its width', grammar: true, of: 'w'),
  'height': UniversalWord(UniversalKind.parameter, 'its height', grammar: true, of: 'h'),
  'grow': UniversalWord(UniversalKind.flag, 'takes the room left along its row or column', grammar: true),
  'pad': UniversalWord(UniversalKind.parameter, 'the room inside its edge', grammar: true),
  'padding': UniversalWord(UniversalKind.parameter, 'the room inside its edge', grammar: true, of: 'pad'),
  'gap': UniversalWord(UniversalKind.parameter, 'the room between what is in it', grammar: true),
  'fill': UniversalWord(UniversalKind.parameter, 'its background colour (a bare fill: as wide as its place)', grammar: true),
  'radius': UniversalWord(UniversalKind.parameter, 'its corners', grammar: true),
  'border': UniversalWord(UniversalKind.parameter, 'a hairline round it', grammar: true),
  'border-top': UniversalWord(UniversalKind.parameter, 'a hairline on that side', grammar: true),
  'border-bottom': UniversalWord(UniversalKind.parameter, 'a hairline on that side', grammar: true),
  'border-left': UniversalWord(UniversalKind.parameter, 'a hairline on that side', grammar: true),
  'border-right': UniversalWord(UniversalKind.parameter, 'a hairline on that side', grammar: true),
  'maxw': UniversalWord(UniversalKind.parameter, 'the widest it gets', grammar: true),
  'scroll': UniversalWord(UniversalKind.flag, 'scrolls what is in it', grammar: true),
  'sticky': UniversalWord(UniversalKind.flag, 'stays in view while the page scrolls under it', grammar: true),
  'animate': UniversalWord(UniversalKind.parameter, 'how it arrives or keeps moving', grammar: true),
  'duration': UniversalWord(UniversalKind.parameter, 'with animate: how long', grammar: true),
  'delay': UniversalWord(UniversalKind.parameter, 'with animate: how long before', grammar: true),
  'stagger': UniversalWord(UniversalKind.parameter, 'with animate under an each: each copy that much later', grammar: true),
  // --- the grammar's own: place --------------------------------------------
  'center': UniversalWord(UniversalKind.flag, 'centred across', grammar: true),
  'middle': UniversalWord(UniversalKind.flag, 'centred down', grammar: true),
  'start': UniversalWord(UniversalKind.flag, 'at the start', grammar: true),
  'end': UniversalWord(UniversalKind.flag, 'at the end', grammar: true),
  'between': UniversalWord(UniversalKind.flag, 'its ends apart', grammar: true),
  'around': UniversalWord(UniversalKind.flag, 'spread with room around each', grammar: true),
  'evenly': UniversalWord(UniversalKind.flag, 'spread evenly', grammar: true),
  'top': UniversalWord(UniversalKind.flag, 'at the top', grammar: true),
  'bottom': UniversalWord(UniversalKind.flag, 'at the bottom', grammar: true),
  'left': UniversalWord(UniversalKind.flag, 'at the left', grammar: true),
  'right': UniversalWord(UniversalKind.flag, 'at the right', grammar: true),
  'stretch': UniversalWord(UniversalKind.flag, 'what is in it as wide as it', grammar: true),
  // --- the grammar's own: showing, naming, moving ---------------------------
  'visible': UniversalWord(UniversalKind.parameter, 'shown while it holds', grammar: true),
  'hidden': UniversalWord(UniversalKind.flag, 'not shown (hidden={cond}: while it holds)', grammar: true),
  'hide': UniversalWord(UniversalKind.parameter, 'not shown at that size (hide=phone)', grammar: true),
  'show': UniversalWord(UniversalKind.parameter, 'shown only at that size (show=phone)', grammar: true),
  'id': UniversalWord(UniversalKind.parameter, 'a name a scroll goes to', grammar: true),
  'drag': UniversalWord(UniversalKind.parameter, 'dragged, in a group, carrying a value', grammar: true),
  'drop': UniversalWord(UniversalKind.parameter, 'takes drops from those groups', grammar: true),
  'menu': UniversalWord(UniversalKind.parameter, 'that Menu on a right click or a long press', grammar: true),
  'preview': UniversalWord(UniversalKind.parameter, 'that Popover as a hover card', grammar: true),
  'tooltip': UniversalWord(UniversalKind.parameter, 'shown on hover, focus or a touch hold; names an icon-only button', grammar: true),
  'selected': UniversalWord(UniversalKind.parameter, 'its selected state: the theme\'s selected look, announced selected', grammar: true),
  // --- the grammar's own: the pointer --------------------------------------
  'onTap': UniversalWord(UniversalKind.event, 'a tap or click (Enter or Space when focused)', grammar: true),
  'onLongPress': UniversalWord(UniversalKind.event, 'a long press', grammar: true),
  'onDoubleTap': UniversalWord(UniversalKind.event, 'a double tap', grammar: true),
  'onRightClick': UniversalWord(UniversalKind.event, 'a right click', grammar: true),
  'onHover': UniversalWord(UniversalKind.event, 'the pointer comes over it', grammar: true),
  'onDrop': UniversalWord(UniversalKind.event, 'something dragged is dropped on it', grammar: true),
  'onSwipeLeft': UniversalWord(UniversalKind.event, 'a swipe', grammar: true),
  'onSwipeRight': UniversalWord(UniversalKind.event, 'a swipe', grammar: true),
  'onSwipeUp': UniversalWord(UniversalKind.event, 'a swipe', grammar: true),
  'onSwipeDown': UniversalWord(UniversalKind.event, 'a swipe', grammar: true),
  // --- the universal words (note 21) ----------------------------------------
  'color': UniversalWord(UniversalKind.parameter,
      'its main ink: a text\'s or an icon\'s colour, a control\'s accent, on a container the ink of what is written in it',
      on: {'container', 'text', 'icon', 'control'}),
  'size': UniversalWord(UniversalKind.parameter, 'small, medium or large: a step of the theme\'s scale (a number where the type takes one)',
      on: {'text', 'icon', 'control'}),
  'icon': UniversalWord(UniversalKind.parameter, 'a leading icon on what has a label', on: {'icon', 'control'}),
  'enabled': UniversalWord(UniversalKind.parameter, 'false (or disabled): takes no input, drawn as disabled'),
  'disabled': UniversalWord(UniversalKind.flag, 'takes no input, drawn as disabled (enabled={!…})', of: 'enabled'),
  'readonly': UniversalWord(UniversalKind.flag, 'shows its value and takes no input', on: {'control'}),
  'readOnly': UniversalWord(UniversalKind.flag, 'shows its value and takes no input', on: {'control'}, of: 'readonly'),
  'required': UniversalWord(UniversalKind.flag, 'its label marked, and an input checks it is not empty', on: {'control'}),
  'autofocus': UniversalWord(UniversalKind.flag, 'has the keyboard\'s focus when the page opens', on: {'control'}),
  // On a list: the line whose lines come from an each.
  'reorder': UniversalWord(UniversalKind.flag, 'its rows are dragged (or moved by Alt and the arrows) into a new order', on: {'container'}),
  'sortable': UniversalWord(UniversalKind.flag, 'reorder', on: {'container'}, of: 'reorder'),
  'reorderable': UniversalWord(UniversalKind.flag, 'reorder', on: {'container'}, of: 'reorder'),
  'handle': UniversalWord(UniversalKind.flag, 'with reorder: its rows are dragged by their Handle', on: {'container'}),
  'onReorder': UniversalWord(UniversalKind.event, 'after a move: result is the list in its new order', on: {'container'}),
  'selectable': UniversalWord(UniversalKind.flag,
      'its rows are chosen: a tap alone, Ctrl or Cmd adds, Shift takes a range, Ctrl or Cmd A all; kept in bind=list',
      on: {'container'}),
  'onSelect': UniversalWord(UniversalKind.event, 'after the selection changes: result is the selection', on: {'container'}),
  'removable': UniversalWord(UniversalKind.flag, 'a small x that fires onRemove'),
  'onRemove': UniversalWord(UniversalKind.event, 'its x was pressed (or Delete on a chip)'),
  'onDelete': UniversalWord(UniversalKind.event, 'onRemove', of: 'onRemove'),
};

/// Whether [word] (a key, a bare word or an event) is a word every line
/// understands.
bool isUniversal(String word) => notationUniversal.containsKey(word);

/// The universal words of note 21 (not the grammar's own).
Iterable<String> get universalWords => notationUniversal.entries.where((e) => !e.value.grammar).map((e) => e.key);
