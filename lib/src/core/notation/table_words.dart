// The table word of the compact notation: a finished table of records.
//
//   Table#people p in shown columns=["Name",{"key":"email","label":"Email","w":240},{"key":"seats","label":"Seats","align":"end"}] select=@sel sort=@sortKey
//     Row gap=8                  the first column's cell (each line under the table is the next column's)
//       Avatar "{p.name}" size=28
//       Text "{p.name}"
//                                columns with no line show their key's value
//
// is written out as the plain lines a careful hand would write: a frame
// (the theme's surface, a hairline on every side, rounded corners that clip
// its rows), a header row (labels in the caption's ink on the band's fill,
// a rule under it, kept in view while the page scrolls), and a row per
// record (a rule under each, the band's fill under the pointer), each cell
// as wide as its column says (`grow` when it says none). With `sort=@name`
// a header press sorts by its column (again: the other way), with an arrow
// on the column sorted and a quiet mark on the others; with `select=@name`
// a column of checkboxes leads (the header's picks every row, or none) and
// the rows are chosen as a selectable list's are (Shift takes a range,
// Ctrl or Cmd adds). `compact` makes the rows denser; `h=` gives the table
// a height its rows scroll in; `empty="…"` is said when there are none.
part of 'page_words.dart';

/// One column of a [Table] line.
final class _TableColumn {
  _TableColumn(this.key, this.label, {this.width, this.align = '', this.sort = true, this.hide = '', this.phoneWidth});

  /// The width it narrows to on a phone to keep its place there, or null.
  final num? phoneWidth;

  final String key, label;

  /// A number (pixels) or null: the column grows.
  final num? width;

  /// `end` or `center` (numbers sit at the end), else ''.
  final String align;
  final bool sort;

  /// The widths it is left out at (`"hide":"phone"`, `"hide":"tablet"`: a
  /// tablet and a phone), as `hide=` says on a line; '' at none.
  final String hide;

  bool get numeric => align == 'end';

  /// The words a cell of it takes on its Row.
  String get size => '${width == null ? ' grow' : ' w=${width is int || width == width!.roundToDouble() ? width!.round() : width}'}${align.isEmpty ? '' : ' $align'}${hide.isEmpty ? '' : ' hide=$hide'}${phoneWidth == null || hide.isNotEmpty ? '' : ' phone.w=${phoneWidth!.round()}'}';

