// The reference's pages and which declarations each documents. Data only:
// the prose of every page is its template (tool/reference/templates/pages),
// the tables come from the catalog (catalog.dart).
//
// Every node type, behavior, trigger, action, value type, model, enum and
// formula function is documented on exactly one page: [assign] fails on an
// item no page claims or two pages claim, and test/reference_test.dart
// checks the generated pages define each anchor once.
import 'package:codelessly_api/codelessly_api.dart';

/// One page of the reference: `<id>.md`, rendered from
/// `templates/pages/<id>.md` with its Reference section generated from the
/// items listed here.
final class PageDef {
  const PageDef(
    this.id, {
    this.nodes = const [],
    this.behaviors = const [],
    this.triggers = const [],
    this.actions = const [],
    this.models = const [],
    this.library,
  });

  /// The file stem; also the `ui_docs` topic of the page.
  final String id;
  final List<String> nodes, behaviors, triggers, actions;

  /// Models (object types) shown on this page rather than in values.md. A
  /// behavior's own model is shown with the behavior wherever it is.
  final List<String> models;

  /// A feature library: every node type and action of its catalog belongs
  /// to this page.
  final Catalog? library;

  String get file => '$id.md';
}

/// The feature pages, in reading order (API_REFERENCE.md's order, after the
/// base and the index).
const List<PageDef> featurePages = [
  PageDef('layout',
      nodes: ['canvas', 'row', 'column', 'flex', 'stack', 'box', 'spacer', 'divider', 'verticalDivider', 'variance'],
      behaviors: ['sticky', 'floating', 'measure'],
      triggers: ['scroll', 'scrollEnd', 'enterViewport', 'exitViewport'],
      actions: ['scrollTo']),
  PageDef('theme', nodes: ['text'], behaviors: ['textDirection', 'defaultTextStyle'], actions: ['setThemeMode'], models: ['TextStyle', 'TextRun']),
  PageDef('decoration',
      nodes: ['icon', 'path'],
      behaviors: ['customPaint'],
      triggers: ['imageLoading', 'imageLoaded', 'imageError'],
      models: ['Paint', 'ColorStop', 'ImagePaint', 'NoisePaint', 'Effect', 'BorderSide']),
  PageDef('forms',
      nodes: [
        'filledButton', 'elevatedButton', 'outlinedButton', 'textButton', 'iconButton', 'floatingActionButton', //
        'textField', 'checkbox', 'switch', 'radio', 'slider', 'dropdown', 'segmentedButton', 'datePicker', 'timePicker',
        'dateTimeInput', 'signature', 'chip', 'actionChip', 'choiceChip', 'filterChip', 'inputChip',
      ],
      behaviors: ['form', 'radioGroup'],
      triggers: ['changed', 'changeEnd', 'submitted', 'deleted', 'editingComplete', 'focusGained', 'focusLost', 'keyDown', 'keyUp'],
      actions: ['editText', 'focus', 'validate'],
      models: ['InputDecoration', 'InputBorder', 'InputIcon', 'ButtonStyle', 'ShapeBorder', 'ButtonSegment', 'IconAction']),
  PageDef('lists',
      nodes: ['listView', 'gridView', 'pageView', 'tableView', 'listTile', 'pagination'],
      behaviors: ['reorderHandle'],
      triggers: ['reorder', 'refresh', 'swipeAction', 'rowTap'],
      actions: ['paginate'],
      models: ['Pagination', 'ListSections', 'ListReorder', 'SwipeAction', 'SwipeActions', 'TableColumn']),
  PageDef('navigation',
      nodes: ['appBar', 'navigationBar', 'bottomNavigationBar', 'tabs', 'tabBar', 'accordion', 'expansionTile', 'modal'],
      triggers: ['load', 'backPressed'],
      actions: ['navigate', 'openModal', 'closeModal', 'showToast', 'confirm', 'openLink'],
      models: ['NavigationDestination', 'RouteTransition', 'RouteDismiss']),
  PageDef('state',
      triggers: ['valueChanged', 'actionError'],
      actions: ['setVariable', 'setValue', 'setVariant', 'callFunction', 'if', 'forEach', 'delay', 'runScript', 'retryFailed']),
  PageDef('interaction',
      behaviors: ['states', 'inkWell', 'tooltip', 'ignorePointer', 'draggable', 'dropTarget', 'track', 'dismissible', 'pan', 'transformGesture'],
      triggers: [
        'click', 'doubleTap', 'longPress', 'hold', 'secondaryClick', 'pointerDown', 'pointerUp', 'hover', 'cursorEnter', //
        'cursorExit', 'swipeLeft', 'swipeRight', 'swipeUp', 'swipeDown', 'drag', 'dragEnd', 'wheel', 'pinch', 'dragStart',
        'dragCancel', 'dragCompleted', 'drop', 'dragEnter', 'dragExit', 'dropRejected',
      ],
      actions: ['controlTrack', 'controlDismissible', 'controlTransform', 'copyToClipboard', 'haptic']),
  PageDef('animation',
      behaviors: [
        'motion', 'animations', 'transitions', 'shimmer', 'reveal', 'typewriter', 'particles', 'flip', 'tilt', 'hero', //
        'viewProgress',
      ],
      triggers: ['timer', 'frame'],
      actions: ['animate']),
  PageDef('components', nodes: ['slot', 'external', 'placeholder', 'singlePlaceholder'], triggers: ['event'], actions: ['componentEvent']),
  PageDef('design-systems'),
  PageDef('charts',
      nodes: [
        'progressBar', 'circularProgressIndicator', 'activityIndicator', 'badge', 'radialGauge', 'gaugeMeter', 'chart', //
        'barChart', 'lineChart', 'plotChart', 'barcode',
      ],
      models: [
        'ChartSeries', 'ChartReferenceLine', 'GaugeZone', 'ProgressBand', 'PlotChartSeries', 'PlotChartLabel', //
        'PlotChartMarker', 'PlotChartRange', 'PlotChartYLine',
      ]),
  PageDef('data', library: dataCatalog),
  PageDef('auth', library: authCatalog),
  PageDef('commerce', library: commerceCatalog),
  PageDef('media', library: mediaCatalog),
  PageDef('engage', library: engageCatalog),
  PageDef('publish'),
  PageDef('edit-ops'),
  PageDef('render'),
];

