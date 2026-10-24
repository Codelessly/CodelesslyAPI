import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../condition.dart';
import 'action.dart';
import '../../json_defaults.dart';

part 'navigation_action.g.dart';

/// Defines how the navigation should be performed.
enum NavigationType {
  /// Navigate to the specified page.
  push,

  /// Navigate back from the current page.
  pop,

  /// Replace the current page with the specified page in the navigation stack.
  replace,

  /// Clear the navigation history and open the specified page, with
  /// [NavigationAction.baseDestinationId] (if set) beneath it, so going back
  /// leads there and no further: Flutter's `pushNamedAndRemoveUntil`. For
  /// example, after creating a trip, open the trip above the trips list
  /// instead of above the creation form.
  reset;

  /// Displayable string representation of [NavigationType].
  String get prettify {
    switch (this) {
      case NavigationType.push:
        return 'Navigate to page';
      case NavigationType.pop:
        return 'Navigate back';
      case NavigationType.replace:
        return 'Replace page';
      case NavigationType.reset:
        return 'Clear history and navigate';
    }
  }
}

Object? _readDestinationId(Map json, String key) => json[key] ?? '';

/// An action that navigates to a new page.
@JsonSerializable()
class NavigationAction extends ActionModel with Equatable, SerializableMixin {
  /// Defines how the navigation should be performed.
  final NavigationType navigationType;

  /// Destination canvas node's ID. For a pop it is an optional fallback.
  /// Empty when no fallback is provided; written for older readers.
  @JsonLegacyDefault(null)
  @JsonKey(readValue: _readDestinationId)
  final String destinationId;

  /// Parameters to pass to the destination page.
  final Map<String, dynamic> params;

  /// For [NavigationType.reset]: the canvas left beneath the destination
  /// once the history is cleared, which going back from the destination
  /// opens. Null leaves the destination alone in the history.
  final String? baseDestinationId;

  /// Parameters to pass to the [baseDestinationId] page.
  final Map<String, dynamic>? baseParams;

  /// Creates a new [NavigationAction].
  NavigationAction({
    this.navigationType = NavigationType.push,
    this.destinationId = '',
    Map<String, dynamic>? params,
    this.baseDestinationId,
    this.baseParams,
    super.nonBlocking,
    super.enabled,
  }) : params = {...params ?? {}},
       super(type: ActionType.navigation);

  @override
  List<Object?> get props => [
    destinationId,
    navigationType,
    params,
    baseDestinationId,
    baseParams,
  ];

  /// Duplicates this [NavigationAction] with given data overrides.
  NavigationAction copyWith({
    NavigationType? navigationType,
    String? destinationId,
    Map<String, String>? params,
    String? baseDestinationId,
    Map<String, dynamic>? baseParams,
  }) => NavigationAction(
    navigationType: navigationType ?? this.navigationType,
    destinationId: destinationId ?? this.destinationId,
    params: {...this.params, ...params ?? {}},
    baseDestinationId: baseDestinationId ?? this.baseDestinationId,
    baseParams: baseParams ?? this.baseParams,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  /// Creates a new [NavigationAction] instance from a JSON data.
  factory NavigationAction.fromJson(Map json) =>
      _$NavigationActionFromJson(json);

  @override
  Map toJson() =>
      _$NavigationActionOmitDefaults(this, _$NavigationActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitNavigationAction(this);
}
