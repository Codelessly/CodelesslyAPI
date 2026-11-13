/// The core of the model: nodes, layout, decoration, values, widgets,
/// behaviors, triggers, the core actions, variables, conditions, bindings and
/// scripts, and the [Catalog] that declares them. It knows no feature
/// library (auth, data, commerce, media, engage, publish, managed
/// components): a renderer-only program imports this alone.
///
/// Feature libraries add declarations to a [Catalog]; decoding takes one
/// (default [Catalog.core]).
library;

export 'src/core/action_fields.dart';
export 'src/core/actions.dart';
export 'src/core/behavior_fields.dart';
export 'src/core/behaviors.dart';
export 'src/core/bindings.dart';
export 'src/core/breakpoints.dart';
export 'src/core/catalog.dart';
export 'src/core/child_fits.dart';
export 'src/core/components.dart';
export 'src/core/conditions.dart';
export 'src/core/custom_paint.dart';
export 'src/core/custom_paint_fields.dart';
export 'src/core/decoration.dart';
export 'src/core/document.dart';
export 'src/core/edit/apply.dart';
export 'src/core/edit/catalog_check.dart';
export 'src/core/edit/diagnostics.dart';
export 'src/core/edit/edit_ops.dart';
export 'src/core/edit/explain.dart';
export 'src/core/edit/from_document.dart';
export 'src/core/edit/lint.dart';
export 'src/core/edit/outline.dart';
export 'src/core/edit/starter.dart';
export 'src/core/edit/stream.dart';
export 'src/core/edit/tools.dart';
export 'src/core/edit/trust.dart';
export 'src/core/json.dart';
export 'src/core/layout.dart';
export 'src/core/logic.dart';
export 'src/core/node.dart';
export 'src/core/node_patch.dart';
export 'src/core/path_follow.dart';
export 'src/core/props.dart';
export 'src/core/media.dart';
export 'src/core/route_transition.dart';
export 'src/core/scripts.dart';
export 'src/core/sections.dart';
export 'src/core/theme.dart';
export 'src/core/theme_refs.dart';
export 'src/core/triggers.dart';
export 'src/core/value_fields.dart';
export 'src/core/values/border.dart';
export 'src/core/values/color.dart';
export 'src/core/values/enums.dart';
export 'src/core/values/geometry.dart';
export 'src/core/values/paint.dart';
export 'src/core/values/text.dart';
export 'src/core/variables.dart';
export 'src/core/widgets/canvas.dart';
export 'src/core/widgets/collections.dart';
export 'src/core/widgets/collections_models.dart';
export 'src/core/widgets/flex.dart';
export 'src/core/widgets/icon.dart';
export 'src/core/widgets/indicators.dart';
export 'src/core/widgets/indicators_models.dart';
export 'src/core/widgets/inputs.dart';
export 'src/core/widgets/inputs_models.dart';
export 'src/core/widgets/material.dart';
export 'src/core/widgets/material_models.dart';
export 'src/core/widgets/media.dart';
export 'src/core/widgets/scroll.dart';
export 'src/core/widgets/stack.dart';
export 'src/core/widgets/text.dart';
export 'src/core/widgets/widgets.dart';
