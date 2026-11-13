// The trust profile: what a document an agent writes may use. A restricted
// catalog (the node and action types allowed) plus limits, checked on every
// op (docs/design/08-ai-developer-experience.md §5). A violation is
// `capability_not_allowed` (or `limit_exceeded`) with the op and the path.
import 'package:meta/meta.dart';

import '../actions.dart';
import '../catalog.dart';
import '../json.dart';
import '../props.dart';
import 'diagnostics.dart';

/// Where navigation may go.
enum NavigationLimit {
  /// Any screen.
  any,

  /// Only the canvases of the document being edited (the session's own
  /// screens).
  withinDocument,

  /// No navigation.
  none,
}

/// What an edited document may use: node types, action types, scripts,
/// link and image hosts, navigation, and size limits. [TrustProfile.none]
/// allows everything; [TrustProfile.agent] is the default for agent-written
/// UI.
@immutable
final class TrustProfile {
  const TrustProfile({
    this.widgets,
    this.actions,
    this.scripts = true,
    this.linkHosts,
    this.imageHosts,
    this.navigation = NavigationLimit.any,
    this.maxNodes,
    this.maxDepth,
    this.maxTextLength,
    this.maxOpsPerCall,
  });

  /// Node types allowed; null: every type of the catalog.
  final Set<String>? widgets;

  /// Action types allowed; null: every type of the catalog.
  final Set<String>? actions;

  /// Whether `runScript` actions and script formulas (`script.x(...)`) are
  /// allowed.
  final bool scripts;

  /// Hosts `openLink` may open (https only); null: any link.
  final Set<String>? linkHosts;

  /// Hosts images may load from (`https://<host>/...`); null: any. `data:`
  /// URIs are always allowed.
  final Set<String>? imageHosts;
  final NavigationLimit navigation;
  final int? maxNodes, maxDepth, maxTextLength, maxOpsPerCall;

  /// No restriction.
  static const TrustProfile none = TrustProfile();

  /// The core's action types an agent may use by default: local state,
  /// in-document navigation, modals, toasts, scrolling, focus, animation,
  /// and `componentEvent` (an event to the agent). Not `runScript`,
  /// `callFunction`, `openLink`, `copyToClipboard`, `editText` or the
  /// controls of drag tracks.
  static const Set<String> agentActions = {
    SetVariableAction.typeName, SetValueAction.typeName, SetVariantAction.typeName, NavigateAction.typeName, //
    OpenModalAction.typeName, CloseModalAction.typeName, ShowToastAction.typeName, ConfirmAction.typeName,
    IfAction.typeName, ForEachAction.typeName, DelayAction.typeName, FocusAction.typeName, ScrollToAction.typeName,
    AnimateAction.typeName, HapticAction.typeName, ComponentEventAction.typeName, RetryFailedAction.typeName,
    PaginateAction.typeName,
  };

  /// The default for agent-written UI: the core's node types (every type
  /// [Catalog.core] declares: layout, text, inputs, lists, charts; no
  /// feature library's, whatever catalog the session has), [agentActions], no scripts, no links, navigation
  /// only to the document's own canvases, and size limits.
  static final TrustProfile agent = TrustProfile(
    widgets: {for (final w in Catalog.core.widgets) w.type},
    actions: agentActions,
    scripts: false,
    linkHosts: {},
    navigation: NavigationLimit.withinDocument,
    maxNodes: 1500,
    maxDepth: 40,
    maxTextLength: 4000,
    maxOpsPerCall: 2000,
  );

  /// [agent] with links to [linkHosts], and other changes.
  TrustProfile copyWith({
    Set<String>? widgets,
    Set<String>? actions,
    bool? scripts,
    Set<String>? linkHosts,
    Set<String>? imageHosts,
    NavigationLimit? navigation,
    int? maxNodes,
    int? maxDepth,
    int? maxTextLength,
    int? maxOpsPerCall,
  }) =>
      TrustProfile(
        widgets: widgets ?? this.widgets,
        actions: actions ?? this.actions,
        scripts: scripts ?? this.scripts,
        linkHosts: linkHosts ?? this.linkHosts,
        imageHosts: imageHosts ?? this.imageHosts,
        navigation: navigation ?? this.navigation,
        maxNodes: maxNodes ?? this.maxNodes,
        maxDepth: maxDepth ?? this.maxDepth,
        maxTextLength: maxTextLength ?? this.maxTextLength,
        maxOpsPerCall: maxOpsPerCall ?? this.maxOpsPerCall,
      );

  /// [catalog] restricted to what this profile allows: the catalog an
  /// agent is described and validated with.
  Catalog restrict(Catalog catalog) => widgets == null && actions == null ? catalog : catalog.select(widgets: widgets, actions: actions);

  /// The problems of node [json] (id [id], op [op]) under this profile:
  /// node types, action types, scripts, links, images and navigation
  /// targets ([screens]: the canvases navigation may name, null for any),
  /// and text length.
  List<EditDiagnostic> checkNode(String id, Json json, {required int op, required Catalog catalog, Set<String>? screens}) {
    final out = <EditDiagnostic>[];
    final at = editPointer('/nodes', id);
    final type = readString(json['type']);
    if (type != null && widgets != null && !widgets!.contains(type)) {
      out.add(EditDiagnostic.of(EditCodes.capabilityNotAllowed, op, 'Node type "$type" is not allowed here.',
          path: editPointer(at, 'type'), nodeId: id, expected: [...widgets!], suggestion: nearestName(type, widgets!)));
    }
    final text = readMap(json['props'])?['text'];
    if (maxTextLength != null && text is String && text.length > maxTextLength!) {
      out.add(EditDiagnostic.of(EditCodes.limitExceeded, op, 'Text of ${text.length} characters: the limit is $maxTextLength.',
          path: editPointer(editPointer(at, 'props'), 'text'), nodeId: id));
    }
    _checkActions(json, at, id, op, catalog, screens, out);
    _checkImages(json, at, id, op, out);
    return out;
  }

