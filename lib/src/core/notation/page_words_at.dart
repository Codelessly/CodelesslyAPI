// The page words beside a design at a width (docs/design/24-a-design-at-a-
// width.md, at_width.dart): a block written under a frame they write out is
// passed by, its lines the frame's children at that width, not what the
// frame does with its own lines.
part of 'page_words.dart';

/// What [PageWordsAt.passBy] gives: the lines the frame still had to write
/// before the block, why the block is not read there, and whether every node
/// the frame holds is its own lines (a Table's header and rows).
typedef PagePass = ({List<PageLine> lines, String? refused, bool wholeFrame});

extension PageWordsAt on PageWords {
  /// An `at` block written at [indent] under the frame open above it:
  ///
  /// - a Table: its cells end (the columns with no line, what it says with
  ///   no rows), and the block's lines go in its frame, beside its header
  ///   and its rows, which are its own lines;
  /// - a website's Nav (or Header, TopBar): its lines are not repeated in a
  ///   menu of its own on a phone, where the block is the bar instead. A
  ///   block that does not hold on a phone ([phone] false) is not read: the
  ///   phone is where the Nav's own menu is;
  /// - an app's first Sidebar: its drawer is the sidebar as its own lines
  ///   write it, not the block's.
  ///
  /// Under a sidebar written as a design system's rail ([railFolds]) the
  /// block's lines are what its part shows where it holds ([holds] says so
  /// of a window's width and height): at a tablet's width they are the
  /// lines that must fold, in place of the part's own; a block that does
  /// not hold there is not read for it.
  PagePass passBy(int indent, {required bool phone, bool Function(num width, num height)? holds}) {
    final i = _open.lastIndexWhere((l) => l.indent < indent);
    if (i < 0) return (lines: const [], refused: null, wholeFrame: false);
    final l = _open[i];
    final side = _open.take(i + 1).where((o) => o.rail).lastOrNull;
    if (side != null && holds != null) {
      if (side.railSkip case final int from when indent <= from) side.railSkip = null;
      if (side.railSkip == null) {
        final at = [for (final w in PageWords._tablets) holds(w.$1, w.$2)];
        if (!at.contains(true)) {
          side.railSkip = indent;
        } else if (!at.contains(false)) {
          side.railBreaks = identical(l, side) ? 0 : l.breaksBefore;
        }
      }
    }
    _Line again({int? shift}) => _Line(l.indent, l.frame, before: l.before, shift: shift ?? l.shift, after: l.after)
      ..hero = l.hero
      ..rail = l.rail
      ..railBreaks = l.railBreaks
      ..railSkip = l.railSkip
      ..breaksBefore = l.breaksBefore;
    if (l.table case final _Table t) {
      // Its lines go in its frame, beside its header and its rows.
      _open[i] = again(shift: 0);
      return (lines: _tableClose(t), refused: null, wholeFrame: true);
    }
    if (l.pageNav) {
      if (!phone) {
        return (
          lines: const [],
          refused: 'a block under a Nav is read where it holds on a phone (at phone, at tablet): there it is the bar, instead of the Nav\'s own menu. The Nav\'s design on a desktop is its own lines.',
          wholeFrame: false,
        );
      }
      _open[i] = again();
      return (lines: const [], refused: null, wholeFrame: false);
    }
    if (_sidebarAt == l.indent) _sidebarAt = null;
    return (lines: const [], refused: null, wholeFrame: false);
  }
}
