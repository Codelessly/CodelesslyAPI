import '../props.dart';
import '../standard_catalog.dart';
import 'canvas.dart';
import 'collections.dart';
import 'flex.dart';
import 'icon.dart';
import 'indicators.dart';
import 'inputs.dart';
import 'material.dart';
import 'media.dart';
import 'stack.dart';
import 'text.dart';

/// The core's node types, in the order an editor lists them.
const List<WidgetSpec> coreWidgetSpecs = [
  CanvasProps.spec,
  StackProps.spec,
  BoxProps.spec,
  FlexProps.row,
  FlexProps.column,
  TextProps.spec,
  IconProps.spec,
  SpacerProps.spec,
  VarianceProps.spec,
  ...collectionsSpecs,
  ...inputsSpecs,
  ...materialSpecs,
  ...indicatorsSpecs,
  ...pathAndSlotSpecs,
];

/// Every widget declaration of the standard catalog ([standardCatalog]):
/// a view kept for code that lists or looks up node types without a
/// catalog of its own.
abstract final class Widgets {
  /// The standard catalog's node types.
  static List<WidgetSpec> get all => standardCatalog.widgets;

  /// The declaration for [type], or null for a type the standard catalog
  /// doesn't declare (its node still decodes and round-trips).
  static WidgetSpec? of(String type) => standardCatalog.widget(type);
}
