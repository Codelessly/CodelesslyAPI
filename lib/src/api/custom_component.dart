// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models/models.dart';
import 'mixins.dart';
import 'utils.dart';

part 'custom_component.g.dart';

/// A model to hold custom component data.
@JsonSerializable()
class CustomComponent with EquatableMixin, SerializableMixin {
  /// Unique identifier for the component.
  final String id;

  /// Name of the component.
  final String name;

  /// Node data of the component. This is the data that is used to render the
  /// component.
  final ComponentData data;

  /// Date and time when the component was created.
  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  final DateTime createdAt;

  /// The thumbnail URL for the component preview.
  final String? previewUrl;

  /// Blur-hash for the thumbnail preview.
  final String blurhash;

  /// Default constructor to create a new component.
  CustomComponent({
    required this.id,
    this.name = '',
    required this.data,
    DateTime? createdAt,
    this.previewUrl,
    this.blurhash = '',
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        name,
        data,
        createdAt,
        previewUrl,
        blurhash,
      ];

  /// Duplicate this [CustomComponent] instance with the given data overrides.
  CustomComponent copyWith({
    String? id,
    String? name,
    ComponentData? data,
    bool? deleted,
    String? previewUrl,
    String? blurhash,
  }) =>
      CustomComponent(
        id: id ?? this.id,
        name: name ?? this.name,
        data: data ?? this.data,
        createdAt: DateTime.now(),
        previewUrl: previewUrl ?? this.previewUrl,
        blurhash: blurhash ?? this.blurhash,
      );

  /// Factory constructor for creating a new instance of this class from
  /// a JSON object.
  factory CustomComponent.fromJson(Map<String, dynamic> json) =>
      _$CustomComponentFromJson(json);

  @override
  Map toJson() => _$CustomComponentToJson(this);
}

/// Holds component's node data and containing rect size data.
@JsonSerializable()
class ComponentData with EquatableMixin, SerializableMixin {
  /// Width of the containing rect for [nodes].
  final double width;

  /// Height of the containing rect for [nodes].
  final double height;

  /// JSON data of all the nodes of the component where key is the ID of the
  /// node and value is actual node JSON that is used to recreate a [BaseNode]
  /// instance.
  final Map<String, dynamic> nodes;

  /// Returns containing rect of the component.
  RectC get rect => RectC.fromLTWH(0, 0, width, height);

  /// Default constructor to create new instances.
  ComponentData({
    required this.width,
    required this.height,
    required this.nodes,
  })  : assert(nodes.isNotEmpty),
        assert(width > 0 && height > 0);

  @override
  List<Object?> get props => [width, height, nodes];

  @override
  Map toJson() => _$ComponentDataToJson(this);

  /// Factory constructor for creating a new instance of this class from
  /// a JSON object.
  factory ComponentData.fromJson(Map<String, dynamic> json) =>
      _$ComponentDataFromJson(json);

  /// Duplicate this [ComponentData] instance with the given data overrides.
  ComponentData copyWith({
    double? width,
    double? height,
    Map<String, dynamic>? nodes,
  }) =>
      ComponentData(
        width: width ?? this.width,
        height: height ?? this.height,
        nodes: nodes ?? this.nodes,
      );
}
