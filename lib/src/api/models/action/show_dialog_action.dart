import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_dialog_action.g.dart';

/// Where a [ShowDialogAction] shows its canvas.
enum DialogAnchor {
  /// Centered on the screen.
  none,

  /// Next to the node that ran the action, like a popover or menu, at the
  /// action's [ShowDialogAction.placement].
  trigger;

  /// Displayable name.
  String get prettify => switch (this) {
    DialogAnchor.none => 'Center of screen',
    DialogAnchor.trigger => 'Anchor to trigger',
  };
}

/// The side of the trigger an anchored [ShowDialogAction] opens on, and how
/// it lines up with the trigger along that side.
///
/// Start and end follow the reading direction for [below] and [above]
/// placements (start is the left edge in a left-to-right app) and are the top
/// and bottom edges for [right] and [left] placements. When the dialog does
/// not fit on its side, it opens on the opposite side if there is more room
/// there.
enum DialogPlacement {
  /// Below the trigger, start edges lined up.
  belowStart,

  /// Below the trigger, centered on it.
  belowCenter,

  /// Below the trigger, end edges lined up.
  belowEnd,

  /// Above the trigger, start edges lined up.
  aboveStart,

  /// Above the trigger, centered on it.
  aboveCenter,

  /// Above the trigger, end edges lined up.
  aboveEnd,

  /// Right of the trigger, top edges lined up.
  rightStart,

  /// Right of the trigger, centered on it.
  rightCenter,

  /// Right of the trigger, bottom edges lined up.
  rightEnd,

  /// Left of the trigger, top edges lined up.
  leftStart,

  /// Left of the trigger, centered on it.
  leftCenter,

  /// Left of the trigger, bottom edges lined up.
  leftEnd;

  /// Whether the dialog opens below or above the trigger, rather than beside
  /// it.
  bool get isVertical => index <= DialogPlacement.aboveEnd.index;

  /// Displayable name.
  String get prettify => switch (this) {
    DialogPlacement.belowStart => 'Below, start',
    DialogPlacement.belowCenter => 'Below, center',
    DialogPlacement.belowEnd => 'Below, end',
    DialogPlacement.aboveStart => 'Above, start',
    DialogPlacement.aboveCenter => 'Above, center',
    DialogPlacement.aboveEnd => 'Above, end',
    DialogPlacement.rightStart => 'Right, top',
    DialogPlacement.rightCenter => 'Right, center',
    DialogPlacement.rightEnd => 'Right, bottom',
    DialogPlacement.leftStart => 'Left, top',
    DialogPlacement.leftCenter => 'Left, center',
    DialogPlacement.leftEnd => 'Left, bottom',
  };
}

/// An action that shows a canvas as a dialog: centered on the screen, or,
/// with [anchor] set to [DialogAnchor.trigger], as a popover next to the node
/// that ran it (an account menu under an avatar, for example).
///
/// The dialog closes when its barrier is tapped (if [barrierDismissible]) or
/// with a "Navigate back" action inside it.
@JsonSerializable()
class ShowDialogAction extends ActionModel with Equatable, SerializableMixin {
  /// Destination canvas node's ID.
  final String destinationId;

  /// Parameters to pass to the destination page.
  final Map<String, dynamic> params;

  /// Whether the dialog is dismissible by tapping outside the dialog.
  final bool barrierDismissible;

  /// Color of the barrier that is shown behind the dialog.
  final ColorRGBA? barrierColor;

  /// Whether to show a close button on the dialog.
  final bool showCloseButton;

  /// Where the dialog shows: centered, or next to the node that ran the
  /// action.
  @JsonKey(unknownEnumValue: DialogAnchor.none)
  final DialogAnchor anchor;

  /// The side of the trigger an anchored dialog opens on. Only used when
  /// [anchor] is [DialogAnchor.trigger].
  @JsonKey(unknownEnumValue: DialogPlacement.belowStart)
  final DialogPlacement placement;

  /// The space between the trigger and an anchored dialog, in logical
  /// pixels.
  final double anchorGap;

  /// How far an anchored dialog is shifted along the trigger's edge, in
  /// logical pixels: toward the end for [DialogPlacement.isVertical]
  /// placements (right in a left-to-right app), down for the others.
  final double anchorOffset;

  /// Creates a new [ShowDialogAction].
  ShowDialogAction({
    required this.destinationId,
    Map<String, String>? params,
    this.barrierColor = ColorRGBA.black54,
    this.barrierDismissible = true,
    this.showCloseButton = false,
    this.anchor = DialogAnchor.none,
    this.placement = DialogPlacement.belowStart,
    this.anchorGap = 4,
    this.anchorOffset = 0,
    super.nonBlocking,
    super.enabled,
  }) : params = {...params ?? {}},
       super(type: ActionType.showDialog);

  @override
  List<Object?> get props => [
    destinationId,
    params,
    barrierDismissible,
    barrierColor,
    showCloseButton,
    anchor,
    placement,
    anchorGap,
    anchorOffset,
  ];

  /// Whether the dialog opens next to the node that ran the action.
  bool get isAnchored => anchor == DialogAnchor.trigger;

  /// Duplicates this [ShowDialogAction] with given data overrides.
  ShowDialogAction copyWith({
    String? destinationId,
    Map<String, String>? params,
    bool? barrierDismissible,
    ColorRGBA? barrierColor,
    bool? showCloseButton,
    DialogAnchor? anchor,
    DialogPlacement? placement,
    double? anchorGap,
    double? anchorOffset,
  }) => ShowDialogAction(
    destinationId: destinationId ?? this.destinationId,
    params: {...this.params, ...params ?? {}},
    barrierDismissible: barrierDismissible ?? this.barrierDismissible,
    barrierColor: barrierColor ?? this.barrierColor,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    anchor: anchor ?? this.anchor,
    placement: placement ?? this.placement,
    anchorGap: anchorGap ?? this.anchorGap,
    anchorOffset: anchorOffset ?? this.anchorOffset,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  /// Creates a new [ShowDialogAction] instance from a JSON data.
  factory ShowDialogAction.fromJson(Map json) =>
      _$ShowDialogActionFromJson(json);

  @override
  Map toJson() =>
      _$ShowDialogActionOmitDefaults(this, _$ShowDialogActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitShowDialogAction(this);
}
