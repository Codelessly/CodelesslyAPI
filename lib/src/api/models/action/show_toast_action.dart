import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_toast_action.g.dart';

/// The look of a [ShowToastAction], colored from the app's theme.
enum ToastStyle {
  /// Dark on a light app and light on a dark one, like a snackbar.
  neutral,

  /// The app's primary color.
  info,

  /// Green.
  success,

  /// Amber.
  warning,

  /// The app's error color.
  error;

  /// Displayable name.
  String get prettify => switch (this) {
    ToastStyle.neutral => 'Neutral',
    ToastStyle.info => 'Info',
    ToastStyle.success => 'Success',
    ToastStyle.warning => 'Warning',
    ToastStyle.error => 'Error',
  };
}

/// Where a [ShowToastAction] shows on screen.
enum ToastPosition {
  /// Above the bottom edge.
  bottom,

  /// Below the top edge and its safe area.
  top;

  /// Displayable name.
  String get prettify => switch (this) {
    ToastPosition.bottom => 'Bottom',
    ToastPosition.top => 'Top',
  };
}

/// Where a toast sits across the screen.
enum ToastAlignment {
  /// Centered, as wide as its content.
  center,

  /// Against the left margin.
  start,

  /// Against the right margin.
  end,

  /// As wide as the space between the margins.
  stretch;

  /// Label for the editor.
  String get prettify => switch (this) {
    ToastAlignment.center => 'Center',
    ToastAlignment.start => 'Left',
    ToastAlignment.end => 'Right',
    ToastAlignment.stretch => 'Stretch',
  };
}

/// An action that shows a short message near the bottom or top of the screen,
/// then hides it. The toast can carry a button, e.g. Undo, that runs
/// [actions].
///
/// Its colors come from [style] and the app's theme unless [backgroundColor]
/// or [textColor] are set. Its font is the app's unless [fontFamily],
/// [fontSize], [fontWeight], [messageStyle] or [actionStyle] set one.
/// [accentColor] draws a bar down its left edge, and [iconColor] colors
/// its [icon]. [border], [shadows], [padding] and [maxWidth] shape the toast;
/// [showClose] adds a dismiss button.
@JsonSerializable()
class ShowToastAction extends ActionModel with Equatable, SerializableMixin {
  /// The message. Supports variables and formulas, e.g.
  /// `Added ${storage.drink.name} to your order`.
  final String message;

  /// How long the message stays on screen, in milliseconds.
  final int duration;

  /// Background color. Null takes the [style]'s color from the app's theme.
  final ColorRGBA? backgroundColor;

  /// Message color. Null takes the color that reads on the background.
  final ColorRGBA? textColor;

  /// Which theme color the toast takes.
  @JsonKey(unknownEnumValue: ToastStyle.neutral)
  final ToastStyle style;

  /// Where the toast shows.
  @JsonKey(unknownEnumValue: ToastPosition.bottom)
  final ToastPosition position;

  /// Label of the toast's button, e.g. Undo. Supports variables. The toast
  /// has no button when it is empty.
  final String actionLabel;

  /// Actions to run, in order, when the toast's button is tapped.
  final List<ActionModel> actions;

  /// Optional icon before the message. Its own color wins over the
  /// message's; an image icon shows as is, e.g. a stamp.
  final MultiSourceIconModel? icon;

  /// Width and height of [icon].
  final double iconSize;

  /// Distance from the bottom of the screen when [position] is
  /// [ToastPosition.bottom].
  final double bottomOffset;

  /// [bottomOffset] per screen size, e.g. `{"mobile": 84}` to sit above a
  /// mobile tab bar. A screen size without an entry uses [bottomOffset].
  final Map<ScreenBreakpoint, double> bottomOffsets;

  /// Color of the button's label. Null uses the message's color.
  final ColorRGBA? actionColor;

  /// Whether the toast shows a close (×) button that dismisses it.
  final bool showClose;

  /// Color of the close button. Null uses the message's color.
  final ColorRGBA? closeColor;

