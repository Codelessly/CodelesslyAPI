// The page words of the compact notation: the frames of a desktop page.
//
// On a phone a UI is one card, and the card is the frame: it owns the width,
// the padding and how its blocks stack. On a desktop there are two frames a
// model would otherwise build from rows and boxes, and get the sizes wrong:
//
//   Page                      a website page: scrolls, its sections stack
//     Nav                     the bar across the top: ends apart
//     Section                 a full-width band; its content in a centered column
//     Footer                  the band that closes the page
//
//   App                       an app window: panes side by side, as tall as the window
//     Sidebar                 a fixed-width pane (navigation)
//     Main                    the pane that takes the room left, and scrolls
//       Nav                   its top bar
//     Pane w:320              a further fixed-width pane (a list, details)
//
// and three small parts: `NavItem "Orders" icon:"inbox" selected` (a line of
// a sidebar), `Link "Docs"` and `Heading "Title"`.
//
// Each is written out as the plain lines it stands for (a Column, a Row, a
// Text), before the notation reads them: the sizes, the content width and
// the scrolling are the frame's, and nothing else of the notation changes.
import 'dart:math' as math;

/// A line to read in place of the one written: its indent and its text.
typedef PageLine = ({int indent, String text});

/// Rewrites page words into plain notation lines, a line at a time (the
/// notation is read as it streams).
final class PageWords {
  PageWords({
    this.contentWidth = 1120,
    this.narrowWidth = 720,
    this.sidebarWidth = 248,
    this.sectionPad = 64,
    this.gutter = 24,
    this.band,
    this.siteFill,
    this.paneFill,
    this.accentName,
    this.accentText,
    this.iconTile,
    this.accent = '#FF2563EB',
    this.selectedFill = '#FFE5E7EB',
    this.line = '#FFE5E7EB',
    this.textVariants = const {},
    this.isComponent = _none,
    this.isFrame = _none,
    this.roles = false,
    this.menu = false,
    this.sidebarMenu,
    this.surface = '#FFFFFFFF',
    this.viewer,
    this.takesViewer = _none,
  });

  static bool _none(String _) => false;

  /// The widest a section's content gets, and a `narrow` section's.
  final double contentWidth, narrowWidth;
  final double sidebarWidth;

  /// A section's padding above and below, and a page's side gutter.
  final double sectionPad, gutter;

  /// A tinted section's fill, what a website page is drawn on, and the fill
  /// of an app's sidebar and top bar; null: none is written.
  final String? band, siteFill, paneFill, iconTile;

  /// The accent as the theme names it (a selected item's ink); null: [accent].
  final String? accentName;
  final String? accentText;

  /// Colors, as the notation takes them (`#AARRGGBB`).
  final String accent, selectedFill, line;

  /// The names `Text.<name>` takes: a heading picks the first it finds.
  final Set<String> textVariants;

  /// Whether a design system has a component of this name (its `Sidebar`
  /// with `items:` is that component, not a pane).
  final bool Function(String name) isComponent;

  /// Whether a design system's component of this name takes children (its
  /// `Dialog` frames a dialog's content).
  final bool Function(String name) isFrame;

  /// Whether a frame's line says which frame it is, after its type
  /// (`Row~nav`, `Column~section`, `Row~app`, `Column~sidebar`, `Column~main`,
  /// `Column~pane`): what lays a page out at other widths reads it, and
  /// takes it off before the line is read.
  final bool roles;

  /// Whether a website's `Nav` gets a menu for a phone: a button at its
  /// end, shown where its links are not, that opens them in a column under
  /// the bar (the links as written, each closing the menu as it goes). A
  /// Nav that writes a `show:phone` or `show:tablet` line has its own.
  final bool menu;

  /// The id of the drawer an app's `Sidebar` opens in where the window is
  /// too narrow to show it (a phone): its lines are kept ([sidebar]) and the
  /// top bar of `Main` gets a menu button, shown there only, that opens it.
  /// Null: none.
  final String? sidebarMenu;

  /// What a drawer's panel is drawn on when the theme names no pane fill.
  final String surface;

  /// The id of the lightbox a design system's gallery opens its photos in
  /// on a page (a component [takesViewer] names: it has `photos` and
  /// `viewer:"overlay"`), so its large view is over the window and not in
  /// the page's flow. Its line is given `viewer:"overlay"` and, after its
  /// own actions, sets `<id>Photos` and `<id>At` and opens the lightbox,
  /// which is written once at the end of the text ([viewerUsed]). Null: a
  /// gallery is left as written (a card).
  final String? viewer;
  final bool Function(String name) takesViewer;

  /// Whether a gallery's line was given the viewer, and the lists written
  /// out on such lines, by the name of the variable each was moved to.
  bool viewerUsed = false;
  final viewerLists = <String, String>{};

  /// [text], a gallery's line, opening its photos in the page's viewer.
  String _gallery(String text) {
    final id = viewer;
    final head = _head.firstMatch(text);
    if (id == null || head == null || !takesViewer(head[1]!)) return text;
    final parts = _Parts(text.substring(head.end));
    // One photo at a time in place is paged where it is; a line that says
    // how it opens is left as it is.
    if (parts.has('viewer') || parts.value('layout')?.replaceAll('"', '') == 'pages' || parts.hasWord('pages')) return text;
    final written = parts.value('photos');
    if (written == null) return text;
    var list = written.startsWith('=') ? written.substring(1) : written;
    if (list.startsWith('{') && list.endsWith('}')) list = list.substring(1, list.length - 1);
    if (list.startsWith('[')) {
      // A list written out is kept once, for the gallery and the viewer.
      final name = '${id}List${viewerLists.length + 1}';
      viewerLists[name] = list;
      text = text.replaceFirst('photos:$written', 'photos:=$name');
      list = name;
    }
    viewerUsed = true;
    final held = parts.binding();
    final opened = '${id}Photos=$list; ${id}At=result-1; open $id${held == null ? '' : '; $held=0'}';
    return withAction(text.replaceFirst(head[0]!, '${head[0]} viewer:"overlay"'), opened);
  }

  /// [text] with [action] after its own actions (a `{…}` merged into the
  /// node at the end of the line stays last).
  static String withAction(String text, String action) {
    var arrow = -1;
    for (var i = 0; i + 1 < text.length; i++) {
      if (text.startsWith('->', i) && !_inString(text, i)) {
        arrow = i;
        break;
      }
    }
    final tail = RegExp(r'\s\{"[\s\S]*\}\s*$').firstMatch(text);
    final end = tail != null && !_inString(text, tail.start) ? tail.start : text.length;
    final body = text.substring(0, end).trimRight();
    return '$body${arrow < 0 ? ' ->' : ';'} $action${text.substring(end)}';
  }

  /// An app's `Sidebar` as written: what followed the word on its line and
  /// the lines under it (each with its indent from the Sidebar's), and
  /// whether a menu button was written for it.
  String? sidebarRest;
  final sidebar = <PageLine>[];
  bool sidebarButton = false;
  int? _sidebarAt;
  int _panesBefore = 0;
  double _widthBefore = 0;
  bool _mainSeen = false;
  int? _mainAt;

