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
///
/// A toast with a [title] is a card: the bold title with [message] as a body
/// line under it, e.g. "Gate change" over "MR 88 now boards at A11".
/// [iconDiscColor] puts the [icon] in a filled circle.
///
/// The colors can follow data: [variables] maps a color field's name (see
/// [bindableColors]) to a variable path or formula giving a color, e.g.
/// `{"backgroundColor": "${pal.surface}",
/// "iconDiscColor": "${= alpha(alert.color, 0.18)}"}`. A binding that gives
/// a color wins over the field; one that gives nothing keeps the field.
@JsonSerializable()
class ShowToastAction extends ActionModel with Equatable, SerializableMixin {
  /// The message. Supports variables and formulas, e.g.
  /// `Added ${storage.drink.name} to your order`. Under a [title] it is the
  /// body line. JSON may name it `body`.
  @JsonKey(readValue: _readMessage)
  final String message;

  /// Bold line above [message]. Supports variables and formulas. Empty (the
  /// default) shows the message alone.
  final String title;

  /// Font, size and color of the [title]. Unset values follow the message,
  /// in bold.
  final TextStyleModel? titleStyle;

  /// Color of [message]. Null takes the text color, a little faded under a
  /// [title].
  final ColorRGBA? messageColor;

  /// Fill of a circle behind the [icon], e.g. the accent at 18% opacity.
  /// Null draws the icon without one.
  final ColorRGBA? iconDiscColor;

  /// Diameter of the [iconDiscColor] circle.
  final double iconDiscSize;

  /// [alignment] per screen size, e.g. `{"mobile": "stretch"}` with
  /// alignment `end` for a full-width toast on phones and one at the right
  /// elsewhere. A screen size without an entry uses [alignment].
  final Map<ScreenBreakpoint, ToastAlignment> alignments;

  /// [sideMargin] per screen size. A screen size without an entry uses
  /// [sideMargin].
  final Map<ScreenBreakpoint, double> sideMargins;

  /// Color bindings: a color field's name (one of [bindableColors]) to a
  /// variable path or formula that gives a color, e.g. `${pal.surface}` or
  /// `${= alpha(pal.gold, 0.5)}`.
  final Map<String, String> variables;

  /// The color fields [variables] can bind. `borderColor` colors the
  /// [border] (a 1px one when there is none).
  static const List<String> bindableColors = <String>[
    'backgroundColor',
    'textColor',
    'messageColor',
    'accentColor',
    'iconColor',
    'iconDiscColor',
    'actionColor',
    'closeColor',
    'borderColor',
  ];

  /// How long the message stays on screen, in milliseconds. Zero or less
  /// keeps it up until it is closed or replaced. [variables] can bind it:
  /// `{"duration": "${= toast.sticky ? 0 : 6000}"}`.
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

  /// Fill of the action button. Null keeps a plain text button. With
  /// [actionBorder], [actionShadows] and [actionCornerRadius] the button
  /// can match the app's own buttons, e.g. a snow button with an ink
  /// outline and a hard ink shadow on an ink toast.
  final ColorRGBA? actionBackgroundColor;

  /// Outline of the action button. Null draws none.
  final BorderSideModel? actionBorder;

  /// Shadows of the action button, e.g. a hard offset shadow (radius 0).
  /// Null draws none.
  final List<Effect>? actionShadows;

  /// Corner radius of the action button. Null keeps the default.
  final double? actionCornerRadius;

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

  /// The narrowest the toast gets (at most the room it has), e.g. 380 with a
  /// [maxWidth] of 380 for a card that is always 380 wide. 0 (the default)
  /// hugs the content.
  final double minWidth;

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

  /// Tilt of the toast in degrees, e.g. -1.5 for a sticky note stuck on
  /// slightly crooked. 0 for none.
  final double rotation;

  /// The curve the toast comes in on: a [MotionCurve] name such as
  /// `easeOutBack` (a note that drops in and settles) or `elasticOut`.
  final String enterCurve;

