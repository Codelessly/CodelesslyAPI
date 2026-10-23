import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'confirm_action.g.dart';

/// Asks the user to confirm, e.g. "Leave album?", then runs [actions] when
/// they confirm and [cancelActions] when they cancel or dismiss the dialog.
///
/// By default the dialog is built by the runtime and takes the app's look:
/// its font, primary color and surface come from the layout that shows it.
/// The optional color and radius fields override that look.
///
/// With a [dialogId] the dialog is that canvas instead, like
/// [ShowDialogAction]. A button in it answers the dialog with a "Navigate
/// back" action whose params hold [resultKey]: `true` confirms, anything else
/// cancels. Closing the dialog any other way cancels. The params popped with a
/// confirm are the `${result}` the [actions] read.
///
/// Either dialog can be presented as a centered dialog, a bottom sheet or a
/// side sheet ([presentation]), like [ShowDialogAction.presentation].
@JsonSerializable()
class ConfirmAction extends ActionModel with Equatable, SerializableMixin {
  /// The dialog's title. Supports variables and formulas.
  final String title;

  /// Text under the title. Supports variables and formulas.
  final String message;

  /// Label of the confirm button.
  final String confirmLabel;

  /// Label of the cancel button.
  final String cancelLabel;

  /// Whether confirming destroys something, which colors the confirm button
  /// red.
  final bool destructive;

  /// Actions to run, in order, when the user confirms.
  final List<ActionModel> actions;

  /// Actions to run, in order, when the user cancels.
  final List<ActionModel> cancelActions;

  /// Id of a canvas to show as the dialog instead of the built-in one, or
  /// null for the built-in dialog.
  final String? dialogId;

  /// Parameters passed to the [dialogId] canvas, like
  /// [ShowDialogAction.params].
  final Map<String, dynamic> params;

  /// Whether tapping outside the dialog dismisses it, which cancels.
  final bool barrierDismissible;

  /// Color of the barrier behind the dialog. Null uses the platform's
  /// default scrim.
  final ColorRGBA? barrierColor;

  /// Background of the built-in dialog. Null uses the app's surface color.
  final ColorRGBA? backgroundColor;

  /// Title and message color of the built-in dialog. Null uses the app's
  /// text color.
  final ColorRGBA? textColor;

  /// Fill of the built-in dialog's confirm button. Null uses the app's
  /// primary color, or its error color when [destructive].
  final ColorRGBA? confirmColor;

  /// Corner radius of the built-in dialog. Null follows the app's buttons.
  final double? cornerRadius;

  /// How the dialog is presented: centered, as a bottom sheet or as a side
  /// sheet. See [ShowDialogAction.presentation].
  @JsonKey(unknownEnumValue: DialogPresentation.dialog)
  final DialogPresentation presentation;

  /// Width of a [DialogPresentation.sideSheet], in logical pixels. Null takes
  /// the [dialogId] canvas's width, or 400 for the built-in dialog.
  final double? sheetWidth;

  /// The most of the screen's height a [DialogPresentation.bottomSheet] takes,
  /// from 0 to 1.
  final double maxHeightFactor;

  /// Whether a [DialogPresentation.bottomSheet] shows a grab handle at its
  /// top.
  final bool showDragHandle;

  /// The key of the "Navigate back" params that answers a [dialogId] dialog.
  static const String resultKey = 'confirmed';

  /// Whether a dialog that closed with [result] was confirmed: a map (the
  /// params of a "Navigate back" action) whose [resultKey] is true, or true.
  static bool isConfirmResult(Object? result) {
    final Object? value = result is Map ? result[resultKey] : result;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String text = value.trim().toLowerCase();
      return text == 'true' ||
          text == 'yes' ||
          text == '1' ||
          text == 'confirm';
    }
    return false;
  }

  /// Creates a [ConfirmAction].
  ConfirmAction({
    required this.title,
    this.message = '',
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    List<ActionModel>? actions,
    List<ActionModel>? cancelActions,
    this.dialogId,
    Map<String, dynamic>? params,
    this.barrierDismissible = true,
    this.barrierColor,
    this.backgroundColor,
    this.textColor,
    this.confirmColor,
    this.cornerRadius,
    this.presentation = DialogPresentation.dialog,
    this.sheetWidth,
    this.maxHeightFactor = 0.92,
    this.showDragHandle = true,
    super.nonBlocking,
    super.enabled,
  }) : actions = actions ?? [],
       cancelActions = cancelActions ?? [],
       params = params ?? {},
       super(type: ActionType.confirm);

  /// Duplicates this action with the given values replaced.
  ConfirmAction copyWith({
    String? title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    bool? destructive,
    List<ActionModel>? actions,
    List<ActionModel>? cancelActions,
    String? dialogId,
    bool clearDialogId = false,
    Map<String, dynamic>? params,
    bool? barrierDismissible,
    ColorRGBA? barrierColor,
    bool clearBarrierColor = false,
    ColorRGBA? backgroundColor,
    bool clearBackgroundColor = false,
    ColorRGBA? textColor,
    bool clearTextColor = false,
    ColorRGBA? confirmColor,
    bool clearConfirmColor = false,
    double? cornerRadius,
    bool clearCornerRadius = false,
    DialogPresentation? presentation,
    double? sheetWidth,
    bool clearSheetWidth = false,
    double? maxHeightFactor,
    bool? showDragHandle,
  }) => ConfirmAction(
    title: title ?? this.title,
    message: message ?? this.message,
    confirmLabel: confirmLabel ?? this.confirmLabel,
    cancelLabel: cancelLabel ?? this.cancelLabel,
    destructive: destructive ?? this.destructive,
    actions: actions ?? this.actions,
    cancelActions: cancelActions ?? this.cancelActions,
    dialogId: clearDialogId ? null : dialogId ?? this.dialogId,
    params: params ?? this.params,
    barrierDismissible: barrierDismissible ?? this.barrierDismissible,
    barrierColor: clearBarrierColor ? null : barrierColor ?? this.barrierColor,
    backgroundColor: clearBackgroundColor
        ? null
        : backgroundColor ?? this.backgroundColor,
    textColor: clearTextColor ? null : textColor ?? this.textColor,
    confirmColor: clearConfirmColor ? null : confirmColor ?? this.confirmColor,
    cornerRadius: clearCornerRadius ? null : cornerRadius ?? this.cornerRadius,
    presentation: presentation ?? this.presentation,
    sheetWidth: clearSheetWidth ? null : sheetWidth ?? this.sheetWidth,
    maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
    showDragHandle: showDragHandle ?? this.showDragHandle,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [
    title,
    message,
    confirmLabel,
    cancelLabel,
    destructive,
    actions,
    cancelActions,
    dialogId,
    params,
    barrierDismissible,
    barrierColor,
    backgroundColor,
    textColor,
    confirmColor,
    cornerRadius,
    presentation,
    sheetWidth,
    maxHeightFactor,
    showDragHandle,
  ];

  /// Creates an instance from a JSON object.
  factory ConfirmAction.fromJson(Map json) => _$ConfirmActionFromJson(json);

  @override
  Map toJson() =>
      _$ConfirmActionOmitDefaults(this, _$ConfirmActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitConfirmAction(this);
}
