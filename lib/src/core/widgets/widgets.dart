import '../props.dart';
import '../sections.dart' show SlotProps;
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
  FlexProps.flex,
  TextProps.spec,
  IconProps.spec,
  SpacerProps.spec,
  VarianceProps.spec,
  ...collectionsSpecs,
  ...inputsSpecs,
  ...materialSpecs,
  ...indicatorsSpecs,
  ...pathAndSlotSpecs,
  SlotProps.spec,
];