  /// Where the sidebar's button shows: on a phone, and on a tablet too when
  /// the window drops the first of two panes there.
  String get _menuSize => _panesBefore >= 2 && _widthBefore > 420 ? 'tablet' : 'phone';

  static final _overlayHead = RegExp(r'^(Dialog|Modal|Sheet|BottomSheet|Drawer|Menu|Dropdown|Popover|Popup|Lightbox)#([A-Za-z_][A-Za-z0-9_]*)(?=\s|$)');

  /// The overlay a top-level line opens (`Dialog#signup "Join"`,
  /// `Sheet#filters`, `Drawer#menu`, `Menu#more`, `Popover#tip`,
  /// `Lightbox#zoom`), or null: the lines under it are a canvas of their
  /// own, shown over the page by `-> open <id>`.
  Overlay? overlay(String text) {
    final head = _overlayHead.firstMatch(text);
    if (head == null) return null;
    // A design system's component of the word's name that is no frame (a
    // Menu called with its items) is that component, as anywhere.
    if (isComponent(head[1]!) && !isFrame(head[1]!)) return null;
    final id = head[2]!;
    final parts = _Parts(text.substring(head.end));
    final width = double.tryParse(parts.take('w') ?? '');
    final title = parts.string(), note = parts.string();
    final heading = _variant(const ['heading', 'heading3', 'sectionTitle', 'strong']);
    // What heads a dialog or a sheet: its title, a close button, a line under it.
    List<PageLine> titled() => [
          if (title != null) (indent: 2, text: 'Row w:fill between middle gap:12'),
          if (title != null) (indent: 4, text: 'Text${heading == null ? '' : '.$heading'} $title grow'),
          if (title != null) (indent: 4, text: 'IconButton "close" -> close'),
          if (note != null) (indent: 2, text: 'Text${textVariants.contains('muted') ? '.muted' : ''} $note'),
        ];
    switch (head[1]!) {
      case 'Dialog' || 'Modal':
        const action = <String, Object?>{
          'presentation': 'dialog',
          'insets': [16, 24, 16, 24],
        };
        // A design system's own dialog frame (its title, its close button) is the dialog.
        if (isFrame('Dialog')) {
          return Overlay('dialog', id, width ?? 480, action, [
            (indent: 0, text: 'Dialog${title == null ? '' : ' $title'}${note == null ? '' : ' $note'}${parts.props}${parts.action ?? ' -> close'}'),
          ], surface: false);
        }
        final pad = parts.take('pad') ?? '24', gap = parts.take('gap') ?? '16';
        return Overlay('dialog', id, width ?? 480, action, [(indent: 0, text: 'Column w:fill pad:$pad gap:$gap${parts.all}'), ...titled()], radius: 16);
      case 'Sheet' || 'BottomSheet':
        final pad = parts.take('pad') ?? '[20,8,20,24]', gap = parts.take('gap') ?? '16';
        final w = width ?? 560;
        return Overlay(
          'sheet',
          id,
          w,
          {'presentation': 'bottomSheet', 'sheetWidth': w, 'sheetRadius': 20, 'showDragHandle': true, 'maxHeightFactor': 0.9},
          [(indent: 0, text: 'Column w:fill pad:$pad gap:$gap${parts.all}'), ...titled()],
        );
      case 'Drawer':
        // A panel as tall as the window at its side; a tap beside it closes it.
        final right = parts.word('right') | parts.word('end');
        parts.word('left');
        final w = width ?? 300;
        final pad = parts.take('pad') ?? '[16,20,16,16]', gap = parts.take('gap') ?? '12';
        const beside = (indent: 2, text: 'Box grow h:fill -> close');
        return Overlay(
          'drawer',
          id,
          390,
          const {'presentation': 'dialog', 'cover': true},
          [
            (indent: 0, text: 'App'),
            if (right) beside,
            (indent: 2, text: 'Sidebar w:${_n(w)} pad:$pad gap:$gap${parts.has('fill') || paneFill != null ? '' : ' fill:$surface'}${parts.all}'),
            if (title != null) (indent: 4, text: 'Text${heading == null ? '' : '.$heading'} $title'),
          ],
          shift: 2,
          foot: [if (!right) beside],
          surface: false,
          closes: 'nav',
        );
      case 'Menu' || 'Dropdown' || 'Popover' || 'Popup':
        final menu = head[1] == 'Menu' || head[1] == 'Dropdown';
        final above = parts.word('above') | parts.word('up');
        final end = parts.word('end') | parts.word('right');
        final center = parts.word('center');
        parts.word('below');
        parts.word('start');
        final placement = parts.take('placement') ?? '${above ? 'above' : 'below'}${end ? 'End' : center ? 'Center' : 'Start'}';
        final action = <String, Object?>{'presentation': 'popover', 'anchor': 'trigger', 'placement': placement, 'anchorGap': 6};
        if (menu && isFrame('MenuPopover')) {
          return Overlay('menu', id, width ?? 228, action, [(indent: 0, text: 'MenuPopover${title == null ? '' : ' $title'}${parts.all}')], surface: false, closes: 'all');
        }
        final pad = parts.take('pad') ?? (menu ? '6' : '16'), gap = parts.take('gap') ?? (menu ? '2' : '12');
        return Overlay(
          menu ? 'menu' : 'popover',
          id,
          width ?? (menu ? 220 : 320),
          action,
          [
            (indent: 0, text: 'Column w:fill pad:$pad gap:$gap${parts.all}'),
            if (title != null) (indent: 2, text: 'Text${textVariants.contains('caption') ? '.caption' : ''} $title${menu ? ' pad:[8,6,8,2]' : ''}'),
            if (note != null) (indent: 2, text: 'Text${textVariants.contains('muted') ? '.muted' : ''} $note'),
          ],
          radius: 12,
          outlined: true,
          closes: menu ? 'all' : 'none',
        );
      default:
        return _lightbox(id, parts, title, note);
    }
  }