  /// Every action in [json] (reactions, nested chains, states and media
  /// patches), checked.
  void _checkActions(Object? json, String at, String id, int op, Catalog catalog, Set<String>? screens, List<EditDiagnostic> out) {
    void action(Json a, String p) {
      final type = readString(a['type']);
      if (type == null) return;
      if (actions != null && !actions!.contains(type)) {
        out.add(EditDiagnostic.of(EditCodes.capabilityNotAllowed, op, 'Action "$type" is not allowed here.',
            path: p, nodeId: id, expected: [...actions!], suggestion: nearestName(type, actions!)));
      }
      if (!scripts && type == RunScriptAction.typeName) {
        out.add(EditDiagnostic.of(EditCodes.capabilityNotAllowed, op, 'Scripts are not allowed here.', path: p, nodeId: id));
      }
      if (type == OpenLinkAction.typeName && linkHosts != null) {
        final url = readString(a['url']) ?? '';
        final uri = Uri.tryParse(url);
        final ok = uri != null && uri.scheme == 'https' && linkHosts!.contains(uri.host);
        if (!ok) {
          out.add(EditDiagnostic.of(EditCodes.capabilityNotAllowed, op,
              linkHosts!.isEmpty ? 'Links are not allowed here.' : 'Link "$url": only https links to ${linkHosts!.join(', ')}.',
              path: editPointer(p, 'url'), nodeId: id));
        }
      }
      if (type == NavigateAction.typeName) {
        final to = readString(a['to']) ?? '';
        final mode = readString(a['mode']);
        if (navigation == NavigationLimit.none) {
          out.add(EditDiagnostic.of(EditCodes.capabilityNotAllowed, op, 'Navigation is not allowed here.', path: p, nodeId: id));
        } else if (navigation == NavigationLimit.withinDocument && screens != null && mode != 'pop' && to.isNotEmpty && !to.contains(r'${') &&
            !screens.contains(to)) {
          out.add(EditDiagnostic.of(EditCodes.capabilityNotAllowed, op, 'Navigation to "$to": only this UI\'s own screens (${screens.join(', ')}).',
              path: editPointer(p, 'to'), nodeId: id, expected: [...screens], suggestion: nearestName(to, screens)));
        }
      }
      final spec = catalog.action(type);
      final nested = spec?.nested ?? const ['then', 'else', 'actions', 'onSuccess', 'onError', 'cancelActions'];
      for (final k in nested) {
        final list = readList(a[k]);
        if (list == null) continue;
        for (var i = 0; i < list.length; i++) {
          if (readMap(list[i]) case final Json n) action(n, editPointer(editPointer(p, k), i));
        }
      }
    }

    void walk(Object? v, String p) {
      if (v is Map) {
        final m = readMap(v)!;
        final reactions = readList(m['actions']);
        if (reactions != null) {
          for (var i = 0; i < reactions.length; i++) {
            final r = readMap(reactions[i]);
            final list = readList(r?['actions']);
            if (list == null) continue;
            for (var j = 0; j < list.length; j++) {
              if (readMap(list[j]) case final Json a) action(a, editPointer(editPointer(editPointer(editPointer(p, 'actions'), i), 'actions'), j));
            }
          }
        }
      }
    }

    walk(json, at);
  }

  void _checkImages(Json json, String at, String id, int op, List<EditDiagnostic> out) {
    if (imageHosts == null) return;
    void walk(Object? v, String p) {
      if (v is Map) {
        for (final e in v.entries) {
          final k = '${e.key}';
          if ((k == 'url' || k == 'src') && e.value is String && p.contains('image')) {
            final url = e.value as String;
            final uri = Uri.tryParse(url);
            final ok = url.startsWith('data:') || (uri != null && uri.scheme == 'https' && imageHosts!.contains(uri.host));
            if (!ok) {
              out.add(EditDiagnostic.of(EditCodes.capabilityNotAllowed, op, 'Image "$url": only https images from ${imageHosts!.join(', ')}.',
                  path: editPointer(p, k), nodeId: id));
            }
          } else {
            walk(e.value, editPointer(p, k));
          }
        }
      } else if (v is List) {
        for (var i = 0; i < v.length; i++) {
          walk(v[i], editPointer(p, i));
        }
      }
    }

    walk(json, at);
  }
}

/// A catalog's slice.
extension CatalogSelect on Catalog {
  /// This catalog with only the node types [widgets] and action types
  /// [actions] (null: all of them), its data sources and formulas kept.
  /// Flutter has no equivalent; the editor's palette and the agent's
  /// description read the slice.
  Catalog select({Set<String>? widgets, Set<String>? actions}) => Catalog(
        id: id.isEmpty ? 'slice' : '$id-slice',
        instructions: instructions,
        widgets: [for (final w in this.widgets) if (widgets == null || widgets.contains(w.type)) w],
        actions: [for (final a in this.actions) if (actions == null || actions.contains(a.type)) a],
        dataSources: dataSources,
        formulas: formulas,
      );
}

/// The prop declarations of [spec] by key (for messages).
List<String> propKeys(WidgetSpec spec) => [for (final p in spec.props) p.key];
