import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_defaults.dart';
import '../mixins.dart';
import 'color_rgba.dart';
import 'icon.dart';
import 'reorder.dart';

part 'swipe_actions.g.dart';

/// One action revealed behind a list item as it is swiped: Delete,
/// Archive, Flag...
@JsonSerializable()
class SwipeActionModel with Equatable, SerializableMixin {
  /// Identifies the action in `${result.action}` of the list's
  /// `swipeAction` reactions, e.g. `delete`.
  final String id;

  /// The text shown on the revealed background.
  final String label;

  /// The icon shown on the revealed background.
  final MultiSourceIconModel? icon;

  /// The revealed background.
  final ColorRGBA background;

  /// The color of the label and icon.
  final ColorRGBA foreground;

  /// Whether the action takes the item out of the list (it slides away and
  /// the items below close the gap), like delete or archive. An action that
  /// doesn't (flag, mark read) springs the item back.
  final bool removes;

  /// Creates a [SwipeActionModel].
  const SwipeActionModel({
    this.id = '',
    this.label = '',
    this.icon,
    this.background = const ColorRGBA(r: 0.86, g: 0.15, b: 0.15, a: 1),
    this.foreground = ColorRGBA.white,
    this.removes = true,
  });

  /// Duplicates this instance with the given data overrides.
  SwipeActionModel copyWith({
    String? id,
    String? label,
    MultiSourceIconModel? icon,
    ColorRGBA? background,
    ColorRGBA? foreground,
    bool? removes,
  }) => SwipeActionModel(
    id: id ?? this.id,
    label: label ?? this.label,
    icon: icon ?? this.icon,
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
    removes: removes ?? this.removes,
  );

  @override
  List<Object?> get props => [id, label, icon, background, foreground, removes];

  /// Creates a [SwipeActionModel] from a JSON object.
  factory SwipeActionModel.fromJson(Map json) =>
      _$SwipeActionModelFromJson(json);

  @override
  Map toJson() =>
      _$SwipeActionModelOmitDefaults(this, _$SwipeActionModelToJson(this));
}

/// Swipe actions on a list's items: swiping an item toward the start
/// reveals [endActions] (the trailing side, e.g. Delete), toward the end
/// reveals [startActions] (e.g. Archive). Swiping past [threshold] runs the
/// first action of that side; a shorter swipe leaves the actions revealed
/// to tap.
///
/// Running one fires the list's `swipeAction` reactions with
/// `${result.action}` (its id), `${result.item}` and `${result.index}`.
/// With [undo], an action that removes the item shows an Undo bar for
/// [undoMs] first and only fires (and applies) when the bar goes away.
@JsonSerializable()
class SwipeActionsModel with Equatable, SerializableMixin {
  /// Whether items can be swiped now.
  final bool enabled;

  /// Revealed when an item is swiped toward the end (right, in a
  /// left-to-right layout).
  final List<SwipeActionModel> startActions;

  /// Revealed when an item is swiped toward the start (left).
  final List<SwipeActionModel> endActions;

  /// The fraction of the item's width a swipe must pass to run the first
  /// action of its side.
  final double threshold;

  /// Whether an action that removes the item can be undone.
  final bool undo;

  /// How long, in milliseconds, the Undo bar shows.
  final int undoMs;

  /// The text of the Undo bar; `${result.label}` reads the action's label.
  final String undoMessage;

  /// What an action that removes the item changes on its own: the bound
  /// list variable, or the cloud document (deleted).
  @JsonKey(unknownEnumValue: ListApply.none)
  final ListApply apply;

  /// Creates a [SwipeActionsModel].
  const SwipeActionsModel({
    this.enabled = true,
    this.startActions = const [],
    this.endActions = const [],
    this.threshold = 0.4,
    this.undo = true,
    this.undoMs = 4000,
    this.undoMessage = r'${result.label}',
    this.apply = ListApply.none,
  });

  /// Whether any action is set.
  bool get hasActions => startActions.isNotEmpty || endActions.isNotEmpty;

  /// Duplicates this instance with the given data overrides.
  SwipeActionsModel copyWith({
    bool? enabled,
    List<SwipeActionModel>? startActions,
    List<SwipeActionModel>? endActions,
    double? threshold,
    bool? undo,
    int? undoMs,
    String? undoMessage,
    ListApply? apply,
  }) => SwipeActionsModel(
    enabled: enabled ?? this.enabled,
    startActions: startActions ?? this.startActions,
    endActions: endActions ?? this.endActions,
    threshold: threshold ?? this.threshold,
    undo: undo ?? this.undo,
    undoMs: undoMs ?? this.undoMs,
    undoMessage: undoMessage ?? this.undoMessage,
    apply: apply ?? this.apply,
  );

  @override
  List<Object?> get props => [
    enabled,
    startActions,
    endActions,
    threshold,
    undo,
    undoMs,
    undoMessage,
    apply,
  ];

  /// Creates a [SwipeActionsModel] from a JSON object.
  factory SwipeActionsModel.fromJson(Map json) =>
      _$SwipeActionsModelFromJson(json);

  @override
  Map toJson() =>
      _$SwipeActionsModelOmitDefaults(this, _$SwipeActionsModelToJson(this));
}
