import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../condition.dart';
import 'action.dart';

part 'link_action.g.dart';

/// An action that opens up a link.
@JsonSerializable()
class LinkAction extends ActionModel with EquatableMixin, SerializableMixin {
  /// The link to open.
  final String url;

  /// Creates a new [LinkAction] with the given data.
  LinkAction({
    required this.url,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.link);

  @override
  List<Object?> get props => [url];

  /// Duplicate this [LinkAction] with the given data overrides.
  LinkAction copyWith({String? url}) => LinkAction(url: url ?? this.url);

  /// Factory constructor for creating a new [LinkAction] instance from
  /// JSON data.
  factory LinkAction.fromJson(Map json) => _$LinkActionFromJson(json);

  @override
  Map toJson() => _$LinkActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitLinkAction(this);
}
