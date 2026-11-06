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
///
/// Either dialog can be presented as a centered dialog, a bottom sheet or a
/// side sheet ([presentation]), like [ShowDialogAction.presentation].
///
/// The built-in dialog's colors can follow data: [variables] maps a color
/// field's name (see [bindableColors]) to a variable path or formula giving a
/// color, e.g. `{"backgroundColor": "${pal.surface}",
/// "confirmColor": "${pal.danger}"}`. A binding that gives a color wins over
/// the field; one that gives nothing keeps the field.
@JsonSerializable()
class ConfirmAction extends ActionModel with Equatable, SerializableMixin {
  /// The dialog's title. Supports variables and formulas.
  final String title;

  /// A small line above the [title], such as "RESET PROGRESS", or empty
  /// for none. Supports variables and formulas.
  final String caption;

  /// Style of the [caption], or null for the built-in small caps.
  final TextStyleModel? captionStyle;

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

  /// Outline of the confirm button, over [buttonBorder]: a red-outlined
  /// "Take down" beside a plain outlined "Keep it". Null uses [buttonBorder].
  final BorderSideModel? confirmBorder;

  /// Outline of the cancel button, over [buttonBorder]. Null uses
  /// [buttonBorder].
  final BorderSideModel? cancelBorder;

  /// An icon over the title, e.g. the lamp being taken down. A
  /// `variables` binding `icon` names a Material icon instead (`${lamp.icon}`).
  final MultiSourceIconModel? icon;

  /// Width and height of [icon].
  final double iconSize;

  /// Color of [icon]. Null keeps the icon's own color, else the text color.
  final ColorRGBA? iconColor;

  /// Fill of a circle behind the [icon] (or alone, a dot, with no icon).
  /// Null draws the icon without one.
  final ColorRGBA? iconDiscColor;

  /// Diameter of the [iconDiscColor] circle.
  final double iconDiscSize;

  /// Outline of the [iconDiscColor] circle. Null draws none.
  final BorderSideModel? iconDiscBorder;

  /// Whether the icon, title and message are centered (the buttons then
  /// share the row too, see [expandButtons]).
  final bool centered;

  /// Whether the two buttons share the width of the dialog equally.
  final bool expandButtons;

  /// Width of the built-in centered dialog, in logical pixels, within
  /// [maxWidth] and the screen less [insets]. Null hugs its content up to
  /// [maxWidth].
  final double? width;

  /// The widest the built-in centered dialog gets. Null is 400.
  final double? maxWidth;

  /// Space kept between the built-in centered dialog and the screen's
  /// edges, e.g. 20 on each side. Null is 24 on each side.
  final EdgeInsetsModel? insets;

  /// Space between the built-in dialog's edge and its icon, texts and
  /// buttons, e.g. `{l: 24, t: 26, r: 24, b: 22}`. Null is 24 on top and
  /// the sides and 16 at the bottom.
  final EdgeInsetsModel? padding;

  /// Height of the built-in dialog's buttons. Null is 44.
  final double? buttonHeight;

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

  /// PR42's persisted placement. For new dialogs use [presentation] and,
  /// when anchored, the trigger-relative placement on [ShowDialogAction].
  @JsonKey(unknownEnumValue: DialogPlacement.belowStart)
  final DialogPlacement placement;

  /// Blur of the page behind a centered [dialogId] dialog, as a Gaussian
  /// sigma (e.g. 8). It fades in with the dialog. 0 leaves the page sharp.
  final double barrierBlur;

  /// The scale a centered [dialogId] dialog grows from as it opens (e.g.
  /// 0.94). 1 keeps the plain fade.
  final double enterScale;
  /// Color bindings: a color field's name (one of [bindableColors]) to a
  /// variable path or formula that gives a color, e.g. `${pal.surface}` or
  /// `${= alpha(pal.ink, 0.22)}`; also the size fields of [bindableSizes].
  final Map<String, String> variables;

  /// The color fields [variables] can bind. `titleColor` and `messageColor`
  /// color the title and message over their text styles; `borderColor` and
  /// `buttonBorderColor` color [border] and [buttonBorder] (1px ones when
  /// there are none).
  static const List<String> bindableColors = <String>[
    'backgroundColor',
    'textColor',
    'titleColor',
    'messageColor',
    'confirmColor',
    'confirmTextColor',
    'cancelColor',
    'cancelTextColor',
    'barrierColor',
    'borderColor',
    'buttonBorderColor',
    'confirmBorderColor',
    'cancelBorderColor',
    'iconColor',
    'iconDiscColor',
    'iconDiscBorderColor',
  ];

