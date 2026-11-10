// Carried over from CodelesslyEditor/lib/utils/migration_handler.dart: the
// schema migrations every stored document goes through on load. The new
// core owns them now (documents are migrated before decoding).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';

/// The node wire version this editor writes. Stored page documents carry no
/// version key, so every load runs every step; each step is idempotent and
/// leaves canonical JSON unchanged.
const int currentVersion = 2;

const Map<int, Migration> versions = <int, Migration>{
  1: MigrateV1(),
  2: MigrateV2(),
};

/// The page document key holding typeless entries (stray writes to deleted
/// nodes), raw, by their original key. Not a node; never decoded.
const String kOrphanedNodesKey = 'orphanedNodes';

/// The node key holding retired values that a newer key replaced, by their
/// old key. No decoder reads it.
const String kLegacyValuesKey = 'legacy';

/// Whether [key] of a stored page document holds page data, not a node.
bool isStoredPageMetaKey(Object? key) =>
    key == kRootNode || key == 'version' || key == kOrphanedNodesKey;

class MigrationHandler {
  MigrationHandler._();

  static void addVersionToJson(Map<String, dynamic> json) {
    json['version'] = currentVersion;
  }

  /// Migrates, in place, a stored page document, a clipboard payload
  /// (`copiedNodes`), or a `document`-wrapped page to [currentVersion].
  static void migrateJson(Map<String, dynamic> json) {
    int version = (json['version'] as num?)?.toInt() ?? 0;
    if (version >= currentVersion) return;
    for (int i = version + 1; i <= currentVersion; i++) {
      Migration migration = versions[i]!;

      bool migrated = false;
      if (json['document'] is Map) {
        migration.migrate(json['document'] as Map);
        migrated = true;
      }
      if (json['copiedNodes'] is Map) {
        migration.migrate(json['copiedNodes'] as Map);
        migrated = true;
      }
      if (!migrated) {
        migration.migrate(json);
      }
    }
  }

  /// Migrates, in place, raw clipboard JSON (`ClipboardNodesData`): its
  /// `copiedNodes` and its `components`' nodes. Unlike [migrateJson] it
  /// ignores the clipboard's own `version`, which is not the node wire
  /// version; every step is idempotent.
  static void migrateClipboardJson(Map<String, dynamic> json) {
    if (json['copiedNodes'] case final Map nodes) {
      for (int i = 1; i <= currentVersion; i++) {
        versions[i]!.migrate(nodes);
      }
    }
    if (json['components'] case final Map components) {
      for (final Object? component in components.values) {
        if (component is Map<String, dynamic>) migrateComponentJson(component);
      }
    }
  }

  /// Migrates one node's JSON in place (no document context).
  static void migrateNode(Map node) => MigrateV2.migrateNode(node);

  /// Migrates, in place, the node map of a stored component
  /// (`CustomComponent` / `PublicComponent` JSON, its `data.nodes`), and
  /// returns [component]. Leaves anything else untouched.
  static Map<K, dynamic> migrateComponentJson<K>(Map<K, dynamic> component) {
    if (component['data'] case final Map data) {
      if (data['nodes'] case final Map nodes) {
        for (int i = 1; i <= currentVersion; i++) {
          versions[i]!.migrate(nodes);
        }
      }
    }
    return component;
  }
}

abstract class Migration {
  const Migration();

  void migrate(Map json);
}

class MigrateV1 extends Migration {
  const MigrateV1();

