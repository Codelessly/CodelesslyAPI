import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_toast_action.g.dart';

/// An action that shows a short message in a pill near the bottom of the
/// screen, then hides it.
@JsonSerializable()
class ShowToastAction extends ActionModel with Equatable, SerializableMixin {
  /// The message. Supports variables and formulas, e.g.
  /// `Added ${storage.drink.name} to your order`.
  final String message;

  /// How long the message stays on screen, in milliseconds.
  final int duration;

  /// Pill color.
  final ColorRGBA backgroundColor;

  /// Message color.
  final ColorRGBA textColor;

  /// Optional icon before the message.
  final MultiSourceIconModel? icon;

  /// Distance from the bottom of the screen.
  final double bottomOffset;

  /// Creates a new [ShowToastAction].
  ShowToastAction({
    required this.message,
    this.duration = 2600,
    this.backgroundColor = const ColorRGBA(r: 0.169, g: 0.141, b: 0.125, a: 1),
    this.textColor = ColorRGBA.white,
    this.icon,
    this.bottomOffset = 104,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.showToast);

  @override
  List<Object?> get props => [
    message,
    duration,
    backgroundColor,
    textColor,
    icon,
    bottomOffset,
  ];

  /// Duplicates this [ShowToastAction] with given data overrides.
  ShowToastAction copyWith({
    String? message,
    int? duration,
    ColorRGBA? backgroundColor,
    ColorRGBA? textColor,
    MultiSourceIconModel? icon,
    bool clearIcon = false,
    double? bottomOffset,
  }) => ShowToastAction(
    message: message ?? this.message,
    duration: duration ?? this.duration,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    textColor: textColor ?? this.textColor,
    icon: clearIcon ? null : icon ?? this.icon,
    bottomOffset: bottomOffset ?? this.bottomOffset,
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
