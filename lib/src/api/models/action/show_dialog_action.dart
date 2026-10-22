import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_dialog_action.g.dart';

/// Where a [ShowDialogAction] puts its canvas.
enum DialogPlacement {
  /// Centered over the screen at its design size.
  center,

  /// Pinned to the bottom edge, full width, sliding up.
  bottomSheet,

  /// A bottom sheet on screens narrower than 600 (mobile), centered
  /// otherwise.
  adaptive,

  /// A popover just below the widget that opened it, like a menu, kept on
  /// screen. Falls back to [center] when the opener has no position.
  anchored;

  /// Displayable label.
  String get prettify => switch (this) {
    DialogPlacement.center => 'Center',
    DialogPlacement.bottomSheet => 'Bottom sheet',
    DialogPlacement.adaptive => 'Sheet on mobile',
    DialogPlacement.anchored => 'Below trigger',
  };
}

/// An action that navigates to a new page.
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

  /// Where the dialog shows.
  final DialogPlacement placement;

  /// Space between the opener and an [DialogPlacement.anchored] dialog.
  final double anchorGap;

  /// Creates a new [ShowDialogAction].
  ShowDialogAction({
    required this.destinationId,
    Map<String, String>? params,
    this.barrierColor = ColorRGBA.black54,
    this.barrierDismissible = true,
    this.showCloseButton = false,
    this.placement = DialogPlacement.center,
    this.anchorGap = 6,
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
    placement,
    anchorGap,
  ];

  /// Duplicates this [ShowDialogAction] with given data overrides.
  ShowDialogAction copyWith({
    String? destinationId,
    Map<String, String>? params,
    bool? barrierDismissible,
    ColorRGBA? barrierColor,
    bool? showCloseButton,
    DialogPlacement? placement,
    double? anchorGap,
  }) => ShowDialogAction(
    destinationId: destinationId ?? this.destinationId,
    params: {...this.params, ...params ?? {}},
    barrierDismissible: barrierDismissible ?? this.barrierDismissible,
    barrierColor: barrierColor ?? this.barrierColor,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    placement: placement ?? this.placement,
    anchorGap: anchorGap ?? this.anchorGap,
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
