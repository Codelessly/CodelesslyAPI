# 9. Catalogs, libraries and plugins

What a document may contain is a **catalog**: the node types (`WidgetSpec`),
action types (`ActionSpec`), list data sources (`DataSourceSpec`) and
formula functions (`FormulaSpec`) it declares. Decoding takes one; an
editor generates its panels from one; an agent can be handed one as JSON.
The code in this chapter is run by `test/catalog_test.dart`,
`test/catalog_json_test.dart` and `test/library_boundaries_test.dart`.

## The libraries

| Import | What it is |
|---|---|
| `package:codelessly_api/core.dart` | The model with no feature: nodes, layout, decoration, values, widgets, behaviors, triggers, the core actions (`CoreAction`), variables, conditions, bindings, scripts, breakpoints, theme tokens, and `Catalog` (`Catalog.core`). |
| `data.dart` | APIs, storage, cloud data and files, form submissions (`DataAction`); the cloud query model; `dataCatalog`. |
| `auth.dart` | `AuthAction`; `authCatalog`. |
| `commerce.dart` | `PaywallAction`, paywall configuration; `commerceCatalog`. |
| `media.dart` | `video`, `embeddedVideo`, `audioPlayer`, `webView`; speech, sound, image preloading, capture, print, file download (`MediaAction`); `mediaCatalog`. |
| `engage.dart` | `emitEvent` (`EngageAction`), automations; `engageCatalog`. |
| `publish.dart` | The publish model, published layouts, app identity, style sheets. |
| `managed.dart` | Codelessly-managed components and hosted plugins. |
| `codelessly_api.dart` | All of the above, `standardCatalog` (the core and every first-party library), `Widgets`, `ActionSpecs`, `ServiceConfig`. |

Each feature library exports `core.dart` too. The core imports no feature
library (the boundary test reads the imports), so a renderer-only program
is one import:

```dart
import 'package:codelessly_api/core.dart';

final doc = LayoutDocument.fromJson(json, catalog: Catalog.core);
```

## Decoding with a catalog