  static String _keyOf(String label) {
    final words = label.trim().split(RegExp(r'[^A-Za-z0-9]+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return label;
    return [
      words.first.toLowerCase(),
      for (final w in words.skip(1)) '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
    ].join();
  }

  static _TableColumn? of(Object? v) {
    if (v is String) return _TableColumn(_keyOf(v), v);
    if (v is! Map) return null;
    final label = v['label'] is String ? v['label'] as String : (v['key'] is String ? v['key'] as String : '');
    final key = v['key'] is String ? v['key'] as String : _keyOf(label);
    final w = v['w'] ?? v['width'];
    var align = v['align'] is String ? v['align'] as String : '';
    if (align == 'right') align = 'end';
    if (align == 'left' || align == 'start') align = '';
    if (v['numeric'] == true) align = 'end';
    final hide = v['hide'] is String && const {'phone', 'tablet'}.contains(v['hide']) ? v['hide'] as String : '';
    return _TableColumn(key, label, width: w is num ? w : null, align: align, sort: v['sort'] != false, hide: hide);
  }
}

/// A Table line being written out: what its cells and its close need.
final class _Table {
  _Table(this.columns, {required this.item, required this.list, required this.at, required this.select, required this.rowsAt});

  final List<_TableColumn> columns;

  /// The name each record is read by, and the rows shown (sorted when the
  /// table sorts).
  final String item, list;

  /// Where the table's frame line is, and where a row's cells go.
  final int at, rowsAt;

  /// The selection variable, or null.
  final String? select;

  /// The cells written so far.
  int cells = 0;

  /// The lines of its rows (their column, the each, the row), until they
  /// are written: at its first cell, or where it closes. A `slot caption`
  /// before them is between the header and the rows.
  List<PageLine>? body;

  /// The line a `slot caption` block's lines go under.
  String captionLine = '';

  /// What the table says when it has no rows ('' none).
  String empty = '';

  String? emptyVariant;
}

extension on PageWords {
  /// The variant of a header's label and of a quiet note: the theme's
  /// caption (its muted ink), else none.
  String get _muted => textVariants.contains('caption') ? '.caption' : (textVariants.contains('muted') ? '.muted' : '');

  /// The plain lines of `Table…` at [at]; the table to keep on its line, or
  /// null when the line is not a table (no `… in …` and no `rows=`).
  ///
  /// [flush]: the table is under a frame written `flush`, or is written
  /// `flush` itself. Its place is its frame: it draws no border, corners
  /// or ground of its own, only its header's band and the rules between
  /// its rows (a border inside a border was two rules under the frame's
  /// head and down its sides).
  (List<PageLine>, _Table)? _tableLines(int at, String mark, String rest, {bool flush = false}) {
    final parts = _Parts(rest);
    var item = 'row';
    String? list;
    // `Table p in people`, or `Table rows={people}`.
    final tokens = parts._tokens;
    if (tokens.length >= 3 && tokens[1] == 'in' && RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(tokens[0])) {
      item = tokens[0];
      list = tokens[2];
      tokens.removeRange(0, 3);
    } else if (parts.take('rows') case final String rows) {
      list = rows.startsWith('{') && rows.endsWith('}') ? rows.substring(1, rows.length - 1) : rows;
    }
    if (list == null) return null;
    final written = parts.take('columns') ?? parts.take('cols');
    final columns = <_TableColumn>[];
    if (written != null) {
      try {
        final decoded = jsonDecode(written);
        if (decoded is List) columns.addAll(decoded.map(_TableColumn.of).nonNulls);
      } on FormatException {
        // Left empty: the cells written still lay out, as columns that grow.
      }
    }
    final compact = parts.word('compact') | parts.word('dense');
    flush = parts.word('flush') || parts.take('flush') == 'true' || flush;
    final comfortable = parts.word('comfortable');
    String? variable(String? v) => v == null ? null : (v.startsWith('@') ? v.substring(1) : v);
    final select = variable(parts.take('select') ?? parts.take('selected'));
    // A page written for a desktop: the columns a tablet's or a phone's row
    // has no room for are left out there (reflow leaves a table as written).
    if (menu && !parts.has('w')) _fitColumns(columns, select: select != null);
    final sort = variable(parts.take('sort') ?? parts.take('sortBy'));
    final empty = parts.take('empty');
    final height = parts.take('h');
    final stickyOff = parts.take('sticky') == 'false';
    parts.word('sticky');
    // What a row does: the events and the menu written on the Table's line
    // are its rows' (`Table m in members … onTap={sel=m.id} menu=rowMenu`),
    // each reading its record by the Table's name, as the line under an
    // each does. (A frame does nothing by itself; how far the rows of a
    // table with a height have scrolled is its own, onScroll.)
    final rowWords = [
      for (final t in parts._tokens.toList())
        if (RegExp(r'^(?:on(?!Scroll)[A-Z][A-Za-z0-9]*(?:\([^()]*\))?|menu)=').hasMatch(t) && parts._tokens.remove(t)) t,
    ];
    final rowH = compact ? 36 : (comfortable ? 52 : 44);
    final headH = compact ? 32 : 40;
    final head = band ?? siteFill ?? _headBand;
    final shown = sort == null ? list : "sortBy($list, replace($sort, '-', ''), startsWith($sort, '-') ? 'desc' : 'asc')";
    final id = mark.contains('#') ? mark.substring(mark.indexOf('#') + 1) : null;
    String sub(String name) => id == null ? '' : '#$id-$name';
    const keyOf = 'coalesce(x.id, x)';
    final out = <PageLine>[
      // `keep`: reflow leaves a table as written (it laid its header and its
      // rows out apart, the header no longer over its columns at a tablet's
      // width: test 9, kanban 8); a column says where it is left out
      // (`"hide":"phone"`).
      (indent: at, text: 'Column$mark w=fill${flush ? '' : ' fill=$surface border=$line radius=8 clip=antiAlias'} keep${height == null ? '' : ' h=$height'}${parts.all}'),
      // The header: labels in the caption's ink on the band's fill.
      (indent: at + 2, text: 'Row${sub('head')} w=fill h=$headH pad=[16,0,16,0] gap=16 fill=$head border-bottom=$line${stickyOff || height != null ? '' : ' sticky=0'}'),
      if (select != null) ...[
        (indent: at + 4, text: 'Row w=16'),
        (
          indent: at + 6,
          text: 'Checkbox compact=true tristate=true w=16 h=16 tooltip="Select all" '
              'value={length($select) > 0 && length($select) == length($shown) ? true : (length($select) == 0 ? false : null)} '
              'onChange={$select=(length($select) == length($shown) ? [] : map($shown, x => $keyOf))}',
        ),
      ],
      for (final c in columns) ...[
        if (sort != null && c.sort)
          (
            indent: at + 4,
            text: 'Row${c.size} gap=4 onTap={$sort=($sort == "${c.key}" ? "-${c.key}" : "${c.key}")}',
          )
        else
          (indent: at + 4, text: 'Row${c.size} gap=4'),
        (indent: at + 6, text: 'Text$_muted ${PageWords._json(c.label)} size=12 weight=600 maxLines=1'),
        if (sort != null && c.sort) ...[
          (
            indent: at + 6,
            text: "Icon \"{$sort == '-${c.key}' ? 'arrow_downward' : 'arrow_upward'}\" size=14 color=${accentName ?? accent} "
                "visible={replace($sort, '-', '') == '${c.key}'}",
          ),
          (indent: at + 6, text: "Icon \"unfold_more\" size=14 opacity=0.4 visible={replace($sort, '-', '') != '${c.key}'}"),
        ],
      ],
    ];
    final body = <PageLine>[
      // The rows.
      (indent: at + 2, text: 'Column${sub('body')} w=fill${height == null ? '' : ' grow scroll'}${select == null ? '' : ' selectable selected=@$select'}'),
      (indent: at + 4, text: 'each $item in $shown'),
      (
        indent: at + 6,
        // A chosen row is tinted with the accent (a selectable list's row is
        // in its `selected` state). Under a theme's names it is the theme's
        // selected tint (`activeTint`), which follows dark mode. A theme
        // that names a chosen row's fill (`selectedRow`) has that: its
        // ticked box is the accent's mark.
        text: 'Row${sub('row')} w=fill minHeight=$rowH pad=[16,6,16,6] gap=16 border-bottom=$line hovered.fill=$head'
            '${select == null ? '' : ' selected={contains($select, coalesce($item.id, $item))} selected.fill=${selectedRow ?? (selectedFill.startsWith('#') || selectedFill == 'subtleFill' ? _mix(surface, accent, .1) : selectedFill)}'}'
            '${rowWords.isEmpty ? '' : ' ${rowWords.join(' ')}'}',
      ),
      if (select != null) ...[
        (indent: at + 8, text: 'Row w=16'),
        (indent: at + 10, text: 'Checkbox compact=true w=16 h=16 value={contains($select, coalesce($item.id, $item))} ignorePointer=true focusable=false'),
      ],
    ];
    final table = _Table(columns, item: item, list: shown, at: at, select: select, rowsAt: at + 8)
      ..empty = empty ?? ''
      ..emptyVariant = _muted
      ..body = body
      ..captionLine = 'Row${sub('caption')} w=fill pad=[16,8,16,8] gap=8 middle border-bottom=$line';
    return (out, table);
  }

  /// Leaves out, at a tablet's and at a phone's width, the columns the row
  /// has no room for there, from the last back: what a desktop's table
  /// keeps beside its first column (its name, which grows) when the window
  /// narrows. At 390 the first column had no width left and its names were
  /// cut to nothing while the columns after it kept theirs (track C: three
  /// of ten builds). The first column, the row's checkbox and a narrow
  /// column with no label (a row's menu button) stay. A column the writer
  /// leaves out at a width (`"hide":"phone"`) is out there; of the others,
  /// those that still have no room beside the column that grows are too
  /// (one column hidden by hand and three kept left the names no width).
  void _fitColumns(List<_TableColumn> columns, {required bool select}) {
    if (columns.length < 2) return;
    // The room a row has: a tablet's window (834) less the app's sidebar
    // there (a rail, or as wide as written) and a page's padding, a phone's
    // less its padding (390 − 32).
    for (final (width, room, growLeast) in [('tablet', 834 - 64 - _sideAtTablet, 160), ('phone', 358.0, 110)]) {
      bool out(_TableColumn c) => c.hide == 'tablet' || (width == 'phone' && c.hide == 'phone');
      const gap = 16, pad = 32;
      final shown = [for (final c in columns) if (!out(c)) c];
      num used = pad + (select ? 16 + gap : 0) + gap * (shown.length - 1);
      final data = <int>[];
      final grower = columns.indexWhere((c) => c.width == null && !out(c));
      for (var i = 0; i < columns.length; i++) {
        final c = columns[i];
        if (out(c)) continue;
        final action = c.label.trim().isEmpty && (c.width ?? 99) <= 48;
        if (i == 0 || i == grower) {
          used += c.width ?? growLeast;
        } else if (action) {
          used += c.width!;
        } else {
          data.add(i);
        }
      }
      var full = false;
      for (final i in data) {
        final need = columns[i].width ?? 90;
        // On a phone a wide column of data (150 and up: words, not a
        // figure or a status) narrows to 90 before it is left out.
        final least = width == 'phone' && need >= 150 ? 90 : need;
        if (!full && used + need <= room) {
          used += need;
        } else if (!full && used + least <= room) {
          final c = columns[i];
          columns[i] = _TableColumn(c.key, c.label, width: c.width, align: c.align, sort: c.sort, hide: c.hide, phoneWidth: room - used);
          used = room;
        } else {
          full = true;
          used -= gap;
          final c = columns[i];
          columns[i] = _TableColumn(c.key, c.label, width: c.width, align: c.align, sort: c.sort, hide: width);
        }
      }
    }
  }

  /// The wrapper of the next cell written under [t] (the line itself goes
  /// two further in).
  List<PageLine> _cellLine(_Table t) {
    final c = t.cells < t.columns.length ? t.columns[t.cells] : null;
    t.cells++;
    final body = t.body ?? const <PageLine>[];
    t.body = null;
    return [...body, (indent: t.rowsAt, text: 'Row${_role('cell')}${c?.size ?? ' grow'} gap=8')];
  }

  /// What closes a table: the cells no line was written for (their key's
  /// value), and what it says with no rows.
  List<PageLine> _tableClose(_Table t) => [
        ...?t.body,
        for (final c in t.columns.skip(t.cells)) ...[
          (indent: t.rowsAt, text: 'Row${c.size}'),
          (
            indent: t.rowsAt + 2,
            text: 'Text "{${t.item}.${c.key}}" maxLines=1 overflow=ellipsis${c.numeric ? ' tabularFigures=true' : ''}',
          ),
        ],
        if (t.empty.isNotEmpty) ...[
          (indent: t.at + 2, text: 'if length(${t.list}) == 0'),
          (indent: t.at + 4, text: 'Column w=fill pad=32 center'),
          (indent: t.at + 6, text: 'Text${t.emptyVariant ?? ''} ${t.empty}'),
        ],
      ];
}

/// [over] at [t] over [base] (both `#AARRGGBB`), opaque: a tint that hides
/// what is under it (a selectable list's own selected fill).
String _mix(String base, String over, double t) {
  int? channel(String c, int i) => c.length == 9 && c.startsWith('#') ? int.tryParse(c.substring(3 + i * 2, 5 + i * 2), radix: 16) : null;
  final out = StringBuffer('#FF');
  for (var i = 0; i < 3; i++) {
    final a = channel(base, i) ?? 255, b = channel(over, i) ?? 37;
    out.write((a + (b - a) * t).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase());
  }
  return out.toString();
}