  @override
  void migrate(Map json) {
    // Migrate canvas inside list view, page view and grid view to root node.
    Set<String> movedCanvases = <String>{};
    for (final Object? value in json.values) {
      if (value is! Map) continue;
      final Map nodeJson = value;
      if (nodeJson['type'] case 'listView' || 'pageView' || 'gridView') {
        final Object? children = nodeJson['children'];
        if (children is! List || children.isEmpty) continue;
        final Object? childId = children.first;
        final Object? child = json[childId];
        if (child is Map && child['type'] == 'canvas') {
          // found a canvas inside a list view, page view or grid view.
          movedCanvases.add(childId as String);
          children.clear();

          // update basicBoxLocal of the canvas to match the list view,
          // page view or grid view so that the canvas is displayed at the
          // correct position rather than at the top left corner.
          child['basicBoxLocal'] = nodeJson['basicBoxLocal'];

          // update the canvas to have fixed horizontal and vertical fit and
          // alignment since list view, page view and grid view may have
          // different size fits that may not work on root node.
          child['horizontalFit'] = 'fixed';
          child['verticalFit'] = 'fixed';
          child.remove('alignment');
        }
      }
    }

    // put back canvases on root node by updating the root node children.
    final Object? rootNode = json[kRootNode];
    if (rootNode is! Map || rootNode['children'] is! List) return;
    final List children = rootNode['children'] as List;
    for (final String canvasId in movedCanvases) {
      if (!children.contains(canvasId)) children.add(canvasId);
    }
  }
}

/// Codelessly API wire v7 (CodelesslyAPI 76a3eb09..2fd7d366): maps every
/// retired shape to the canonical one. Each rule maps one old shape exactly,
/// as the API's decoders read it before the change; anything without an
/// unambiguous mapping is left as is, so the strict decoder still fails on
/// it and the stored page is kept unchanged.
///
/// | Old | New | API |
/// |---|---|---|
/// | `type: rowColumn` + `rowColumnType` | `type: row` / `column` | eeea94bf |
/// | `itemSpacing` (no `spacing`) | `spacing` | eeea94bf |
/// | TextNode `characters` | `data` | 20634e05 |
/// | `type: button` + `properties.buttonType` | `elevatedButton`, `textButton`, `outlinedButton`, `iconButton`, `filledButton` + `properties.variant` | eeea94bf, 5868b04a |
/// | DropdownProperties `dense`, `expanded`, `autoFocus` | `isDense`, `isExpanded`, `autofocus` | 20634e05 |
/// | NavigationBar `currentIndex` | `selectedIndex` | 02a8a5b0 |
/// | chart / gauge / signature without a kind, or `chartSeries`, `chartPlot`, `gaugeRadial`, `gaugeMeter`, `signatureNormalized`, `signatureKind: pixel` | `type` + `chartKind` / `gaugeKind` / `signatureKind` | 20068fb7 |
/// | Typeless partial entries (stray field writes to deleted nodes) | moved to the document's `orphanedNodes` map, untouched | editor |
///
/// When an old key and its new key are both present, the new key wins: only
/// this editor writes new keys, and it saves single fields of stored nodes
/// (`document.<id>.data`), so the new key is the newer write over a stored
/// legacy node. The old value is not dropped: it moves to `legacy.<oldKey>`
/// on the node (`kLegacyValuesKey`), which no decoder reads.
class MigrateV2 extends Migration {
  const MigrateV2();

  @override
  void migrate(Map json) {
    // Typeless entries cannot be decoded; keep them raw beside the nodes.
    for (final MapEntry entry in json.entries.toList()) {
      if (isStoredPageMetaKey(entry.key)) continue;
      final Object? value = entry.value;
      if (value is Map && value['type'] == null) {
        final Map orphans = (json[kOrphanedNodesKey] ??= <String, dynamic>{})
            as Map;
        orphans[entry.key] = value;
        json.remove(entry.key);
      }
    }

    final Map<Object?, String> typeOf = <Object?, String>{};
    for (final MapEntry entry in json.entries) {
      if (isStoredPageMetaKey(entry.key) || entry.value is! Map) continue;
      migrateNode(entry.value as Map);
      if ((entry.value as Map)['type'] case final String type) {
        typeOf[entry.key] = type;
      }
    }

    // State patches name nodes' properties by their wire keys.
    for (final MapEntry entry in json.entries) {
      if (isStoredPageMetaKey(entry.key) || entry.value is! Map) continue;
      final Map node = entry.value as Map;
      if (node['interactionStates'] case final Map states) {
        for (final Object? patches in states.values) {
          if (patches is Map) _migratePatches(patches, typeOf);
        }
      }
      if (node['variants'] case final List variants) {
        for (final Object? variant in variants) {
          if (variant is Map && variant['overrides'] is Map) {
            _migratePatches(variant['overrides'] as Map, typeOf);
          }
        }
      }
    }
  }

