# Flutter mirror standard (prototype, 2026-10-29)

**Canonical source:** pinned Flutter widget catalog, then API node field metadata. Breaking changes are permitted; do not add migrators or legacy decoders. The metadata builder here is a four-node prototype, not a production-level guarantee of render parity.

## Names and shape

- One node per Flutter widget **class**; expose Flutter's constructor parameter names exactly. A variant enum is appropriate only if Flutter presents variants as one class. Existing `ButtonNode` combining `ElevatedButton`, `TextButton`, `OutlinedButton`, `FilledButton` and `IconButton` and `RowColumnNode` combining `Row` and `Column` are transitional exceptions, **not** precedents.
- Node payload: `type` (Flutter class identifier), `props` (only mirrored Flutter arguments), `children` (child references), `extensions` (Codelessly-only bindings/reactions/variants/interactions), and core identity/layout metadata. Existing wire shapes remain until a coordinated breaking release; do not silently rename serialization fields in this metadata pilot.
- `@FlutterNode(widget, family: ..., nodeType: ...)` names the upstream class and the current serialized wire type. `@FlutterProp(name, type, group, control, field?, defaultSource?, required?, bindable?)` decorates a **real field declaration** (including inherited mixin and nested `properties` fields). The generator validates the field path and declares the existing storage name in JSON Schema. `defaultSource` is the upstream expression, not a claimed evaluated JSON default. When Flutter's parameter name and the wire field path differ, a `drift` finding is emitted: this must be resolved before declaring parity.
- Flutter's `material`, `cupertino`, `widgets` families remain separate. `codelessly` extensions never count toward Flutter coverage.

## Package layout target

`lib/src/{core,nodes/<family>,properties,actions,triggers,variables,data,schema}`. `schema/flutter_prop.dart` owns metadata; `tool/flutter_prop_builder` owns build_runner projections. No migrations directory while breaking changes are authorized. Refactor the old `src/api/nodes` tree in one coordinated change only after consumers can be updated.

## Generated projections

`dart run build_runner build` emits checked-in `.flutter_catalog.json` adjacent to annotated nodes with `jsonSchema` keyed by **existing node wire fields**, DPP descriptors (`nodeType`, `flutterName`, `fieldPath`, `group`, `control`, `schemaType`, `defaultSource`, `bindable`), A2UI catalog components, and test-matrix inputs. `dart run tool/flutter_prop_builder/bin/merge.dart ../catalog/flutter_3.47.8.json` validates upstream widget and parameter names against the pinned catalog, then emits one merged `catalog/codelessly_catalog_v1.json` and `catalog/dpp_descriptors.json`. JSON Schema describes annotated wire fields only, not a complete node payload until every node field is annotated. DPP descriptors are not yet wired editor panels. Test values are candidates, not golden results.

A2UI v0.9.1 catalog uses `$schema`, `$id`, `components` (map from component name to JSON Schema), optionally `functions` and `theme`: [upstream basic catalog](https://github.com/google/A2UI/blob/main/specification/v0_9_1/catalogs/basic/catalog.json). [a2ui_core on pub.dev](https://pub.dev/packages/a2ui_core) is the Dart core package; [GenUI Catalog.definition](https://pub.dev/documentation/genui/latest/genui/Catalog/definition.html) describes `components` keyed by name. Catalog `$id` and `catalogId` are fixed at `https://codelessly.com/a2ui/catalogs/codelessly/v1/catalog.json`, protocol v0.9.1. The merged catalog is parsed by `a2ui_core` in tests. `action` fields reference `common_types.json#/$defs/Action`; `children` fields reference `ChildList`, and single child fields reference `ComponentId`. Converting A2UI action event objects to Codelessly reactions and child references to SDK node IDs is a separate renderer integration, not accomplished by schema generation.

## Tests required per node in production

JSON round-trip, generated schema validation, SDK light/dark goldens, one parity row per upstream constructor parameter, DPP control interaction, and A2UI renderer contract validation. The generator must refuse invalid annotated field paths and missing Flutter class/parameter names before declaring coverage; the current prototype checks field paths and schema types in the builder and Flutter class/parameter names in the merge command. It does not yet verify type and semantic equivalence. No legacy migration fixture (explicitly superseded by the master plan Decisions). Reject unknown fields after adoption; remove dual decode paths and guards.
