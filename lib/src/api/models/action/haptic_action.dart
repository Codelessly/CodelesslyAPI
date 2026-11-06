import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'haptic_action.g.dart';

/// How strong a [HapticAction] buzz is.
enum HapticKind {
  /// The faint tick of a picker or a dial detent.
  selection,

  /// A light knock.
  light,

  /// A medium knock: a dial's click on the right number.
  medium,

  /// A heavy knock: a tumbler dropping, a door unlocking.
  heavy,

  /// A long buzz: an error, an alarm.
  vibrate;

  /// Displayable name.
  String get prettify => switch (this) {
    HapticKind.selection => 'Selection tick',
    HapticKind.light => 'Light',
    HapticKind.medium => 'Medium',
    HapticKind.heavy => 'Heavy',
    HapticKind.vibrate => 'Vibrate',
  };
}

/// Buzzes the device (on phones that support it; nothing elsewhere): a
/// tick per dial detent, a knock on the right number.
@JsonSerializable()
class HapticAction extends ActionModel with Equatable, SerializableMixin {
  /// How strong.
  final HapticKind kind;

  /// A formula: the buzz only happens while it is true, e.g.
  /// `${= settings.haptics}`. Empty always buzzes.
  final String when;

  /// Creates a [HapticAction].
  HapticAction({
    this.kind = HapticKind.selection,
    this.when = '',
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.haptic);

  /// Duplicates this action with the given values replaced.
  HapticAction copyWith({HapticKind? kind, String? when}) => HapticAction(
    kind: kind ?? this.kind,
    when: when ?? this.when,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [kind, when];

  /// Creates an instance from a JSON object.
  factory HapticAction.fromJson(Map json) => _$HapticActionFromJson(json);

  @override
  Map toJson() => _$HapticActionOmitDefaults(this, _$HapticActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitHapticAction(this);
}