  static void _migratePatches(Map patches, Map<Object?, String> typeOf) {
    for (final MapEntry entry in patches.entries) {
      final Object? patch = entry.value;
      if (patch is! Map) continue;
      switch (typeOf[entry.key]) {
        case 'text':
          _rename(patch, 'characters', 'data');
        case 'navigationBar':
          _rename(patch, 'currentIndex', 'selectedIndex');
        case 'row' || 'column':
          _rename(patch, 'itemSpacing', 'spacing');
        case 'dropdown':
          if (patch['properties'] case final Map properties) {
            _migrateDropdownProperties(patch, properties);
          }
      }
    }
  }

  /// Migrates one node's JSON in place.
  static void migrateNode(Map node) {
    switch (node['type']) {
      case 'rowColumn':
        final Object? axis = node['rowColumnType'];
        if (axis == 'row' || axis == 'column') node['type'] = axis;
      case 'button':
        _migrateButton(node);
      case 'chartSeries':
        node['type'] = 'chart';
        node['chartKind'] ??= 'series';
      case 'chartPlot':
        node['type'] = 'chart';
        node['chartKind'] ??= 'plot';
      case 'gaugeRadial':
        node['type'] = 'gauge';
        node['gaugeKind'] ??= 'radial';
      case 'gaugeMeter':
        node['type'] = 'gauge';
        node['gaugeKind'] ??= 'meter';
      case 'signatureNormalized':
        node['type'] = 'signature';
        node['signatureKind'] ??= 'normalized';
    }
    switch (node['type']) {
      case 'row' || 'column':
        _rename(node, 'itemSpacing', 'spacing');
      case 'text':
        _rename(node, 'characters', 'data');
      case 'dropdown':
        if (node['properties'] case final Map properties) {
          _migrateDropdownProperties(node, properties);
        }
      case 'navigationBar':
        _rename(node, 'currentIndex', 'selectedIndex');
      case 'chart':
        if (node['chartKind'] == null) {
          if (_inferChartKind(node) case final String kind) {
            node['chartKind'] = kind;
          }
        }
      case 'gauge':
        if (node['gaugeKind'] == null) {
          if (_inferGaugeKind(node) case final String kind) {
            node['gaugeKind'] = kind;
          }
        }
      case 'signature':
        if (node['signatureKind'] == 'pixel') {
          node['signatureKind'] = 'strokes';
        } else if (node['signatureKind'] == null) {
          if (_inferSignatureKind(node) case final String kind) {
            node['signatureKind'] = kind;
          }
        }
    }
  }

  /// Moves [from] to [to]. When [to] is already set it wins, and a
  /// different [from] value is kept under `legacy.<from>` of [holder] (the
  /// node; [json] itself by default).
  static void _rename(Map json, String from, String to, {Map? holder}) {
    if (!json.containsKey(from)) return;
    final Object? value = json.remove(from);
    if (!json.containsKey(to)) {
      json[to] = value;
    } else if (!_jsonEquals(value, json[to])) {
      final Map legacy =
          ((holder ?? json)[kLegacyValuesKey] ??= <String, dynamic>{}) as Map;
      legacy[from] = value;
    }
  }

  static bool _jsonEquals(Object? a, Object? b) =>
      a == b || jsonEncode(a) == jsonEncode(b);

  static void _migrateDropdownProperties(Map node, Map properties) {
    _rename(properties, 'dense', 'isDense', holder: node);
    _rename(properties, 'expanded', 'isExpanded', holder: node);
    _rename(properties, 'autoFocus', 'autofocus', holder: node);
  }

  static const Map<String, String> _buttonTypes = <String, String>{
    'elevated': 'elevatedButton',
    'text': 'textButton',
    'outlined': 'outlinedButton',
    'icon': 'iconButton',
    'filled': 'filledButton',
    'filledTonal': 'filledButton',
  };

