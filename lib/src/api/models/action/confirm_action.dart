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
/// The optional color, radius, border, shadow and text style fields
/// override that look.
///
/// With a [dialogId] the dialog is that canvas instead, like
/// [ShowDialogAction]. A button in it answers the dialog with a "Navigate
/// back" action whose params hold [resultKey]: `true` confirms, anything else
/// cancels. Closing the dialog any other way cancels. The params popped with a
/// confirm are the `${result}` the [actions] read.
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

  /// Outline of the built-in dialog. Null draws none.
  final BorderSideModel? border;

  /// Drop shadows of the built-in dialog, e.g. a hard offset shadow (radius
  /// 0). Null keeps the default elevation shadow; an empty list draws none.
  final List<Effect>? shadows;

  /// Font, size and color of the title. Unset values follow the app.
  final TextStyleModel? titleStyle;

  /// Font, size and color of the message. Unset values follow the app.
  final TextStyleModel? messageStyle;

  /// Font, size and color of both buttons' labels. Unset values follow the
  /// app; the label colors come from [confirmTextColor] and
  /// [cancelTextColor] when this sets none.
  final TextStyleModel? buttonStyle;

  /// Corner radius of the buttons. Null follows the app's buttons.
  final double? buttonRadius;

  /// Outline of both buttons. Null draws none.
  final BorderSideModel? buttonBorder;

  /// Drop shadows of the confirm button, and of the cancel button when it
  /// has a [cancelColor]. Null draws none.
  final List<Effect>? buttonShadows;

  /// Label color of the confirm button. Null picks one that reads on its
  /// fill.
  final ColorRGBA? confirmTextColor;

  /// Fill of the cancel button. Null leaves it a text button.
  final ColorRGBA? cancelColor;

  /// Label color of the cancel button. Null uses the dialog's text color.
  final ColorRGBA? cancelTextColor;

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
    this.border,
    this.shadows,
    this.titleStyle,
    this.messageStyle,
    this.buttonStyle,
    this.buttonRadius,
    this.buttonBorder,
    this.buttonShadows,
    this.confirmTextColor,
    this.cancelColor,
    this.cancelTextColor,
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
    BorderSideModel? border,
    bool clearBorder = false,
    List<Effect>? shadows,
    bool clearShadows = false,
    TextStyleModel? titleStyle,
    bool clearTitleStyle = false,
    TextStyleModel? messageStyle,
    bool clearMessageStyle = false,
    TextStyleModel? buttonStyle,
    bool clearButtonStyle = false,
    double? buttonRadius,
    bool clearButtonRadius = false,
    BorderSideModel? buttonBorder,
    bool clearButtonBorder = false,
    List<Effect>? buttonShadows,
    bool clearButtonShadows = false,
    ColorRGBA? confirmTextColor,
    bool clearConfirmTextColor = false,
    ColorRGBA? cancelColor,
    bool clearCancelColor = false,
    ColorRGBA? cancelTextColor,
    bool clearCancelTextColor = false,
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
    border: clearBorder ? null : border ?? this.border,
    shadows: clearShadows ? null : shadows ?? this.shadows,
    titleStyle: clearTitleStyle ? null : titleStyle ?? this.titleStyle,
    messageStyle: clearMessageStyle ? null : messageStyle ?? this.messageStyle,
    buttonStyle: clearButtonStyle ? null : buttonStyle ?? this.buttonStyle,
    buttonRadius: clearButtonRadius ? null : buttonRadius ?? this.buttonRadius,
    buttonBorder: clearButtonBorder ? null : buttonBorder ?? this.buttonBorder,
    buttonShadows: clearButtonShadows
        ? null
        : buttonShadows ?? this.buttonShadows,
    confirmTextColor: clearConfirmTextColor
        ? null
        : confirmTextColor ?? this.confirmTextColor,
    cancelColor: clearCancelColor ? null : cancelColor ?? this.cancelColor,
    cancelTextColor: clearCancelTextColor
        ? null
        : cancelTextColor ?? this.cancelTextColor,
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
    border,
    shadows,
    titleStyle,
    messageStyle,
    buttonStyle,
    buttonRadius,
    buttonBorder,
    buttonShadows,
    confirmTextColor,
    cancelColor,
    cancelTextColor,
  ];

  /// Creates an instance from a JSON object.
  factory ConfirmAction.fromJson(Map json) => _$ConfirmActionFromJson(json);

  @override
  Map toJson() =>
      _$ConfirmActionOmitDefaults(this, _$ConfirmActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitConfirmAction(this);
}
