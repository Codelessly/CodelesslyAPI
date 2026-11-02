import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import '../json_defaults.dart';

part 'breakpoint.g.dart';

/// The scale mode represents how a canvas should be displayed within a given
/// breakpoint.
enum ScaleMode {
  /// The size of the canvas adjusts to fit either the width of the canvas or
  /// the width of the screen, whichever is smaller. The scale is determined by
  /// dividing the screen width by the canvas width.
  ///
  /// The result is used to set the width of a FittedBox widget that wraps the
  /// canvas, ensuring that it fits within the window without being too big or
  /// too small.
  ///
  /// The entire canvas is scaled to keep the layout exactly as designed in its
  /// original width.
  autoScale('Auto Scale'),

  /// The canvas and its elements can lay out as they please, stretching to fit
  /// the screen width.
  ///
  /// All elements will react based on their layout rules, with expanded size
  /// fits stretching or shrinking, pinned elements moving to their pinned
  /// sides, aligned elements maintaining their percentage from their relevant
  /// side, and so on.
  ///
  /// The layout becomes adaptive to the size of the canvas and screen, making
  /// it responsive to changes in size.
  responsive('Responsive');

  /// Displayable string representation of the enum value.
  final String label;

  /// Default constructor for this enum.
  const ScaleMode(this.label);
}

/// The screen size classes a layout can adapt to: mobile, tablet and desktop.
///
/// A width picks one by the rule the runtime's `screen` variable uses: below
/// [tablet]'s [minWidth] is mobile, below [desktop]'s is tablet, and anything
/// wider is desktop. A responsive [VarianceNode] maps each of its variants to
/// one of these (see [Variant.breakpoint]).
enum ScreenBreakpoint {
  /// Phones: narrower than 600.
  mobile('Mobile', minWidth: 0, defaultWidth: 390),

  /// Tablets: from 600 up to 1024.
  tablet('Tablet', minWidth: 600, defaultWidth: 834),

  /// Desktops: 1024 and wider.
  desktop('Desktop', minWidth: 1024, defaultWidth: 1440);

  /// Displayable name.
  final String label;

  /// The narrowest width this breakpoint covers, inclusive.
  final double minWidth;

  /// The width a design canvas takes to show this breakpoint.
  final double defaultWidth;

  const ScreenBreakpoint(
    this.label, {
    required this.minWidth,
    required this.defaultWidth,
  });

  /// The breakpoint a screen or canvas [width] wide falls in; a responsive
  /// layout may move where tablet and desktop start.
  static ScreenBreakpoint forWidth(
    double width, {
    double? tabletMinWidth,
    double? desktopMinWidth,
  }) {
    if (width >= (desktopMinWidth ?? desktop.minWidth)) return desktop;
    if (width >= (tabletMinWidth ?? tablet.minWidth)) return tablet;
    return mobile;
  }
}

/// Represents a breakpoint for responsiveness.
@JsonSerializable()
class Breakpoint with Equatable, SerializableMixin {
  /// ID of the node which this breakpoint belongs to.
  final String nodeId;

  /// Lower bound of this breakpoint. It is an integer, but supports infinity.
  /// Its value is inclusive in the breakpoint.
  final num lowerBound;

  /// Upper bound of this breakpoint. It is an integer, but supports infinity.
  final num upperBound;

  /// Creates new [Breakpoint] with given values.
  const Breakpoint({
    required this.nodeId,
    this.lowerBound = 0,
    this.upperBound = double.infinity,
  });

  /// Duplicates this [Breakpoint] with given data overrides.
  Breakpoint copyWith({String? nodeId, num? lowerBound, num? upperBound}) =>
      Breakpoint(
        nodeId: nodeId ?? this.nodeId,
        lowerBound: lowerBound ?? this.lowerBound,
        upperBound: upperBound ?? this.upperBound,
      );

  @override
  List<Object?> get props => [nodeId, lowerBound, upperBound];

  /// Factory constructor for creating a new [Breakpoint] instance from
  /// JSON data.
  factory Breakpoint.fromJson(Map json) => _$BreakpointFromJson(json);

  @override
  Map toJson() => _$BreakpointOmitDefaults(this, _$BreakpointToJson(this));
}