/// The appendix: value types, enums and the models no page claims.
const String valuesPage = 'values';

/// The formula functions by group, in the order the state page shows them.
/// A function the table does not group is an error ([assign]).
const Map<String, List<String>> formulaGroups = {
  'Text': [
    'left', 'right', 'upper', 'lower', 'trim', 'contains', 'startsWith', 'endsWith', 'padLeft', 'padRight', 'substring', //
    'replace', 'regexReplace', 'titleCase', 'split', 'matches', 'slug', 'charCode', 'fromCharCode', 'codeUnits', 'join',
    'pad', 'text', 'runs', 'interpolate', 'textDirection', 'textDirectionOf', 'plural', 'pluralCategory',
  ],
  'Numbers and math': [
    'round', 'floor', 'ceil', 'abs', 'min', 'max', 'sqrt', 'pow', 'exp', 'ln', 'log', 'sign', 'hypot', 'sin', 'cos', //
    'tan', 'asin', 'acos', 'atan', 'atan2', 'pi', 'radians', 'degrees', 'clamp', 'distance', 'number', 'random', 'fill',
    'fixed', 'feetInches', 'thousands', 'seconds', 'duration',
  ],
  'Money and number formatting': [
    'money', 'currency', 'parseAmount', 'formatAmount', 'currencySymbol', 'currencyDecimals', 'formatNumber', //
    'formatCurrency', 'formatPercent',
  ],
  'Lists': [
    'sum', 'count', 'length', 'filter', 'where', 'find', 'any', 'all', 'map', 'sortBy', 'sortByDesc', 'findIndex', //
    'groupBy', 'unique', 'without', 'concat', 'first', 'last', 'slice', 'take', 'skip', 'reverse', 'range', 'indexOf',
    'flatten', 'compact', 'append', 'prepend', 'setAt', 'insertAt', 'removeAt', 'move', 'moveItems', 'updateWhere',
    'removeWhere', 'minBy', 'maxBy', 'pick', 'flatMap', 'at', 'isEmpty', 'isNotEmpty', 'toMap',
  ],
  'Objects': ['object', 'obj', 'merge', 'set', 'keys', 'values', 'get', 'unset', 'with', 'newId'],
  'Dates and time': [
    'now', 'nowMs', 'today', 'wallTime', 'parseDate', 'formatDate', 'addSeconds', 'diffSeconds', 'formatDuration', //
    'addMinutes', 'addHours', 'addDays', 'addMonths', 'diffMinutes', 'diffHours', 'diffDays', 'timeAgo', 'formatRelative',
    'isToday', 'isPast', 'isFuture', 'isSameDay', 'isBefore', 'isAfter', 'year', 'month', 'day', 'hour', 'minute',
    'second', 'weekday', 'daysInMonth',
  ],
  'Colors': ['luminance', 'mix', 'alpha', 'lerpColor'],
  'Logic': ['if', 'coalesce'],
};