  /// The size fields [variables] can bind too, to a number (`width`,
  /// `maxWidth`, `buttonHeight`) or, for `insets` and `padding`, a number
  /// for every side, `[horizontal, vertical]` or `[left, top, right,
  /// bottom]`, e.g. `{"width": "${= screen.isMobile ? 340 : 380}"}`. A
  /// binding that gives nothing keeps the field.
  static const List<String> bindableSizes = <String>[
    'width',
    'maxWidth',
    'buttonHeight',
    'insets',
    'padding',
  ];

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
    this.caption = '',
    this.captionStyle,
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
    this.confirmBorder,
    this.cancelBorder,
    this.icon,
    this.iconSize = 24,
    this.iconColor,
    this.iconDiscColor,
    this.iconDiscSize = 52,
    this.iconDiscBorder,
    this.centered = false,
    this.expandButtons = false,
    this.width,
    this.maxWidth,
    this.insets,
    this.padding,
    this.buttonHeight,
    this.presentation = DialogPresentation.dialog,
    this.sheetWidth,
    this.maxHeightFactor = 1,
    this.showDragHandle = false,
    this.placement = DialogPlacement.belowStart,
    this.barrierBlur = 0,
    this.enterScale = 1,
    Map<String, String>? variables,
    super.nonBlocking,
    super.enabled,
  }) : actions = actions ?? [],
       cancelActions = cancelActions ?? [],
       params = params ?? {},
       variables = variables ?? {},
       super(type: ActionType.confirm);

  /// Duplicates this action with the given values replaced.
  ConfirmAction copyWith({
    String? title,
    String? caption,
    TextStyleModel? captionStyle,
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
    BorderSideModel? confirmBorder,
    bool clearConfirmBorder = false,
    BorderSideModel? cancelBorder,
    bool clearCancelBorder = false,
    MultiSourceIconModel? icon,
    bool clearIcon = false,
    double? iconSize,
    ColorRGBA? iconColor,
    bool clearIconColor = false,
    ColorRGBA? iconDiscColor,
    bool clearIconDiscColor = false,
    double? iconDiscSize,
    BorderSideModel? iconDiscBorder,
    bool clearIconDiscBorder = false,
    bool? centered,
    bool? expandButtons,
    double? width,
    bool clearWidth = false,
    double? maxWidth,
    bool clearMaxWidth = false,
    EdgeInsetsModel? insets,
    bool clearInsets = false,
    EdgeInsetsModel? padding,
    bool clearPadding = false,
    double? buttonHeight,
    bool clearButtonHeight = false,
    DialogPresentation? presentation,
    double? sheetWidth,
    bool clearSheetWidth = false,
    double? maxHeightFactor,
    bool? showDragHandle,
    DialogPlacement? placement,
    double? barrierBlur,
    double? enterScale,
    Map<String, String>? variables,
  }) => ConfirmAction(
    title: title ?? this.title,
    caption: caption ?? this.caption,
    captionStyle: captionStyle ?? this.captionStyle,
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
    confirmBorder: clearConfirmBorder
        ? null
        : confirmBorder ?? this.confirmBorder,
    cancelBorder: clearCancelBorder ? null : cancelBorder ?? this.cancelBorder,
    icon: clearIcon ? null : icon ?? this.icon,
    iconSize: iconSize ?? this.iconSize,
    iconColor: clearIconColor ? null : iconColor ?? this.iconColor,
    iconDiscColor: clearIconDiscColor
        ? null
        : iconDiscColor ?? this.iconDiscColor,
    iconDiscSize: iconDiscSize ?? this.iconDiscSize,
    iconDiscBorder: clearIconDiscBorder
        ? null
        : iconDiscBorder ?? this.iconDiscBorder,
    centered: centered ?? this.centered,
    expandButtons: expandButtons ?? this.expandButtons,
    width: clearWidth ? null : width ?? this.width,
    maxWidth: clearMaxWidth ? null : maxWidth ?? this.maxWidth,
    insets: clearInsets ? null : insets ?? this.insets,
    padding: clearPadding ? null : padding ?? this.padding,
    buttonHeight: clearButtonHeight ? null : buttonHeight ?? this.buttonHeight,
    presentation: presentation ?? this.presentation,
    sheetWidth: clearSheetWidth ? null : sheetWidth ?? this.sheetWidth,
    maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
    showDragHandle: showDragHandle ?? this.showDragHandle,
    placement: placement ?? this.placement,
    barrierBlur: barrierBlur ?? this.barrierBlur,
    enterScale: enterScale ?? this.enterScale,
    variables: variables ?? this.variables,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [
    title,
    caption,
    captionStyle,
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
    confirmBorder,
    cancelBorder,
    icon,
    iconSize,
    iconColor,
    iconDiscColor,
    iconDiscSize,
    iconDiscBorder,
    centered,
    expandButtons,
    width,
    maxWidth,
    insets,
    padding,
    buttonHeight,
    presentation,
    sheetWidth,
    maxHeightFactor,
    showDragHandle,
    placement,
    barrierBlur,
    enterScale,
    variables,
  ];

  /// Creates an instance from a JSON object.
  factory ConfirmAction.fromJson(Map json) => _$ConfirmActionFromJson(json);

  @override
  Map toJson() =>
      _$ConfirmActionOmitDefaults(this, _$ConfirmActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitConfirmAction(this);
}
