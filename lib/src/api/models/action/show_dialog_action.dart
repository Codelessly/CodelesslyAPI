import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_dialog_action.g.dart';

/// How a [ShowDialogAction] presents its destination canvas.
enum DialogPresentation {
  /// Centered over the page at the canvas's design size.
  dialog,

  /// Anchored to the bottom edge, as wide as the screen and as tall as the
  /// canvas's content, up to [ShowDialogAction.maxHeightFactor] of the
  /// screen. Slides up from the bottom.
  bottomSheet,

  /// Anchored to the right edge, as tall as the screen and
  /// [ShowDialogAction.sheetWidth] wide. Slides in from the right.
  sideSheet;

  /// Displayable name.
  String get prettify => switch (this) {
    DialogPresentation.dialog => 'Dialog',
    DialogPresentation.bottomSheet => 'Bottom Sheet',
    DialogPresentation.sideSheet => 'Side Sheet',
  };
}

/// An action that shows a canvas over the current page, as a centered
/// dialog, a bottom sheet or a side sheet (see [presentation]). A
/// "Navigate back" action in the canvas closes it.
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

  /// How the canvas is presented.
  @JsonKey(unknownEnumValue: DialogPresentation.dialog)
  final DialogPresentation presentation;

  /// Width of a [DialogPresentation.sideSheet], in logical pixels. Null takes
  /// the destination canvas's width.
  final double? sheetWidth;

  /// The most of the screen's height a [DialogPresentation.bottomSheet] takes,
  /// from 0 to 1. A taller canvas scrolls within it.
  final double maxHeightFactor;

  /// Whether a [DialogPresentation.bottomSheet] shows a grab handle at its
  /// top.
  final bool showDragHandle;

  /// Creates a new [ShowDialogAction].
  ShowDialogAction({
    required this.destinationId,
    Map<String, String>? params,
    this.barrierColor = ColorRGBA.black54,
    this.barrierDismissible = true,
    this.showCloseButton = false,
    this.presentation = DialogPresentation.dialog,
    this.sheetWidth,
    this.maxHeightFactor = 0.92,
    this.showDragHandle = true,
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
    sheetWidth,
    maxHeightFactor,
    showDragHandle,
  ];

  /// Duplicates this [ShowDialogAction] with given data overrides.
  ShowDialogAction copyWith({
    String? destinationId,
    Map<String, String>? params,
    bool? barrierDismissible,
    ColorRGBA? barrierColor,
    bool? showCloseButton,
    DialogPresentation? presentation,
    double? sheetWidth,
    bool clearSheetWidth = false,
    double? maxHeightFactor,
    bool? showDragHandle,
  }) => ShowDialogAction(
    destinationId: destinationId ?? this.destinationId,
    params: {...this.params, ...params ?? {}},
    barrierDismissible: barrierDismissible ?? this.barrierDismissible,
    barrierColor: barrierColor ?? this.barrierColor,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    presentation: presentation ?? this.presentation,
    sheetWidth: clearSheetWidth ? null : sheetWidth ?? this.sheetWidth,
    maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
    showDragHandle: showDragHandle ?? this.showDragHandle,
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
