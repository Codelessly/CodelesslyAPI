# Flutter mirror standard (prototype, 2026-10-29)

**Canonical source:** pinned Flutter widget catalog, then API node field metadata. Breaking changes are permitted; do not add migrators or legacy decoders. The metadata builder here is a three-node prototype, not a production-level guarantee of render parity.

## Names and shape

- One node per Flutter widget **class**; expose Flutter's constructor parameter names exactly. A variant enum is appropriate only if Flutter presents variants as one class. Existing `ButtonNode` combining `ElevatedButton`, `TextButton`, `OutlinedButton`, `FilledButton` and `IconButton` and `RowColumnNode` combining `Row` and `Column` are transitional exceptions, **not** precedents.
- Node payload: `type` (Flutter class identifier), `props` (only mirrored Flutter arguments), `children` (child references), `extensions` (Codelessly-only bindings/reactions/variants/interactions), and core identity/layout metadata. Existing wire shapes remain until a coordinated breaking release; do not silently rename serialization fields in this metadata pilot.
- `@FlutterNode(widget, family: ...)` names the upstream class. `@FlutterProp(name, type, group, control, field?, defaultSource?, required?, bindable?)` names one upstream parameter, with `field` identifying existing storage when different. `defaultSource` is the upstream expression, not a claimed evaluated JSON default.
- Flutter's `material`, `cupertino`, `widgets` families remain separate. `codelessly` extensions never count toward Flutter coverage.

## Package layout target

`lib/src/{core,nodes/<family>,properties,actions,triggers,variables,data,schema}`. `schema/flutter_prop.dart` owns metadata; `tool/flutter_prop_builder` owns build_runner projections. No migrations directory while breaking changes are authorized. Refactor the old `src/api/nodes` tree in one coordinated change only after consumers can be updated.

## Generated projections

`dart run build_runner build --delete-conflicting-outputs` emits checked-in `.flutter_catalog.json` adjacent to annotated nodes with `jsonSchema`, DPP controls (`field`, `group`, `control`, `bindable`), A2UI catalog components, and test-matrix inputs. Tests assert three output files and property consistency. **Do not confuse the pilot schema with an API node wire schema:** JSON Schema currently describes mirrored widget props only. DPP controls are descriptors, not wired editor panels. Test values are candidates, not golden results.

A2UI v0.9.1 catalog uses `$schema`, `$id`, `components` (map from component name to JSON Schema), optionally `functions` and `theme`: [upstream basic catalog](https://github.com/google/A2UI/blob/main/specification/v0_9_1/catalogs/basic/catalog.json). [a2ui_core on pub.dev](https://pub.dev/packages/a2ui_core) is the Dart core package; [GenUI Catalog.definition](https://pub.dev/documentation/genui/latest/genui/Catalog/definition.html) describes `components` keyed by name. The generated node fragments must later be merged into one versioned catalog with a stable URL, shared refs and runtime validators; callbacks/actions and children need A2UI-specific binding representations rather than string placeholders.

## Tests required per node in production

JSON round-trip, generated schema validation, SDK light/dark goldens, one parity row per upstream constructor parameter, DPP control interaction, and A2UI renderer contract validation. No legacy migration fixture (explicitly superseded by the master plan Decisions). Reject unknown fields after adoption; remove dual decode paths and guards.
