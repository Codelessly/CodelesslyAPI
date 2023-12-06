import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../condition.dart';
import 'action.dart';

part 'api_call_action.g.dart';

/// Holds information about an API call action to perform on a user interaction.
@JsonSerializable()
class ApiCallAction extends ActionModel with EquatableMixin, SerializableMixin {
  /// ID of the API to call.
  final String? apiId;

  /// Parameters to pass to the API.
  final Map<String, String> parameters;

  /// Creates an [ApiCallAction] with the given data.
  ApiCallAction({
    this.apiId,
    Map<String, String>? parameters,
    super.nonBlocking,
  })  : parameters = parameters ?? {},
        super(type: ActionType.callApi);

  @override
  List<Object?> get props => [apiId, parameters];

  /// Creates a copy of this [ApiCallAction] but with the given fields replaced
  /// with the new values.
  ApiCallAction copyWith({
    String? apiId,
    Map<String, String>? parameters,
  }) =>
      ApiCallAction(
        apiId: apiId ?? this.apiId,
        parameters: parameters ?? this.parameters,
      );

  /// Creates a new [ApiCallAction] from a JSON object.
  factory ApiCallAction.fromJson(Map json) => _$ApiCallActionFromJson(json);

  @override
  Map toJson() => _$ApiCallActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitApiCall(this);
}
