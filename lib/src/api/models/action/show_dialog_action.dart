import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_dialog_action.g.dart';

/// Where a dialog opens.
enum DialogPlacement {
  /// Centered on the screen.
  center,

  /// Under the node that opened it, left edges aligned (a dropdown).
  below,

  /// Above the node that opened it, left edges aligned.
  above,

  /// To the right of the node that opened it, bottom edges aligned (a menu
  /// opened from a sidebar). Falls back to below or above when there is no
  /// room on the right.
  beside,
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

  /// Where the dialog opens: centered, or next to the node that opened it
  /// (a popover). Kept on screen either way.
  @JsonKey(unknownEnumValue: DialogPlacement.center)
  final DialogPlacement placement;

  /// Space between the dialog and the node it opens next to.
  final double placementGap;

  /// Creates a new [ShowDialogAction].
  ShowDialogAction({
    required this.destinationId,
    Map<String, String>? params,
    this.barrierColor = ColorRGBA.black54,
    this.barrierDismissible = true,
    this.showCloseButton = false,
    this.placement = DialogPlacement.center,
    this.placementGap = 8,
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
    placementGap,
  ];

  /// Duplicates this [ShowDialogAction] with given data overrides.
  ShowDialogAction copyWith({
    String? destinationId,
    Map<String, String>? params,
    bool? barrierDismissible,
    ColorRGBA? barrierColor,
    bool? showCloseButton,
    DialogPlacement? placement,
    double? placementGap,
  }) => ShowDialogAction(
    destinationId: destinationId ?? this.destinationId,
    params: {...this.params, ...params ?? {}},
    barrierDismissible: barrierDismissible ?? this.barrierDismissible,
    barrierColor: barrierColor ?? this.barrierColor,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    placement: placement ?? this.placement,
    placementGap: placementGap ?? this.placementGap,
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
