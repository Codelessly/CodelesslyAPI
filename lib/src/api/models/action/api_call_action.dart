import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'api_call_action.g.dart';

/// Holds information about an API call action to perform on a user interaction.
///
/// The response is the chain's `${result}` afterwards (`${result.data}`,
/// `${result.isError}`, `${result.statusCode}`, ...). [onSuccess] runs after a
/// 2xx response and [onError] after any other response or a failed request.
/// With [onError] actions, a failed request doesn't stop the chain.
@JsonSerializable()
class ApiCallAction extends ActionModel with Equatable, SerializableMixin {
  /// ID of the API to call.
  final String? apiId;

  /// Parameters to pass to the API.
  final Map<String, String> parameters;

  /// Actions to run, in order, after a successful (2xx) response.
  final List<ActionModel> onSuccess;

  /// Actions to run, in order, after an error response or a failed request.
  final List<ActionModel> onError;

  /// Creates an [ApiCallAction] with the given data.
  ApiCallAction({
    this.apiId,
    Map<String, String>? parameters,
    List<ActionModel>? onSuccess,
    List<ActionModel>? onError,
    super.nonBlocking,
    super.enabled,
  }) : parameters = parameters ?? {},
       onSuccess = onSuccess ?? [],
       onError = onError ?? [],
       super(type: ActionType.callApi);

  @override
  List<Object?> get props => [apiId, parameters, onSuccess, onError];

  /// Creates a copy of this [ApiCallAction] but with the given fields replaced
  /// with the new values.
  ApiCallAction copyWith({
    String? apiId,
    Map<String, String>? parameters,
    List<ActionModel>? onSuccess,
    List<ActionModel>? onError,
  }) => ApiCallAction(
    apiId: apiId ?? this.apiId,
    parameters: parameters ?? this.parameters,
    onSuccess: onSuccess ?? this.onSuccess,
    onError: onError ?? this.onError,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  /// Creates a new [ApiCallAction] from a JSON object.
  factory ApiCallAction.fromJson(Map json) => _$ApiCallActionFromJson(json);

  @override
  Map toJson() =>
      _$ApiCallActionOmitDefaults(this, _$ApiCallActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitApiCall(this);
}