  static void _migrateButton(Map node) {
    final Object? properties = node['properties'];
    if (properties != null && properties is! Map) return;
    // An absent buttonType was the default, elevated.
    final Object? kind = properties is Map
        ? properties['buttonType'] ?? 'elevated'
        : 'elevated';
    final String? type = _buttonTypes[kind];
    if (type == null) return; // Unknown kind: leave it to fail closed.
    final Map props = properties is Map ? properties : <String, dynamic>{};
    props.remove('buttonType');
    if (kind == 'filled') props['variant'] = 'filled';
    if (kind == 'filledTonal') props['variant'] = 'tonal';
    node['properties'] = props;
    node['type'] = type;
  }

  static Set<Object?> _keys(Object? map) =>
      map is Map ? map.keys.toSet() : <Object?>{};

  /// The chart kind the API inferred from exclusive keys before 20068fb7,
  /// or null when neither or both kinds match.
  static String? _inferChartKind(Map json) {
    final Set<Object?> properties = _keys(json['properties']);
    final Set<Object?> variables = _keys(json['variables']);
    final bool series =
        json.containsKey('selectedIndex') ||
        properties.any(const {
          'chartType',
          'series',
          'sampleData',
          'labelField',
          'xSlots',
          'referenceLines',
          'gridLines',
          'barWidthFraction',
          'domainMin',
        }.contains) ||
        variables.any(const {'data', 'selectedIndex'}.contains);
    final bool plot =
        json.containsKey('selectedX') ||
        properties.any(const {
          'points',
          'xMin',
          'xMax',
          'gridStepX',
          'markers',
          'ranges',
          'referenceX',
          'selectionStep',
          'lineWidth',
          'fillColor',
        }.contains) ||
        variables.any(const {'points', 'markers', 'selectedX'}.contains);
    if (series == plot) return null;
    return series ? 'series' : 'plot';
  }

  /// The gauge kind the API inferred before 20068fb7, or null.
  static String? _inferGaugeKind(Map json) {
    final Set<Object?> properties = _keys(json['properties']);
    final bool radial = properties.any(const {
      'valueColor',
      'colorByZone',
      'zones',
      'zoneThickness',
      'zoneOpacity',
      'majorTicks',
      'minorTicks',
      'labels',
      'labelColor',
      'labelFontSize',
      'labelFontFamily',
      'showTarget',
      'target',
      'targetColor',
      'showNeedle',
      'needleColor',
      'needleClearance',
    }.contains);
    final bool meter =
        json.containsKey('limit') ||
        _keys(json['variables']).any(const {
          'limit',
          'color',
          'limitColor',
        }.contains) ||
        properties.any(const {
          'shape',
          'color',
          'fillStartOpacity',
          'backgroundColor',
          'borderColor',
          'inset',
          'edgeWidth',
          'edgeColor',
          'ticks',
          'majorTickEvery',
          'limitColor',
          'limitWidth',
          'limitStyle',
          'limitPointer',
          'cornerRadius',
        }.contains);
    if (radial == meter) return null;
    return radial ? 'radial' : 'meter';
  }

  /// The signature kind the API inferred before 20068fb7 (its pixel kind is
  /// now `strokes`), or null.
  static String? _inferSignatureKind(Map json) {
    final Set<Object?> properties = _keys(json['properties']);
    final bool pixel =
        json.containsKey('value') ||
        properties.any(const {
          'inkWidth',
          'backgroundColor',
          'borderColor',
          'borderWidth',
          'errorBorderColor',
          'errorBorderWidth',
          'cornerRadius',
          'placeholder',
          'placeholderColor',
          'placeholderFontSize',
          'showSignLine',
          'signLineColor',
          'error',
          'enabled',
        }.contains);
    final bool normalized =
        json.containsKey('strokes') ||
        properties.any(const {'strokeWidth', 'readOnly'}.contains);
    if (pixel == normalized) return null;
    return pixel ? 'strokes' : 'normalized';
  }
}