  /// How far the toast travels as it comes in, as a share of its height
  /// (from above for a top toast, below for a bottom one): 0.25 slides in
  /// a little, 1 drops in from a whole toast away.
  final double enterOffset;

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
    this.actionBackgroundColor,
    this.actionBorder,
    this.actionShadows,
    this.actionCornerRadius,
    this.showClose = false,
    this.closeColor,
    this.cornerRadius,
    this.border,
    this.shadows,
    this.padding,
    this.maxWidth = 560,
    this.minWidth = 0,
    this.messageStyle,
    this.actionStyle,
    this.accentColor,
    this.accentWidth = 4,
    this.rotation = 0,
    this.enterCurve = 'easeOutCubic',
    this.enterOffset = 0.25,
    this.iconColor,
    this.fontFamily,
    this.alignment = ToastAlignment.center,
    this.sideMargin = 16,
    this.showCloseButton = false,
    this.fontSize,
    this.fontWeight,
    this.offset = '',
    this.title = '',
    this.titleStyle,
    this.messageColor,
    this.iconDiscColor,
    this.iconDiscSize = 36,
    Map<ScreenBreakpoint, ToastAlignment>? alignments,
    Map<ScreenBreakpoint, double>? sideMargins,
    Map<String, String>? variables,
    super.nonBlocking,
    super.enabled,
  }) : actions = actions ?? [],
       bottomOffsets = bottomOffsets ?? {},
       alignments = alignments ?? {},
       sideMargins = sideMargins ?? {},
       variables = variables ?? {},
       super(type: ActionType.showToast);

  /// Whether the toast shows a button.
  bool get hasAction => actionLabel.trim().isNotEmpty;

  /// The distance from the bottom of a screen [width] wide.
  double bottomOffsetFor(double width) =>
      bottomOffsets[ScreenBreakpoint.forWidth(width)] ?? bottomOffset;

  /// Where the toast sits across a screen [width] wide.
  ToastAlignment alignmentFor(double width) =>
      alignments[ScreenBreakpoint.forWidth(width)] ?? alignment;

  /// The space between the toast and the sides of a screen [width] wide.
  double sideMarginFor(double width) =>
      sideMargins[ScreenBreakpoint.forWidth(width)] ?? sideMargin;

  /// Whether the toast shows a [title] line.
  bool get hasTitle => title.trim().isNotEmpty;

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
    actionBackgroundColor,
    actionBorder,
    actionShadows,
    actionCornerRadius,
    showClose,
    closeColor,
    cornerRadius,
    border,
    shadows,
    padding,
    maxWidth,
    minWidth,
    messageStyle,
    actionStyle,
    accentColor,
    accentWidth,
    rotation,
    enterCurve,
    enterOffset,
    iconColor,
    fontFamily,
    alignment,
    sideMargin,
    showCloseButton,
    fontSize,
    fontWeight,
    offset,
    title,
    titleStyle,
    messageColor,
    iconDiscColor,
    iconDiscSize,
    alignments,
    sideMargins,
    variables,
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
    ColorRGBA? actionBackgroundColor,
    BorderSideModel? actionBorder,
    List<Effect>? actionShadows,
    double? actionCornerRadius,
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
    double? minWidth,
    TextStyleModel? messageStyle,
    bool clearMessageStyle = false,
    TextStyleModel? actionStyle,
    bool clearActionStyle = false,
    ColorRGBA? accentColor,
    bool clearAccentColor = false,
    double? accentWidth,
    double? rotation,
    String? enterCurve,
    double? enterOffset,
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
    String? title,
    TextStyleModel? titleStyle,
    bool clearTitleStyle = false,
    ColorRGBA? messageColor,
    bool clearMessageColor = false,
    ColorRGBA? iconDiscColor,
    bool clearIconDiscColor = false,
    double? iconDiscSize,
    Map<ScreenBreakpoint, ToastAlignment>? alignments,
    Map<ScreenBreakpoint, double>? sideMargins,
    Map<String, String>? variables,
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
    actionBackgroundColor: actionBackgroundColor ?? this.actionBackgroundColor,
    actionBorder: actionBorder ?? this.actionBorder,
    actionShadows: actionShadows ?? this.actionShadows,
    actionCornerRadius: actionCornerRadius ?? this.actionCornerRadius,
    showClose: showClose ?? this.showClose,
    closeColor: clearCloseColor ? null : closeColor ?? this.closeColor,
    cornerRadius: clearCornerRadius ? null : cornerRadius ?? this.cornerRadius,
    border: clearBorder ? null : border ?? this.border,
    shadows: clearShadows ? null : shadows ?? this.shadows,
    padding: clearPadding ? null : padding ?? this.padding,
    maxWidth: maxWidth ?? this.maxWidth,
    minWidth: minWidth ?? this.minWidth,
    messageStyle: clearMessageStyle ? null : messageStyle ?? this.messageStyle,
    actionStyle: clearActionStyle ? null : actionStyle ?? this.actionStyle,
    accentColor: clearAccentColor ? null : accentColor ?? this.accentColor,
    accentWidth: accentWidth ?? this.accentWidth,
    rotation: rotation ?? this.rotation,
    enterCurve: enterCurve ?? this.enterCurve,
    enterOffset: enterOffset ?? this.enterOffset,
    iconColor: clearIconColor ? null : iconColor ?? this.iconColor,
    fontFamily: clearFontFamily ? null : fontFamily ?? this.fontFamily,
    alignment: alignment ?? this.alignment,
    sideMargin: sideMargin ?? this.sideMargin,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    fontSize: clearFontSize ? null : fontSize ?? this.fontSize,
    fontWeight: clearFontWeight ? null : fontWeight ?? this.fontWeight,
    offset: offset ?? this.offset,
    title: title ?? this.title,
    titleStyle: clearTitleStyle ? null : titleStyle ?? this.titleStyle,
    messageColor: clearMessageColor ? null : messageColor ?? this.messageColor,
    iconDiscColor: clearIconDiscColor
        ? null
        : iconDiscColor ?? this.iconDiscColor,
    iconDiscSize: iconDiscSize ?? this.iconDiscSize,
    alignments: alignments ?? this.alignments,
    sideMargins: sideMargins ?? this.sideMargins,
    variables: variables ?? this.variables,
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

/// [ShowToastAction.message], or its `body` alias, or empty.
Object? _readMessage(Map json, String key) =>
    json[key] ?? json['body'] ?? '';
