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

/// An action that shows a short message near the bottom or top of the screen,
/// then hides it. The toast can carry a button, e.g. Undo, that runs
/// [actions].
///
/// Its colors come from [style] and the app's theme unless [backgroundColor]
/// or [textColor] are set. Its font is the app's. It can show a close (✕)
/// button ([showClose]).
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

  /// Optional icon before the message.
  final MultiSourceIconModel? icon;

  /// Distance from the bottom of the screen when [position] is
  /// [ToastPosition.bottom].
  final double bottomOffset;

  /// Distance from the screen edge the toast shows at, bound to a variable
  /// or formula, e.g. `${= screen.isMobile ? 96 : 24}` to sit above a
  /// bottom bar on phones. Overrides [bottomOffset] (and the top inset when
  /// [position] is [ToastPosition.top]) when it gives a number. Empty to use
  /// [bottomOffset].
  final String offset;

  /// Color of the button's label, e.g. an orange Undo. Null takes the
  /// message color.
  final ColorRGBA? actionColor;

  /// Whether the toast shows a close (✕) button that hides it.
  final bool showClose;

  /// Radius of the toast's corners. Null makes a pill, or follows the app's
  /// button radius when the toast has a button.
  final double? cornerRadius;

  /// Size of the message's text. Null is 14.
  final double? fontSize;

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
    this.bottomOffset = 104,
    this.offset = '',
    this.actionColor,
    this.showClose = false,
    this.cornerRadius,
    this.fontSize,
    super.nonBlocking,
    super.enabled,
  }) : actions = actions ?? [],
       super(type: ActionType.showToast);

  /// Whether the toast shows a button.
  bool get hasAction => actionLabel.trim().isNotEmpty;

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
    bottomOffset,
    offset,
    actionColor,
    showClose,
    cornerRadius,
    fontSize,
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
    double? bottomOffset,
    String? offset,
    ColorRGBA? actionColor,
    bool clearActionColor = false,
    bool? showClose,
    double? cornerRadius,
    bool clearCornerRadius = false,
    double? fontSize,
    bool clearFontSize = false,
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
    bottomOffset: bottomOffset ?? this.bottomOffset,
    offset: offset ?? this.offset,
    actionColor: clearActionColor ? null : actionColor ?? this.actionColor,
    showClose: showClose ?? this.showClose,
    cornerRadius: clearCornerRadius ? null : cornerRadius ?? this.cornerRadius,
    fontSize: clearFontSize ? null : fontSize ?? this.fontSize,
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
