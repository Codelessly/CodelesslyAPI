import '../props.dart';
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

/// Every widget declaration, by node type.
abstract final class Widgets {
  static const List<WidgetSpec> all = [
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
    ...mediaSpecs,
  ];

  static final Map<String, WidgetSpec> _byType = {for (final s in all) s.type: s};

  /// The declaration for [type], or null for a type this version doesn't
  /// know (its node still decodes and round-trips).
  static WidgetSpec? of(String type) => _byType[type];
}
