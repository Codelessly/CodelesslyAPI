import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_dialog_action.g.dart';

/// An action that navigates to a new page.
/// How a [ShowDialogAction] presents its canvas.
enum DialogPresentation {
  /// Centered over a dimmed barrier.
  dialog,

  /// Slides up from the bottom edge, full width, with rounded top corners.
  bottomSheet,

  /// A bottom sheet on phone-width screens (below 600), a dialog otherwise.
  adaptive,

  /// Anchored to the node that triggered it: below it, or above when there
  /// is no room, aligned to its left edge and kept on screen; no dim.
  popover;

  /// Displayable name.
  String get prettify => switch (this) {
    DialogPresentation.dialog => 'Dialog',
    DialogPresentation.bottomSheet => 'Bottom sheet',
    DialogPresentation.adaptive => 'Sheet on mobile, dialog on larger screens',
    DialogPresentation.popover => 'Popover',
  };
}

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

  /// How the canvas is presented: a centered dialog, a bottom sheet, either
  /// by screen width, or a popover anchored to the triggering node.
  final DialogPresentation presentation;

  /// Creates a new [ShowDialogAction].
  ShowDialogAction({
    required this.destinationId,
    Map<String, String>? params,
    this.barrierColor = ColorRGBA.black54,
    this.barrierDismissible = true,
    this.showCloseButton = false,
    this.presentation = DialogPresentation.dialog,
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
    presentation,
  ];

  /// Duplicates this [ShowDialogAction] with given data overrides.
  ShowDialogAction copyWith({
    String? destinationId,
    Map<String, String>? params,
    bool? barrierDismissible,
    ColorRGBA? barrierColor,
    bool? showCloseButton,
    DialogPresentation? presentation,
  }) => ShowDialogAction(
    destinationId: destinationId ?? this.destinationId,
    params: {...this.params, ...params ?? {}},
    barrierDismissible: barrierDismissible ?? this.barrierDismissible,
    barrierColor: barrierColor ?? this.barrierColor,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    presentation: presentation ?? this.presentation,
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
