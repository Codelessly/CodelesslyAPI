// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';

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

/// Represents a breakpoint for responsiveness.
@JsonSerializable()
class Breakpoint with EquatableMixin, SerializableMixin {
  /// ID of the node which this breakpoint belongs to.
  final String nodeId;

  /// Lower bound of this breakpoint. It is an integer, but supports infinity.
  /// Its value is inclusive in the breakpoint.
  final num lowerBound;

  /// Upper bound of this breakpoint. It is an integer, but supports infinity.
  final num upperBound;

  /// Scale mode of this breakpoint.
  final ScaleMode scaleMode;

  /// Creates new [Breakpoint] with given values.
  const Breakpoint({
    required this.nodeId,
    required this.lowerBound,
    required this.upperBound,
    required this.scaleMode,
  });

  /// Duplicates this [Breakpoint] with given data overrides.
  Breakpoint copyWith({
    String? nodeId,
    num? lowerBound,
    num? upperBound,
    ScaleMode? scaleMode,
  }) =>
      Breakpoint(
        nodeId: nodeId ?? this.nodeId,
        lowerBound: lowerBound ?? this.lowerBound,
        upperBound: upperBound ?? this.upperBound,
        scaleMode: scaleMode ?? this.scaleMode,
      );

  @override
  List<Object?> get props => [nodeId, lowerBound, upperBound, scaleMode];

  /// Factory constructor for creating a new [Breakpoint] instance from
  /// JSON data.
  factory Breakpoint.fromJson(Map json) => _$BreakpointFromJson(json);

  @override
  Map toJson() => _$BreakpointToJson(this);
}