Every decoder takes one: `LayoutDocument.fromJson(json, catalog: …)`,
`Node.fromJson`, `Reaction.fromJson`, `ActionDef.fromJson`,
`ComponentDefinition.fromJson`, `PublishLayout.fromJson`,
`PublishBundle.fromJson`. Nested values (an action inside an `if`, a
reaction inside a navigation bar's destination) decode with the same one.
Without one, a decoder uses `Catalog.current`: the catalog of the decode
around it, else `Catalog.core`. The core can't name the feature libraries,
so code that reads feature types passes `standardCatalog` (or the SDK's
runtime catalog):

```dart
final doc = LayoutDocument.fromJson(json, catalog: standardCatalog);
```

A type the catalog doesn't declare still decodes, as it always has, and
re-encodes byte for byte: a node keeps its props raw (`Props.unknown`), an
action is an `UnknownAction`. Reading such a prop through its `PropDef`
decodes it (`node.prop(VideoProps.url)` works on a `video` read with the
core catalog), and `standardCatalog.upgrade(action)` makes such an action
typed.

## Declaring a native plugin

A plugin's types are named `vendor.name`; unprefixed names are the core's
and the first-party libraries'. In Dart, a node type is a `WidgetSpec` and
an action type an `ActionSpec` with a decoder for its own `ActionDef`
subclass:

```dart
abstract final class RatingProps {
  static const value = PropDef<double>('value', DoubleCodec(min: 0, max: 5), 0, doc: 'Stars filled.');
  static const color = PropDef<Color>('color', Codecs.color, Color(0xFFFFC83D));
  static const spec = WidgetSpec('acme.rating', props: [value, color], doc: 'A five-star rating.');
}

final class ShareAction extends ActionDef {
  const ShareAction({this.text = '', super.enabled, super.nonBlocking, super.when});

  static const typeName = 'acme.share';
  static const spec = ActionSpec(typeName, label: 'Share', fields: ShareFields.all, decode: decode, requires: ['share']);

  static ShareAction decode(Json m, ActionCommon c) =>
      ShareAction(text: readString(m['text']) ?? '', enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);

  final String text;

  @override
  String get type => typeName;

  @override
  Json get fieldsJson => {if (text.isNotEmpty) 'text': text};
}

const acme = Catalog(id: 'acme', widgets: [RatingProps.spec], actions: [ShareAction.spec]);

final doc = LayoutDocument.fromJson(json, catalog: standardCatalog + acme);
doc['r']!.prop(RatingProps.value); // 3.5
```

`+` composes catalogs (later entries win by type name); `parts` composes
them as a constant. A type declared without a Dart class (an `ActionSpec`
with no `decode`) decodes as a `DeclaredAction`: its spec and its fields as
`Props`. The SDK side of a native plugin is a `CodelesslyFeature` with the
same `catalog`, the `recipes` that build its node types and the `actions`
that run its action types (SDK guide, chapter 12).

## Catalog JSON

`catalog.toJson()` writes every node type (props with kind, Flutter type,
default, enum values, bounds and doc; child model; slots), the node envelope
(`layout`, `decoration`, `behaviors`) once, every action type (fields,
result, nested chains, required capabilities), the triggers, data sources,
formula functions and the object value types' fields. `compact: true` keeps
each prop to key, type and default, for handing a model a slice.
`Catalog.fromJson` reads declarations back: a plugin declared as data.

```json
{"widgets": [{"type": "acme.rating", "doc": "A five-star rating.", "children": "none",
   "props": [{"key": "value", "type": {"kind": "number", "flutter": "double", "min": 0, "max": 5}, "default": 0},
             {"key": "color", "type": {"kind": "value", "flutter": "Color"}, "default": "#FFFFC83D"}]}],
 "actions": [{"type": "acme.cheer", "label": "Cheer",
   "fields": [{"key": "amount", "type": {"kind": "number", "flutter": "double"}, "default": 1}]}]}
```

A prop declared as data decodes through a `JsonPropCodec`: numbers clamped
to their bounds, enum values by name, and a Flutter value type the core
models (`Color`, `EdgeInsets`, `TextStyle`…) as that model.

## Hosted plugins

A shipped app can't download compiled Dart, so a plugin stored on
Codelessly's hosting is **data**: its declarations and an implementation in
the model itself (`PluginPackage`, `package:codelessly_api/managed.dart`):

```json
{"schema": 2, "id": "acme.stars", "semver": "1.0.0", "minSdk": "24.0.0", "requires": [],
 "catalog": {"widgets": [...], "actions": [...]},
 "implementation": {
   "widgets": {"acme.rating": {"document": {"roots": ["root"], "nodes": {
     "root": {"type": "row", "children": ["s1", "s2", "s3", "s4", "s5"]},
     "s1": {"type": "icon", "props": {"icon": "star_border"},
            "bind": {"props.icon": "${= props.value >= 1 ? 'star' : 'star_border'}", "props.color": "${props.color}"}}}}}},
   "actions": {"acme.cheer": {"chain": [{"type": "setVariable", "variable": "cheers", "op": "add",
                                          "value": "${= params.amount * 2}"}]}}}}
```

* A node type is a tree with one root; its bindings read the plugin node's
  props as `${props.<key>}`. A page holds **one** node
  (`{"type": "acme.rating", "props": {"value": 3}}`); the SDK expands it at
  run time.
* An action type is a chain reading its fields as `${params.<key>}`.
* `formulas` are function variables, `scripts` keep their capability lists,
  `assets` are URLs with digests.

Releases use the managed components' machinery: a `PluginVersion` is stored
at `plugins/{id}/versions/{n}` like a managed component version (the
package's JSON text as `payload`, its sha256 as `digest`, `minSdk`), the
master at `plugins/{id}` is a `ManagedComponentMaster` (channels, majors,
rollouts, blocked versions), and `pluginUpdateTarget` applies the same rules.
A publish lists what it uses (`PublishModel.plugins`, `PluginRef`: id,
channel, pin, version, semver, digest).

`package.problems(hostCatalog)` is the trust check: a tree or chain may use
only types the host declares (and the plugin's own), and an action whose
`ActionSpec.requires` the package doesn't list in `requires` is refused.