  /// Corner radius. Null keeps the default: a pill without a button, and the
  /// app's button radius (at least 8) with one.
  final double? cornerRadius;

  /// Outline. Null draws none.
  final BorderSideModel? border;

  /// Drop shadows, e.g. a hard offset shadow (radius 0). Null keeps the
  /// default soft shadow; an empty list draws none.
  final List<Effect>? shadows;

  /// Space around the content. Null keeps the default.
  final EdgeInsetsModel? padding;

  /// The widest the toast grows.
  final double maxWidth;

  /// Font, size and color of the message. Unset values follow the app.
  final TextStyleModel? messageStyle;

  /// Font, size and color of the button's label. Unset values follow the
  /// app.
  final TextStyleModel? actionStyle;

  /// Color of a bar down the toast's left edge, e.g. a yellow or red accent.
  /// Null draws no bar.
  final ColorRGBA? accentColor;

  /// Width of the [accentColor] bar.
  final double accentWidth;

  /// Color of the [icon]. Null takes the message color.
  final ColorRGBA? iconColor;

  /// Font family of the message and button, e.g. `Barlow`. Null takes the
  /// app's font.
  final String? fontFamily;

  /// Where the toast sits across the screen.
  @JsonKey(unknownEnumValue: ToastAlignment.center)
  final ToastAlignment alignment;

  /// Space between the toast and the screen's sides.
  final double sideMargin;

  /// PR42's close-button key; [showClose] is the master key.
  final bool showCloseButton;

  /// Message font size. Null lets the renderer use its default (14).
  /// [messageStyle] takes precedence when it specifies a size.
  final double? fontSize;

  /// Weight of the message's text. Null is the app's.
  final FontWeightNumeric? fontWeight;

  /// Distance from the screen edge, as a variable or formula. When it gives
  /// a number it overrides [bottomOffset] and [bottomOffsets].
  final String offset;

  /// Creates a new [ShowToastAction].
  ShowToastAction({
    required this.message,
    this.duration = 2600,
    this.backgroundColor,
    this.textColor,
    this.style = ToastStyle.neutral,
    this.position = ToastPosition.bottom,
    this.actionLabel = '',
    List<ActionModel>? actions,
    this.icon,
    this.iconSize = 18,
    this.bottomOffset = 104,
    Map<ScreenBreakpoint, double>? bottomOffsets,
    this.actionColor,
    this.showClose = false,
    this.closeColor,
    this.cornerRadius,
    this.border,
    this.shadows,
    this.padding,
    this.maxWidth = 560,
    this.messageStyle,
    this.actionStyle,
    this.accentColor,
    this.accentWidth = 4,
    this.iconColor,
    this.fontFamily,
    this.alignment = ToastAlignment.center,
    this.sideMargin = 16,
    this.showCloseButton = false,
    this.fontSize,
    this.fontWeight,
    this.offset = '',
    super.nonBlocking,
    super.enabled,
  }) : actions = actions ?? [],
       bottomOffsets = bottomOffsets ?? {},
       super(type: ActionType.showToast);

  /// Whether the toast shows a button.
  bool get hasAction => actionLabel.trim().isNotEmpty;

  /// The distance from the bottom of a screen [width] wide.
  double bottomOffsetFor(double width) =>
      bottomOffsets[ScreenBreakpoint.forWidth(width)] ?? bottomOffset;

  @override
  List<Object?> get props => [
    message,
    duration,
    backgroundColor,
    textColor,
    style,
    position,
    actionLabel,
    actions,
    icon,
    iconSize,
    bottomOffset,
    bottomOffsets,
    actionColor,
    showClose,
    closeColor,
    cornerRadius,
    border,
    shadows,
    padding,
    maxWidth,
    messageStyle,
    actionStyle,
    accentColor,
    accentWidth,
    iconColor,
    fontFamily,
    alignment,
    sideMargin,
    showCloseButton,
    fontSize,
    fontWeight,
    offset,
  ];