/// The kinds of item a page documents, with the anchor prefix of each.
enum ItemKind {
  node('node'),
  behavior('behavior'),
  trigger('trigger'),
  action('action'),
  valueType('type'),
  model('type'),
  enumeration('enum'),
  function('fn');

  const ItemKind(this.prefix);
  final String prefix;
  String anchor(String name) => '$prefix-$name';
}

/// Which page documents each item: kind → name → page id.
typedef Assignment = Map<ItemKind, Map<String, String>>;

/// Assigns every item of [catalog] (catalog.json, as data) to its page.
/// Throws on an item that no page claims, or that two pages claim, or a
/// page that names an item that does not exist.
Assignment assign(Map<String, dynamic> catalog) {
  final out = {for (final k in ItemKind.values) k: <String, String>{}};
  final errors = <String>[];
  void claim(ItemKind kind, String name, String page) {
    final had = out[kind]![name];
    if (had != null && had != page) errors.add('${kind.name} $name: on $had and $page');
    out[kind]![name] = page;
  }

  final nodeTypes = (catalog['nodeTypes'] as Map).keys.cast<String>().toSet();
  final actionTypes = (catalog['actions']['types'] as Map).keys.cast<String>().toSet();
  final behaviorKeys = {for (final f in catalog['behaviors']['fields'] as List) f['key'] as String};
  final triggerTypes = {for (final t in catalog['triggers']['types'] as List) t['type'] as String};
  final models = (catalog['objectTypes'] as Map).keys.cast<String>().toSet();
  for (final p in featurePages) {
    void named(ItemKind kind, List<String> names, Set<String> known) {
      for (final n in names) {
        if (!known.contains(n)) errors.add('${p.id} names ${kind.name} $n, which is not declared');
        claim(kind, n, p.id);
      }
    }

    named(ItemKind.node, p.nodes, nodeTypes);
    named(ItemKind.behavior, p.behaviors, behaviorKeys);
    named(ItemKind.trigger, p.triggers, triggerTypes);
    named(ItemKind.action, p.actions, actionTypes);
    named(ItemKind.model, p.models, models);
    if (p.library case final lib?) {
      for (final w in lib.widgets) {
        claim(ItemKind.node, w.type, p.id);
      }
      for (final a in lib.actions) {
        claim(ItemKind.action, a.type, p.id);
      }
    }
  }
  // A behavior's own model goes with it.
  for (final f in (catalog['behaviors']['fields'] as List).cast<Map>()) {
    final m = (f['object'] ?? f['item_object']) as String?;
    final page = out[ItemKind.behavior]![f['key']];
    if (m != null && page != null && !out[ItemKind.model]!.containsKey(m)) claim(ItemKind.model, m, page);
  }
  for (final m in models) {
    out[ItemKind.model]!.putIfAbsent(m, () => valuesPage);
  }
  for (final v in (catalog['valueTypes'] as Map).keys) {
    claim(ItemKind.valueType, v as String, valuesPage);
  }
  for (final e in (catalog['enums'] as Map).keys) {
    claim(ItemKind.enumeration, e as String, valuesPage);
  }
  final grouped = {for (final g in formulaGroups.values) ...g};
  for (final f in (catalog['formulas']['functions'] as List).cast<Map>()) {
    final name = f['name'] as String;
    if (!grouped.contains(name)) errors.add('formula function $name: in no group of formulaGroups');
    claim(ItemKind.function, name, 'state');
  }
  for (final (kind, all) in [
    (ItemKind.node, nodeTypes),
    (ItemKind.behavior, behaviorKeys),
    (ItemKind.trigger, triggerTypes),
    (ItemKind.action, actionTypes),
  ]) {
    for (final n in all) {
      if (!out[kind]!.containsKey(n)) errors.add('${kind.name} $n: on no page (tool/reference/src/areas.dart)');
    }
  }
  if (errors.isNotEmpty) throw StateError('Reference pages:\n${errors.join('\n')}');
  return out;
}