  /// A picture, or a list of them, shown large over the page
  /// (`Lightbox#zoom "{photo}" "Caption"`, `Lightbox#zoom photos:=photos
  /// =at`): the picture contained in the window on a dark scrim, zoomed by
  /// a pinch, the wheel and a double tap (to 2x where it was tapped, and
  /// back), panned while zoomed and kept inside the window; closed by its
  /// button, Escape, a tap on the scrim and a drag down. A list is paged by
  /// a swipe, the arrows and the arrow keys, with a count and a strip of
  /// thumbnails; `=at` is the picture shown, from 0. The lines written under
  /// a list draw one picture (`photo` is the element) in place of an Image
  /// of its `url`.
  Overlay _lightbox(String id, _Parts parts, String? title, String? note) {
    final written = parts.take('photos') ?? parts.take('images') ?? parts.take('items');
    final thumbs = (parts.take('thumbs') ?? 'true') != 'false';
    final max = num.tryParse(parts.take('max') ?? '') ?? 4;
    final zoom = '${id}Zoom';
    final variables = <String, Object?>{zoom: 1.0};
    final still = '$zoom<=1.01';
    const white = '#FFFFFFFF', pill = '#8C000000', pillOver = '#BF000000';
    String tail(Map<String, Object?> json) => ' ${_json(json)}';
    Map<String, Object?> at(Map<String, Object?> x, Map<String, Object?> y) => {'x': x, 'y': y};
    Map<String, Object?> fill(String color) => {
          'fills': [
            {'color': color},
          ],
        };
    // The picture's place: the window, clear of the bars. What zooms is the
    // picture's own box in it, kept over the window as a zoomed photo is
    // (no gap where it is larger, centered where it is smaller). The box has
    // the picture's proportions where they are known: `ratio:` on the line,
    // a `ratio` in a record of the list, a design system's drawn scene.
    final given = num.tryParse(parts.take('ratio') ?? '') ?? 0;
    final scenes = written != null && isComponent('Media');
    final ratio = written == null
        ? '$given'
        : 'coalesce(item.ratio, ${scenes ? 'coalesce(item.kind, "") != "" ? 1.5 : $given' : '$given'})';
    // The picture shown (a list's), from 0: the line's variable, or its own.
    final current = written == null ? null : (parts.binding() ?? '${id}At');
    final below = written == null ? (note == null ? 64 : 80) : (thumbs ? 144 : 80);
    List<PageLine> photo(int indent) => [
          (
            indent: indent,
            text: 'Stack w:fill h:fill center middle pad:[72,64,72,$below]${tail({
              'media': [
                {
                  'maxWidth': 699,
                  'patch': {
                    'layout': {
                      'padding': [0, 64, 0, below],
                    },
                  },
                },
              ],
            })}',
          ),
          (
            indent: indent + 2,
            text: 'Stack#${id}Photo w:fill h:fill center middle${tail({
              'transformGesture': {'target': 'node', 'pan': 'whenZoomed', 'minScale': 1, 'maxScale': max, 'doubleTapScale': 2, 'wheel': 'zoom', 'bounds': 'cover'},
              'bind': {'layout.aspectRatio': '\${= $ratio}'},
              'actions': [
                // The zoom of the picture in view (one left behind as the page
                // turns settles unseen).
                {
                  'trigger': {'type': 'changed', if (current != null) 'when': '\${= index == $current}'},
                  'actions': [
                    {'type': 'setVariable', 'variable': zoom, 'value': r'${= round(result.scale, 2)}'},
                  ],
                },
                // A tap on the picture itself leaves it open; where its box
                // may be wider than the picture, a tap is one on the scrim.
                {
                  'trigger': {'type': 'click', 'when': '\${= ($ratio) <= 0 && $still}'},
                  'actions': [
                    {'type': 'closeModal'},
                  ],
                },
              ],
            })}',
          ),
        ];
    PageLine round(String name, double size, String action, Map<String, Object?> place, {String? visible, bool wide = false}) => (
          indent: 4,
          text: 'Row#$id$name w:${_n(size)} h:${_n(size)} center middle radius:${_n(size / 2)}${visible == null ? '' : ' visible:=$visible'} -> $action${tail({
            'layout': place,
            'decoration': fill(pill),
            'states': {
              'hovered': {
                '$id$name': {'decoration': fill(pillOver)},
              },
            },
            if (wide)
              'media': [
                {
                  'maxWidth': 699,
                  'patch': {
                    'visible': false,
                    'bind': {'visible': null},
                  },
                },
              ],
          })}',
        );
    PageLine glyph(String name, double size) => (indent: 6, text: 'Icon "$name"${tail({'props': {'size': size, 'color': white}})}');
    PageLine label(int indent, String text, {num size = 13, int weight = 500, String more = ''}) => (
          indent: indent,
          text: 'Text $text$more${tail({
            'props': {
              'style': {'color': white, 'fontSize': size, 'fontWeight': weight, 'height': 1.35},
            },
          })}',
        );
    Map<String, Object?> key(String name, List<Map<String, Object?>> actions, String when) => {
          'trigger': {'type': 'keyDown', 'key': name, 'when': '\${= $when}'},
          'actions': actions,
        };
    Map<String, Object?> set(String name, String value) => {'type': 'setVariable', 'variable': name, 'value': '\${= $value}'};
    // A tap on the scrim closes it while the picture is at rest; a zoom left
    // from the last time is forgotten as it opens.
    List<Map<String, Object?>> rootActions([List<Map<String, Object?>> more = const []]) => [
          {
            'trigger': {'type': 'click', 'when': '\${= $still}'},
            'actions': [
              {'type': 'closeModal'},
            ],
          },
          {
            'trigger': {'type': 'load'},
            'actions': [set(zoom, '1')],
          },
          ...more,
        ];
    const action = <String, Object?>{
      'presentation': 'dialog',
      'cover': true,
      'barrierColor': '#F2000000',
      // It fades in rising a little; a drag down takes it back the same
      // way, under the finger, and closes it past a fifth of the window.
      'routeTransition': {
        'enter': {
          'motion': {'opacity': 0, 'shiftY': 0.12},
        },
        'durationMs': 220,
        'dismiss': {'direction': 'down', 'distance': 0.2},
      },
    };
    final close = [round('Close', 40, 'close', at({'end': 16}, {'start': 16})), glyph('close', 20)];
    final zoomed = <PageLine>[
      (indent: 4, text: 'Row#${id}Scale w:hug pad:[12,6,12,6] radius:999 visible:=$zoom>1.01${tail({'layout': at({'align': 0}, {'start': 20}), 'decoration': fill(pill)})}'),
      label(6, '"{round($zoom,1)}×"', weight: 600),
    ];
    if (written == null) {
      return Overlay(
        'lightbox',
        id,
        390,
        action,
        [
          (indent: 0, text: 'Column w:fill h:fill center middle${parts.props}${tail({'actions': rootActions()})}'),
          (indent: 2, text: 'Stack#${id}Stage w:fill h:fill grow'),
          ...photo(4),
          if (title != null) (indent: 8, text: 'Image $title w:fill h:fill fit:contain'),
          if (note != null) (indent: 4, text: 'Row w:hug pad:[14,8,14,8] radius:12 visible:=$still${tail({'layout': at({'align': 0}, {'end': 20}), 'decoration': fill(pill)})}'),
          if (note != null) label(6, note, size: 14, more: ' center'),
          ...zoomed,
          ...close,
        ],
        surface: false,
        variables: variables,
      );
    }
    // A list: written out (a variable of its own), or worked out.
    var list = written.startsWith('=') ? written.substring(1) : written;
    if (list.startsWith('{') && list.endsWith('}')) list = list.substring(1, list.length - 1);
    if (list.startsWith('[')) {
      variables['${id}Photos'] = list;
      list = '${id}Photos';
    }
    final index = current!;
    variables.putIfAbsent(index, () => 0);
    final last = 'length($list)-1';
    final shown = 'at($list,clamp($index,0,max(0,$last)))';
    final caption = 'coalesce($shown.caption,$shown.title,"")';
    return Overlay(
      'lightbox',
      id,
      390,
      action,
      [
        (
          indent: 0,
          text: 'Column w:fill h:fill center middle${parts.props}${tail({
            'actions': rootActions([
              key('ArrowRight', [set(index, 'min($index+1,$last)')], '$index<$last'),
              key('ArrowLeft', [set(index, 'max($index-1,0)')], '$index>0'),
            ]),
          })}',
        ),
        (indent: 2, text: 'Stack#${id}Stage w:fill h:fill grow'),
        (
          indent: 4,
          text: 'Pages#${id}Pages =$index w:fill h:fill${tail({
            'props': {'animationDuration': 280},
            // Another picture starts at rest.
            'actions': [
              {
                'trigger': {'type': 'changed'},
                'actions': [
                  set(index, 'result.index'),
                  {'type': 'controlTransform', 'node': '${id}Photo', 'command': 'reset'},
                  set(zoom, '1'),
                ],
              },
            ],
          })}',
        ),
        (indent: 6, text: 'each photo in $list'),
        ...photo(8),
      ],
      shift: 10,
      empty: [
        if (scenes)
          (indent: 2, text: 'Media kind:=coalesce(photo.kind,"mountain") tone:=coalesce(photo.tone,"auto") w:fill h:fill visible:=coalesce(photo.kind,"")!=""${tail({'layout': {'aspectRatio': 1.5}})}'),
        (indent: 2, text: 'Image "{coalesce(photo.url,photo.src,photo.image,photo)}" w:fill h:fill fit:contain${scenes ? ' visible:=coalesce(photo.kind,"")==""' : ''}'),
      ],
      foot: [
        (indent: 4, text: 'Row#${id}Count w:hug pad:[12,6,12,6] radius:999${tail({'layout': at({'start': 16}, {'start': 20}), 'decoration': fill(pill)})}'),
        label(6, '"{clamp($index,0,max(0,$last))+1} / {length($list)}"', weight: 600),
        ...zoomed,
        ...close,
        round('Prev', 44, '$index=max($index-1,0)', at({'start': 16}, {'align': 0}), visible: '$index>0&&$still', wide: true),
        glyph('chevron_left', 26),
        round('Next', 44, '$index=min($index+1,$last)', at({'end': 16}, {'align': 0}), visible: '$index<$last&&$still', wide: true),
        glyph('chevron_right', 26),
        (
          indent: 4,
          text: 'Column#${id}Foot w:hug h:hug center gap:10 visible:=$still${tail({'layout': at({'align': 0}, {'end': 16})})}',
        ),
        (indent: 6, text: 'Row pad:[14,8,14,8] radius:12 visible:=$caption!=""${tail({'decoration': fill(pill)})}'),
        label(8, '"{$caption}"', size: 14, more: ' center'),
        if (thumbs) ...[
          (indent: 6, text: 'Row#${id}Thumbs scroll gap:6 pad:6 radius:10 visible:=length($list)>1${tail({'decoration': fill(pill)})}'),
          (indent: 8, text: 'each photo in $list'),
          (
            indent: 10,
            text: 'Stack#${id}Thumb w:64 h:48 radius:6 -> $index=index${tail({
              'decoration': {
                'clip': 'antiAlias',
                'strokes': [
                  {'color': white},
                ],
                'strokeWidth': 2,
              },
              'bind': {'opacity': '\${= index == $index ? 1 : 0.6}', 'decoration.strokeWidth': '\${= index == $index ? 2 : 0}'},
            })}',
          ),
          (indent: 12, text: Overlay.lines),
        ],
      ],
      surface: false,
      variables: variables,
    );
  }

  static String _json(Object? v) => switch (v) {
        final Map<Object?, Object?> m => '{${m.entries.map((e) => '"${e.key}":${_json(e.value)}').join(',')}}',
        final List<Object?> l => '[${l.map(_json).join(',')}]',
        final String s => '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"',
        _ => '$v',
      };

  /// [text], a line written under an overlay that closes as its lines are
  /// used ([Overlay.closes]), with `close` after its actions.
  static String closing(String text, String closes) {
    if (closes == 'none') return text;
    final t = text.trimLeft();
    if (closes == 'nav' && !RegExp(r'^(NavItem|NavLink|SidebarItem|MenuItem|Link)\b').hasMatch(t)) return text;
    var arrow = -1;
    for (var i = 0; i + 1 < text.length; i++) {
      if (text.startsWith('->', i) && !_inString(text, i)) {
        arrow = i;
        break;
      }
    }
    if (arrow < 0) return text;
    final actions = text.substring(arrow + 2);
    if (RegExp(r'(^|;)\s*close\s*(;|$)').hasMatch(actions)) return text;
    // A {…} merged into the node at the end of the line stays last.
    final tail = RegExp(r'\s\{"[\s\S]*\}\s*$').firstMatch(actions);
    if (tail != null) return '${text.substring(0, arrow + 2)}${actions.substring(0, tail.start).trimRight()}; close${actions.substring(tail.start)}';
    return '${text.trimRight()}; close';
  }

  /// What closes a frame: a bar's menu for a phone, then its rule.
  List<PageLine> _closing(_Line closed) {
    final at = closed.indent + closed.before;
    // It repeats the links the bar hides on a phone: the ones written
    // straight under the Nav and the ones in a row of two or more. A lone
    // link beside the bar's buttons stays where it is.
    final inGroup = <_Line?, int>{};
    for (final link in closed.links) {
      inGroup[link.group] = (inGroup[link.group] ?? 0) + 1;
    }
    final links = [
      for (final link in closed.links)
        if (link.direct || (inGroup[link.group] ?? 0) >= 2) link,
    ];
    // From six links on, a tablet has no room for them either.
    final size = links.length >= 6 ? 'tablet' : 'phone';
    return [
      if (menu && closed.pageNav && closed.links.isNotEmpty && !closed.ownMenu) ...[
        (indent: at + 4, text: 'Button.outline "Menu" show:$size -> navMenu=!navMenu'),
        (indent: at + 2, text: 'if navMenu'),
        (indent: at + 4, text: 'Column w:fill maxw:${_n(contentWidth)} show:$size gap:2 pad:[0,8,0,4]'),
        for (final link in links) ...[
          (indent: at + 6, text: 'Row w:fill pad:[12,10,12,10] radius:8 middle -> navMenu=false; ${link.action}'),
          (indent: at + 8, text: 'Text.strong ${link.label}'),
        ],
      ],
      if (closed.after != null) (indent: at, text: closed.after!),
    ];
  }

  String _role(String name) => roles ? '~$name' : '';

  /// The lines open above the one being read.
  final _open = <_Line>[];

  /// Whether the page's root is an app window (as tall as the window).
  bool app = false;

  static const _bars = {'Nav', 'Navbar', 'NavBar', 'TopBar', 'Topbar', 'Header', 'AppBar'};
  static const _sides = {'Sidebar', 'Aside', 'SideNav', 'Sidenav', 'Rail'};
  static const _items = {'NavItem', 'NavLink', 'SidebarItem', 'MenuItem'};
  static final _head = RegExp(r'^([A-Z][A-Za-z0-9]*)((?:\.[A-Za-z][A-Za-z0-9]*)?(?:#[A-Za-z_][A-Za-z0-9_]*)?)(?=\s|$)');

  /// The lines [text] at [indent] stands for: itself, moved under the frame
  /// it is in, or the plain lines of a page word.
  List<PageLine> rewrite(int indent, String text) {
    text = _gallery(_plain(text));
    final out = <PageLine>[];
    while (_open.isNotEmpty && _open.last.indent >= indent) {
      out.addAll(_closing(_open.removeLast()));
    }
    if (_sidebarAt case final int from) {
      if (indent > from) {
        sidebar.add((indent: indent - from, text: text));
      } else {
        _sidebarAt = null;
      }
    }
    final bar = _open.where((l) => l.pageNav).lastOrNull;
    if (bar != null && RegExp(r'\sshow:(phone|tablet|mobile)(\s|$)').hasMatch(text)) bar.ownMenu = true;
    final parent = _open.lastOrNull;
    // Where this line goes: under the lines its frames added.
    final shift = parent == null ? 0 : parent.before + parent.shift;
    final at = indent + shift;
    final head = _head.firstMatch(text);
    final word = head?[1];
    final rest = head == null ? '' : text.substring(head.end);
    final mark = head?[2] ?? '';
    // A frame is one only among frames: a Header inside a card is a row.
    final framed = parent == null || parent.frame != null;
    final root = _open.isEmpty ? null : _open.first.frame;

    _Line open({String? frame, int shift = 0, String? after}) {
      final l = _Line(indent, frame, before: at - indent, shift: shift, after: after);
      _open.add(l);
      return l;
    }

    // A Main with no top bar of its own gets a slim one where the sidebar is
    // hidden, for the button that opens it.
    if (_mainAt case final int from) {
      _mainAt = null;
      final bar = word != null && _bars.contains(word) && !isComponentCall(word, _Parts(rest));
      if (indent > from && !bar && sidebarMenu != null && sidebarRest != null && !sidebarButton) {
        sidebarButton = true;
        out
          ..add((indent: at, text: 'Row w:fill middle pad:[12,8,12,8] show:$_menuSize${paneFill == null ? '' : ' fill:$paneFill'}'))
          ..add((indent: at + 2, text: 'IconButton "menu" -> open $sidebarMenu'))
          ..add((indent: at, text: 'Divider show:$_menuSize'));
      }
    }
    // An `if` or an `each` is not a place of its own: what is under it is
    // where the line itself is.
    if (RegExp(r'^(if|each|for|else)\b').hasMatch(text)) {
      open(frame: parent?.frame);
      return out..add((indent: at, text: text));
    }
    if (word == null || text.startsWith('node ') || text.startsWith('document ')) {
      open();
      return out..add((indent: at, text: text));
    }
    final parts = _Parts(rest);
    // A text with a look of its own (a rule at its side, a fill, a corner)
    // is a box around the text: a text itself draws none.
    if (word == 'Text' && _looks(parts)) {
      open();
      return out..addAll(_textBox(at, mark, parts));
    }
    if (word == 'Page' && indent == 0) {
      open(frame: 'Page');
      final fill = parts.has('fill') || siteFill == null ? '' : ' fill:$siteFill';
      return out..add((indent: at, text: 'Column$mark w:fill scroll stretch$fill${parts.all}'));
    }
    if ((word == 'App' || word == 'AppShell' || word == 'Window') && indent == 0) {
      app = true;
      open(frame: 'App');
      return out..add((indent: at, text: 'Row${_role('app')}$mark w:fill h:fill stretch${parts.all}'));
    }
    final inApp = root == 'App' || (parent?.frame == 'Sidebar' || parent?.frame == 'Main' || parent?.frame == 'Pane');
    if (word == 'Section' || (word == 'Footer' && !inApp) || (word == 'Hero' && !isComponent('Hero'))) {
      if (!framed) {
        open();
        return out..add((indent: at, text: 'Column$mark w:fill${parts.has('gap') ? '' : ' gap:16'}${parts.all}'));
      }
      final footer = word == 'Footer';
      final bleed = parts.word('bleed');
      final width = parts.take('maxw') ?? (parts.word('narrow') ? _n(narrowWidth) : _n(contentWidth));
      parts.word('wide');
      final g = _n(gutter);
      final tight = parts.word('compact') | parts.word('tight');
      final v = _n(tight ? (sectionPad / 2).roundToDouble() : sectionPad);
      final pad = parts.take('pad') ?? (bleed ? '[0,$v,0,$v]' : footer ? '[$g,40,$g,40]' : '[$g,$v,$g,$v]');
      // A tinted band: the page's alternate ground, ruled off above and below.
      final tint = parts.word('tint') | parts.word('alt') | parts.word('band') | parts.word('muted');
      final banded = tint && band != null && !parts.has('fill') ? ' fill:$band border-top:$line border-bottom:$line' : '';
      final gap = parts.take('gap') ?? (footer ? '24' : '32');
      final inner = parts.takeWords(const {'center', 'middle', 'start', 'end', 'between', 'stretch', 'left', 'right'});
      open(frame: 'Section', shift: 2);
      if (footer) out.add((indent: at, text: 'Divider'));
      return out
        ..add((indent: at, text: 'Column${_role('section')}$mark w:fill center pad:$pad$banded${parts.all}'))
        ..add((indent: at + 2, text: 'Column w:fill${bleed ? '' : ' maxw:$width'} gap:$gap${inner.isEmpty ? '' : ' ${inner.join(' ')}'}'));
    }
    if (_bars.contains(word) && !isComponentCall(word, parts)) {
      if (!framed) {
        open();
        return out..add((indent: at, text: 'Row$mark w:fill between middle${parts.has('gap') ? '' : ' gap:16'}${parts.all}'));
      }
      final gap = parts.take('gap') ?? '24';
      if (inApp) {
        final pad = parts.take('pad') ?? '[24,14,24,14]';
        final fill = parts.has('fill') || paneFill == null ? '' : ' fill:$paneFill';
        open(frame: 'Nav', after: 'Divider');
        out.add((indent: at, text: 'Row${_role('nav')}$mark w:fill between middle pad:$pad gap:$gap$fill${parts.all}'));
        // The sidebar a phone has no room for opens from a button here
        // (a tablet too, where it drops the first of two panes).
        if (sidebarMenu != null && sidebarRest != null && !sidebarButton && parent?.frame == 'Main') {
          sidebarButton = true;
          out.add((indent: at + 2, text: 'IconButton${_role('appmenu')} "menu" show:$_menuSize -> open $sidebarMenu'));
        }
        return out;
      }
      final width = parts.take('maxw') ?? _n(contentWidth);
      final pad = parts.take('pad') ?? '[${_n(gutter)},14,${_n(gutter)},14]';
      final sticky = parts.word('sticky') ? ' sticky:0${parts.has('fill') || siteFill == null ? '' : ' fill:$siteFill'}' : '';
      open(frame: 'Nav', shift: 2, after: 'Divider').pageNav = true;
      return out
        ..add((indent: at, text: 'Column$mark w:fill center pad:$pad$sticky${parts.all}'))
        ..add((indent: at + 2, text: 'Row${_role('nav')} w:fill maxw:$width between middle gap:$gap'));
    }
    if (_sides.contains(word) && !isComponentCall(word, parts)) {
      final width = parts.take('w') ?? _n(sidebarWidth);
      final pad = parts.take('pad') ?? '[12,20,12,16]';
      final gap = parts.take('gap') ?? '4';
      open(frame: framed ? 'Sidebar' : null);
      final fill = !framed || parts.has('fill') || paneFill == null ? '' : ' fill:$paneFill';
      if (framed && root == 'App' && indent > 0 && !_mainSeen) {
        _panesBefore++;
        _widthBefore += double.tryParse(width) ?? sidebarWidth;
        // The first pane of the window is what a narrow one leaves out.
        if (sidebarMenu != null && sidebarRest == null && _panesBefore == 1) {
          sidebarRest = ' pad:$pad gap:$gap${parts.props}';
          _sidebarAt = indent;
        }
      }
      return out..add((indent: at, text: 'Column${framed ? _role('sidebar') : ''}$mark w:$width${framed ? ' h:fill' : ''} pad:$pad gap:$gap$fill${parts.hasBorder ? '' : ' border-right:$line'}${parts.all}'));
    }
    if (word == 'Main' || word == 'Content') {
      if (framed && root == 'App' && !_mainSeen) {
        _mainSeen = true;
        _mainAt = indent;
      }
      open(frame: framed ? 'Main' : null);
      return out..add((indent: at, text: 'Column${framed ? _role('main') : ''}$mark grow${framed ? ' h:fill scroll' : ''}${parts.all}'));
    }
    if (word == 'Pane' || (word == 'Panel' && inApp && !isComponent('Panel'))) {
      // Among the panes of a window it is as tall as the window and scrolls;
      // in a row further in (a list beside its details) it is a column of it.
      final width = parts.take('w');
      parts.word('scroll');
      parts.word('grow');
      if (framed && root == 'App' && !_mainSeen && width != null) {
        _panesBefore++;
        _widthBefore += double.tryParse(width) ?? 0;
      }
      open(frame: framed ? 'Pane' : null);
      return out..add((indent: at, text: 'Column${framed ? _role('pane') : ''}$mark ${width == null ? 'grow' : 'w:$width'}${framed ? ' h:fill scroll' : ''}${parts.hasBorder || !framed ? '' : ' border-right:$line'}${parts.all}'));
    }
    if (_items.contains(word) && !isComponent(word)) {
      final icon = parts.take('icon');
      final badge = parts.take('badge') ?? parts.take('count');
      final selected = parts.take('selected') ?? parts.take('active');
      final on = parts.word('selected') | parts.word('active');
      final label = parts.string();
      final ink = accentName ?? accent;
      const quiet = '#FF4B5563';
      final fill = selected != null
          ? ' fill:=${_expr(selected)}?"$selectedFill":"#00000000"'
          : on
              ? ' fill:$selectedFill'
              : '';
      // In a bar the items sit side by side; in a sidebar each takes the width.
      final across = parent?.frame == 'Nav';
      open();
      return out
        ..add((indent: at, text: 'Row$mark ${across ? '' : 'w:fill '}gap:10 middle pad:[10,8,10,8] radius:8$fill${parts.all}'))
        ..addAll([
          if (icon != null) (indent: at + 2, text: 'Icon $icon size:18${on ? ' color:$ink' : selected != null ? ' color:=${_expr(selected)}?"$ink":"$quiet"' : ' color:$quiet'}'),
          (indent: at + 2, text: 'Text ${label ?? '""'} size:14 weight:${on ? 600 : 500}${on ? ' color:$ink' : selected != null ? ' color:=${_expr(selected)}?"$ink":"$quiet"' : ''}${across ? '' : ' grow'}'),
          if (badge != null) (indent: at + 2, text: 'Text.${_variant(const ['muted', 'caption', 'small']) ?? 'muted'} $badge'),
        ]);
    }
    // A badge with a width is a table's cell: the cell has the width, the
    // badge stays as big as its label.
    // A badge's ink follows its tone: a color worked out from data is left out.
    if (word == 'Badge' && !isComponent('Badge') && parts.bound('color')) {
      parts.take('color');
      if (!parts.has('w')) {
        open();
        return out..add((indent: at, text: 'Badge$mark${parts.all}'));
      }
    }
    if (word == 'Badge' && parts.has('w') && !isComponent('Badge')) {
      final width = parts.take('w')!;
      final grow = parts.word('grow') ? ' grow' : '';
      open();
      return out
        ..add((indent: at, text: 'Row w:$width$grow'))
        ..add((indent: at + 2, text: 'Badge$mark${parts.all}'));
    }
    // The product's mark and name, at the head of a sidebar or the start of a bar.
    if ((word == 'Brand' || word == 'Logo') && !isComponent(word)) {
      final icon = parts.take('icon');
      final name = parts.string();
      final side = parent?.frame == 'Sidebar';
      open();
      return out
        ..add((indent: at, text: 'Row$mark gap:10 middle${side ? ' pad:[8,4,8,16]' : ''}${parts.all}'))
        ..addAll([
          if (icon != null) (indent: at + 2, text: 'Box w:28 h:28 radius:8 fill:$accent center middle'),
          if (icon != null) (indent: at + 4, text: 'Icon $icon size:16 color:#FFFFFFFF'),
          (indent: at + 2, text: 'Text ${name ?? '""'} size:17 weight:700'),
        ]);
    }
    // A field in a bar has no room for a label above it: its label is its hint.
    if ((word == 'Input' || word == 'Search' || word == 'SearchField') &&
        (_open.any((l) => l.frame == 'Nav') || RegExp(r'^\s*"(Search|Filter|Find)\b').hasMatch(rest)) &&
        !isComponent(word)) {
      if (!parts.has('hint')) {
        final label = parts.string();
        final hint = parts.string() ?? label ?? '"Search"';
        open();
        return out..add((indent: at, text: 'Input$mark "" $hint${parts.all}'));
      }
    }
    if (word == 'IconTile' && !isComponent('IconTile')) {
      final name = parts.string();
      final size = double.tryParse(parts.take('size') ?? '') ?? 40;
      final ink = parts.take('color') ?? accentName ?? accent;
      final fill = parts.take('fill') ?? iconTile ?? selectedFill;
      open();
      return out
        ..add((indent: at, text: 'Box$mark w:${_n(size)} h:${_n(size)} radius:${_n((size / 4).roundToDouble())} fill:$fill center middle${parts.all}'))
        ..add((indent: at + 2, text: 'Icon ${name ?? '"star"'} size:${_n((size / 2).roundToDouble())} color:$ink'));
    }
    if (word == 'Link' && !isComponent('Link')) {
      final href = parts.take('href') ?? parts.take('to') ?? parts.take('url');
      final label = parts.string();
      // menu:false keeps a link out of the bar's phone menu (one that stays in view: Search).
      final inMenu = parts.take('menu') != 'false';
      // href:"https://…" opens it; href:"#pricing" scrolls to that part of the page.
      final action = parts.action ??
          (href != null && RegExp(r'^"?https?://').hasMatch(href)
              ? ' -> link ${href.replaceAll('"', '')}'
              : href != null && RegExp(r'^"?#[A-Za-z_]').hasMatch(href)
                  ? ' -> scroll ${href.replaceAll('"', '').substring(1)}'
                  : '');
      if (bar != null && inMenu && label != null && action.trim().startsWith('->')) {
        bar.links.add((label: label, action: action.trim().substring(2).trim(), group: parent, direct: parent?.frame == 'Nav'));
      }
      open();
      // In a bar a link is a quiet button; in running content, text in the accent.
      if (parent?.frame == 'Nav' || _open.any((l) => l.frame == 'Nav')) {
        return out..add((indent: at, text: 'Button.ghost$mark ${label ?? '""'}${parts.props}$action'));
      }
      if (_looks(parts)) {
        final color = parts.has('color') ? '' : ' color:${accentText ?? accentName ?? accent}';
        return out..addAll(_textBox(at, mark, parts, text: '${label ?? '""'}$color', action: action));
      }
      return out..add((indent: at, text: 'Text$mark ${label ?? '""'}${parts.has('color') ? '' : ' color:${accentText ?? accentName ?? accent}'}${parts.props}$action'));
    }
    if ((word == 'Heading' || word == 'Title' || RegExp(r'^H[1-4]$').hasMatch(word)) && !isComponent(word)) {
      final level = word.startsWith('H') && word.length == 2 ? int.parse(word.substring(1)) : int.tryParse(parts.take('level') ?? '') ?? 2;
      // A website's headline and section titles; an app's page title and
      // the titles of its panels.
      final variant = inApp
          ? switch (level) {
              // In a top bar the page's title is a bar's size.
              1 when _open.any((l) => l.frame == 'Nav') => _variant(const ['heading3', 'heading', 'title']),
              1 => _variant(const ['title', 'pageTitle', 'heading2']),
              2 => _variant(const ['heading', 'sectionTitle', 'heading3']),
              _ => _variant(const ['strong', 'heading']),
            }
          : switch (level) {
              1 => _variant(const ['heading1', 'pageTitle', 'title']),
              2 => _variant(const ['heading2', 'title', 'sectionTitle']),
              _ => _variant(const ['heading3', 'heading', 'cardTitle', 'strong']),
            };
      open();
      return out..add((indent: at, text: 'Text${variant == null ? '' : '.$variant'}${mark.startsWith('#') ? mark : ''}${parts.all}'));
    }
    open(frame: null);
    return out..add((indent: at, text: text));
  }

  /// A design system's own component of this name, when the line is
  /// written as it is called (`Sidebar items:[…]`, `TopBar title:"…"`).
  /// Whether a text line writes a look of its own (a rule at a side, a
  /// fill, a corner): a text itself draws none.
  static bool _looks(_Parts parts) => (parts.hasBorder || parts.has('fill') || parts.has('radius')) && !parts.props.contains('{"');

  /// A text with a look of its own, as a box around the text.
  static List<PageLine> _textBox(int at, String mark, _Parts parts, {String text = '', String? action}) {
    final look = [
      for (final k in const ['fill', 'radius', 'border', 'border-left', 'border-right', 'border-top', 'border-bottom', 'w', 'maxw'])
        if (parts.take(k) case final String v) '$k:$v',
    ];
    final filled = look.any((l) => l.startsWith('fill:'));
    final pad = parts.take('pad') ?? (!filled && look.any((l) => l.startsWith('border-left')) ? '[12,2,0,2]' : '[8,3,8,3]');
    final grow = parts.word('grow') ? ' grow' : '';
    return [
      (indent: at, text: 'Box${filled && !look.any((l) => l.startsWith('w:')) ? ' w:hug' : ''} ${look.join(' ')} pad:$pad$grow'),
      (indent: at + 2, text: 'Text$mark${text.isEmpty ? '' : ' $text'}${parts.props}${action ?? parts.action ?? ''}'),
    ];
  }

  bool isComponentCall(String word, _Parts parts) => isComponent(word) && (parts.has('items') || parts.has('title') || parts.has('brand'));

  /// The lines that close what is still open (a bar's rule).
  List<PageLine> finish() {
    final out = <PageLine>[];
    while (_open.isNotEmpty) {
      out.addAll(_closing(_open.removeLast()));
    }
    return out;
  }

  static final _idKey = RegExp(r'\s(?:id|anchor):[A-Za-z_][\w-]*(?=\s|$)');
  static final _stickyKey = RegExp(r'\ssticky:true(?:\s+top:\d+)?(?=\s|$)');
  static final _bareValue = RegExp(r'^((?:Text|Avatar|Heading|Badge|Button)(?:[.#][\w.#]*)?)\s+([a-z_]\w*(?:\.[A-Za-z_]\w*)+)(?=\s|$)');
  static final _avatarSrc = RegExp(r'^(Avatar(?:#\w+)?)\s+(?:src|url|img):');

  /// A line with the keys a model reaches for by habit put as the notation
  /// has them: `id:why` (an anchor; nothing reads it) left out,
  /// `sticky:true top:24` as the word `sticky`, an Avatar's `src:` as its
  /// `image:` (with the name it must have).
  static String _plain(String text) {
    if (text.contains("'")) text = _doubleQuoted(text);
    if (!text.contains(':') && !text.contains('.')) return text;
    final quoted = text.indexOf('"');
    var t = text;
    if (t.contains(' id:') || t.contains(' anchor:')) {
      final m = _idKey.firstMatch(t);
      // id:why is an anchor (a `scroll why` goes to it): written as #why.
      if (m != null && (quoted < 0 || m.start < quoted || !_inString(t, m.start))) {
        final name = t.substring(m.start, m.end).split(':').last;
        t = t.replaceRange(m.start, m.end, RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(name) ? ' #$name' : '');
      }
    }
    if (t.contains(' sticky:true')) {
      final m = _stickyKey.firstMatch(t);
      if (m != null && !_inString(t, m.start)) t = t.replaceRange(m.start, m.end, ' sticky');
    }
    if (t.startsWith('Avatar')) {
      final m = _avatarSrc.firstMatch(t);
      if (m != null) {
        t = '${m[1]} "" image:${t.substring(m.end)}';
      } else {
        t = t.replaceFirstMapped(RegExp(r'\s(?:src|url|img):(?=")'), (_) => ' image:');
      }
    }
    // A value written bare where a text goes (Text.strong row.name) is that value shown.
    final bare = _bareValue.firstMatch(t);
    if (bare != null) t = '${bare[1]} "{${bare[2]}}"${t.substring(bare.end)}';
    return t;
  }

  /// 'single-quoted' text outside a string, as "double-quoted": a value
  /// read after := ends at its closing quote, not at the line's last one.
  static String _doubleQuoted(String t) {
    final out = StringBuffer();
    var inDouble = false;
    for (var i = 0; i < t.length; i++) {
      final c = t[i];
      if (inDouble) {
        out.write(c);
        if (t.codeUnitAt(i) == 0x5C && i + 1 < t.length) {
          out.write(t[++i]);
        } else if (c == '"') {
          inDouble = false;
        }
        continue;
      }
      if (c == '"') {
        inDouble = true;
        out.write(c);
        continue;
      }
      if (c == "'") {
        final end = t.indexOf("'", i + 1);
        final before = i == 0 ? ' ' : t[i - 1];
        if (end > i && !t.substring(i + 1, end).contains('"') && '=(,?:[!<>+&| '.contains(before)) {
          out.write('"${t.substring(i + 1, end)}"');
          i = end;
          continue;
        }
      }
      out.write(c);
    }
    return out.toString();
  }

  static bool _inString(String t, int at) {
    var inside = false;
    for (var i = 0; i < at; i++) {
      if (t.codeUnitAt(i) == 0x5C) {
        i++;
      } else if (t[i] == '"') {
        inside = !inside;
      }
    }
    return inside;
  }

  String? _variant(List<String> names) => names.where(textVariants.contains).firstOrNull;

  static String _n(double v) => v == v.roundToDouble() ? '${v.round()}' : '$v';

  static String _expr(String raw) {
    var e = raw.startsWith('=') ? raw.substring(1) : raw;
    if (e.startsWith('{') && e.endsWith('}')) e = e.substring(1, e.length - 1);
    return '(${e.replaceAll(' ', '')})';
  }
}

/// A block written after the page that is shown over it: a dialog, a
/// sheet, a drawer, a menu, a popover, a lightbox ([PageWords.overlay]).
final class Overlay {
  const Overlay(this.kind, this.id, this.width, this.action, this.head,
      {this.shift = 0,
      this.foot = const [],
      this.surface = true,
      this.radius = 0,
      this.outlined = false,
      this.closes = 'none',
      this.empty = const [],
      this.variables = const {}});

  /// In [foot], a line that stands for the lines written under the block
  /// (else [empty]), read again there: a gallery's picture in its thumbnails.
  static const lines = '@lines';

  /// The lines read where none is written under the block.
  final List<PageLine> empty;

  /// The variables it keeps (a lightbox's zoom, the picture it shows), by
  /// name with the value each starts at; a text starting `[` is a list
  /// written out.
  final Map<String, Object?> variables;

  /// `dialog`, `sheet`, `drawer`, `menu`, `popover` or `lightbox`.
  final String kind;

  /// Its canvas's id: what `open` names.
  final String id;

  /// Its canvas's width.
  final double width;

  /// What an `open <id>` says besides its canvas: the presentation, where
  /// it sits.
  final Map<String, Object?> action;

  /// The plain lines it starts with (its root first) and ends with, and how
  /// much further in the lines written under it are.
  final List<PageLine> head, foot;
  final int shift;

  /// Whether its canvas draws the surface (a fill, with [radius] corners and,
  /// when [outlined], a hairline and a shadow); false: what is in it does.
  final bool surface, outlined;
  final num radius;

  /// Which of its lines close it after their actions: `all` (a menu's
  /// items), `nav` (a drawer's NavItems and Links) or `none`.
  final String closes;
}

class _Line {
  _Line(this.indent, this.frame, {required this.before, this.shift = 0, this.after});

  /// As written.
  final int indent;

  /// The frame this line is (Page, App, Section, Nav, Sidebar, Main, Pane), if one.
  final String? frame;

  /// How far this line itself was moved in, and how much further its
  /// children are (a frame of two lines holds them under the second).
  final int before, shift;

  /// A line written after its children, at its own level.
  final String? after;

  /// A website's Nav: the links written in it (for its phone menu), and
  /// whether it writes a menu of its own.
  bool pageNav = false, ownMenu = false;
  final links = <({String label, String action, _Line? group, bool direct})>[];
}

/// The words of a line after its type, taken apart: `key:value` pairs,
/// bare words, strings and the action, each where it was written.
class _Parts {
  _Parts(String rest) {
    var i = 0;
    final s = rest;
    while (i < s.length) {
      if (s[i] == ' ') {
        i++;
        continue;
      }
      if (s.startsWith('->', i)) {
        action = ' ${s.substring(i).trimRight()}';
        break;
      }
      final from = i;
      var depth = 0;
      String? quote;
      while (i < s.length) {
        final c = s[i];
        if (quote != null) {
          if (c == r'\') i++;
          if (c == quote) quote = null;
        } else if (c == '"' || c == "'") {
          quote = c;
        } else if (c == '[' || c == '{' || c == '(') {
          depth++;
        } else if (c == ']' || c == '}' || c == ')') {
          depth = math.max(0, depth - 1);
        } else if (c == ' ' && depth == 0) {
          break;
        }
        i++;
      }
      _tokens.add(s.substring(from, math.min(i, s.length)));
    }
  }

  final _tokens = <String>[];
  String? action;

  static final _key = RegExp(r'^([A-Za-z][A-Za-z0-9_-]*):');

  /// Whether [key] is written with a value worked out (`key:=…`).
  bool bound(String key) => _tokens.any((t) => t.startsWith('$key:='));

  bool has(String key) => _tokens.any((t) => _key.firstMatch(t)?[1] == key);

  /// The value of `key:value`, left on the line.
  String? value(String key) {
    final i = _tokens.indexWhere((t) => _key.firstMatch(t)?[1] == key);
    return i < 0 ? null : _tokens[i].substring(key.length + 1);
  }

  /// Whether a border is written, on every side or on one.
  bool get hasBorder => _tokens.any((t) => _key.firstMatch(t)?[1]?.startsWith('border') ?? false);

  /// The value of `key:value`, removed from the line.
  String? take(String key) {
    final i = _tokens.indexWhere((t) => _key.firstMatch(t)?[1] == key);
    if (i < 0) return null;
    return _tokens.removeAt(i).substring(key.length + 1);
  }

  /// Whether the bare [word] is written.
  bool hasWord(String word) => _tokens.contains(word);

  /// Whether the bare [word] was written; it is removed.
  bool word(String word) => _tokens.remove(word);

  List<String> takeWords(Set<String> words) {
    final found = [for (final t in _tokens) if (words.contains(t)) t];
    _tokens.removeWhere(words.contains);
    return found;
  }

  /// The variable a line is bound to (`=at`), removed.
  String? binding() {
    final i = _tokens.indexWhere((t) => RegExp(r'^=[A-Za-z_][A-Za-z0-9_]*$').hasMatch(t));
    return i < 0 ? null : _tokens.removeAt(i).substring(1);
  }

  /// The first string of the line, removed.
  String? string() {
    final i = _tokens.indexWhere((t) => t.startsWith('"'));
    return i < 0 ? null : _tokens.removeAt(i);
  }

  /// What is left, without the action.
  String get props => _tokens.isEmpty ? '' : ' ${_tokens.join(' ')}';

  /// What is left, as it was written.
  String get all => '$props${action ?? ''}';
}
