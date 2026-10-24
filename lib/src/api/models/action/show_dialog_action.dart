import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_dialog_action.g.dart';

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

  /// How the canvas opens: a dialog, a bottom sheet, or adaptive (a bottom
  /// sheet on phones, below 600 px wide, and a dialog otherwise).
  @JsonKey(unknownEnumValue: DialogPresentation.dialog)
  final DialogPresentation presentation;

  /// Where a dialog sits on the screen, e.g. top right for a menu. Center by
  /// default. Bottom sheets always sit at the bottom and side sheets at the
  /// right edge.
  final AlignmentModel alignment;

  /// Space kept between the overlay and the screen edges: a dialog placed
  /// in a corner stays this far from it, a side sheet is inset by it.
  final EdgeInsetsModel insets;

  /// The most of the screen height a dialog or bottom sheet may take, as a
  /// share of it (e.g. 0.9); its content scrolls beyond. Null keeps the
  /// canvas's design height (a bottom sheet's own cap applies).
  final double? maxHeightFactor;

  /// Creates a new [ShowDialogAction].
  ShowDialogAction({
    required this.destinationId,
    Map<String, String>? params,
    this.barrierColor = ColorRGBA.black54,
    this.barrierDismissible = true,
    this.showCloseButton = false,
    this.presentation = DialogPresentation.dialog,
    this.alignment = AlignmentModel.center,
    this.insets = EdgeInsetsModel.zero,
    this.maxHeightFactor,
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
    alignment,
    insets,
    maxHeightFactor,
  ];

  /// Duplicates this [ShowDialogAction] with given data overrides.
  ShowDialogAction copyWith({
    String? destinationId,
    Map<String, String>? params,
    bool? barrierDismissible,
    ColorRGBA? barrierColor,
    bool? showCloseButton,
    DialogPresentation? presentation,
    AlignmentModel? alignment,
    EdgeInsetsModel? insets,
    double? maxHeightFactor,
    bool clearMaxHeightFactor = false,
  }) => ShowDialogAction(
    destinationId: destinationId ?? this.destinationId,
    params: {...this.params, ...params ?? {}},
    barrierDismissible: barrierDismissible ?? this.barrierDismissible,
    barrierColor: barrierColor ?? this.barrierColor,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    presentation: presentation ?? this.presentation,
    alignment: alignment ?? this.alignment,
    insets: insets ?? this.insets,
    maxHeightFactor: clearMaxHeightFactor
        ? null
        : maxHeightFactor ?? this.maxHeightFactor,
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

/// How a [ShowDialogAction] presents its canvas.
enum DialogPresentation {
  /// A dialog, centered unless the action gives an alignment.
  dialog,

  /// A modal sheet that slides up from the bottom edge.
  bottomSheet,

  /// A bottom sheet on phones (narrower than 600 px), a dialog otherwise.
  adaptive,

  /// A sheet that slides in from the right edge, as tall as the screen less
  /// the insets (or as its content when the canvas hugs its height).
  sideSheet,
}