/// Old pages that became stubs: each lists where its items went.
const Map<String, String> stubPages = {
  'nodes.md': 'Node types',
  'behaviors.md': 'Behaviors',
  'triggers.md': 'Triggers',
  'actions.md': 'Actions',
  'bindings.md': 'Bindings and expressions',
  'formulas.md': 'Formula functions',
  'variables-conditions-scripts.md': 'Variables, conditions and scripts',
};

/// The old guide's sections (index.md#guide-...) and where each went.
const Map<String, String> movedGuideSections = {
  'guide-document': 'STARTER.md#base-the-document',
  'guide-theme': 'theme.md#page-theme',
  'guide-nodes': 'STARTER.md#base-nodes-ids-children-and-slots',
  'guide-layout': 'layout.md#page-layout',
  'guide-decoration': 'decoration.md#page-decoration',
  'guide-text': 'theme.md#theme-text',
  'guide-screens': 'navigation.md#page-navigation',
  'guide-responsive': 'layout.md#layout-responsive-design',
  'guide-variables': 'state.md#page-state',
  'guide-conditions': 'state.md#state-conditions',
  'guide-reactions': 'interaction.md#interaction-reactions',
  'guide-states': 'interaction.md#interaction-hover-press-and-other-states',
  'guide-scrolling': 'layout.md#layout-scrolling',
  'guide-lists': 'lists.md#page-lists',
  'guide-forms': 'forms.md#page-forms',
  'guide-modals': 'navigation.md#navigation-modals-and-toasts',
  'guide-images': 'decoration.md#decoration-images',
  'guide-checking': 'render.md#page-render',
  'guide-pitfalls': 'STARTER.md#base-rules-that-are-easy-to-get-wrong',
  'guide-components': 'components.md#page-components',
  'guide-edit': 'edit-ops.md#page-edit-ops',
};

/// `ui_docs` names kept from the earlier topic list, and the section each
/// now answers with.
const Map<String, String> topicAliases = {
  'responsive': 'layout-responsive-design',
  'screens': 'navigation',
  'variables': 'state',
  'conditions': 'state-conditions',
  'reactions': 'interaction-reactions',
  'states': 'interaction-hover-press-and-other-states',
  'scrolling': 'layout-scrolling',
  'modals': 'navigation-modals-and-toasts',
  'images': 'decoration-images',
  'text': 'theme-text',
  'gestures': 'interaction',
  'scrollEffects': 'layout-scrolling',
  'formulas': 'state-formula-functions',
  'bindings': 'state-binding-paths',
  'ops': 'edit-ops',
};