  /// Duplicates this [ShowToastAction] with given data overrides.
  ShowToastAction copyWith({
    String? message,
    int? duration,
    ColorRGBA? backgroundColor,
    bool clearBackgroundColor = false,
    ColorRGBA? textColor,
    bool clearTextColor = false,
    ToastStyle? style,
    ToastPosition? position,
    String? actionLabel,
    List<ActionModel>? actions,
    MultiSourceIconModel? icon,
    bool clearIcon = false,
    double? iconSize,
    double? bottomOffset,
    Map<ScreenBreakpoint, double>? bottomOffsets,
    ColorRGBA? actionColor,
    bool clearActionColor = false,
    bool? showClose,
    ColorRGBA? closeColor,
    bool clearCloseColor = false,
    double? cornerRadius,
    bool clearCornerRadius = false,
    BorderSideModel? border,
    bool clearBorder = false,
    List<Effect>? shadows,
    bool clearShadows = false,
    EdgeInsetsModel? padding,
    bool clearPadding = false,
    double? maxWidth,
    TextStyleModel? messageStyle,
    bool clearMessageStyle = false,
    TextStyleModel? actionStyle,
    bool clearActionStyle = false,
    ColorRGBA? accentColor,
    bool clearAccentColor = false,
    double? accentWidth,
    ColorRGBA? iconColor,
    bool clearIconColor = false,
    String? fontFamily,
    bool clearFontFamily = false,
    ToastAlignment? alignment,
    double? sideMargin,
    bool? showCloseButton,
    double? fontSize,
    bool clearFontSize = false,
    FontWeightNumeric? fontWeight,
    bool clearFontWeight = false,
    String? offset,
  }) => ShowToastAction(
    message: message ?? this.message,
    duration: duration ?? this.duration,
    backgroundColor: clearBackgroundColor
        ? null
        : backgroundColor ?? this.backgroundColor,
    textColor: clearTextColor ? null : textColor ?? this.textColor,
    style: style ?? this.style,
    position: position ?? this.position,
    actionLabel: actionLabel ?? this.actionLabel,
    actions: actions ?? this.actions,
    icon: clearIcon ? null : icon ?? this.icon,
    iconSize: iconSize ?? this.iconSize,
    bottomOffset: bottomOffset ?? this.bottomOffset,
    bottomOffsets: bottomOffsets ?? this.bottomOffsets,
    actionColor: clearActionColor ? null : actionColor ?? this.actionColor,
    showClose: showClose ?? this.showClose,
    closeColor: clearCloseColor ? null : closeColor ?? this.closeColor,
    cornerRadius: clearCornerRadius ? null : cornerRadius ?? this.cornerRadius,
    border: clearBorder ? null : border ?? this.border,
    shadows: clearShadows ? null : shadows ?? this.shadows,
    padding: clearPadding ? null : padding ?? this.padding,
    maxWidth: maxWidth ?? this.maxWidth,
    messageStyle: clearMessageStyle ? null : messageStyle ?? this.messageStyle,
    actionStyle: clearActionStyle ? null : actionStyle ?? this.actionStyle,
    accentColor: clearAccentColor ? null : accentColor ?? this.accentColor,
    accentWidth: accentWidth ?? this.accentWidth,
    iconColor: clearIconColor ? null : iconColor ?? this.iconColor,
    fontFamily: clearFontFamily ? null : fontFamily ?? this.fontFamily,
    alignment: alignment ?? this.alignment,
    sideMargin: sideMargin ?? this.sideMargin,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    fontSize: clearFontSize ? null : fontSize ?? this.fontSize,
    fontWeight: clearFontWeight ? null : fontWeight ?? this.fontWeight,
    offset: offset ?? this.offset,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  /// Creates a new [ShowToastAction] instance from JSON data.
  factory ShowToastAction.fromJson(Map json) => _$ShowToastActionFromJson(json);

  @override
  Map toJson() =>
      _$ShowToastActionOmitDefaults(this, _$ShowToastActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitShowToastAction(this);
}
