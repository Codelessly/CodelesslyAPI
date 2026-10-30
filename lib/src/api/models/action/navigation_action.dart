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

/// How the screen opened by a [NavigationAction] comes in, and how it leaves
/// when going back. Shared elements (nodes with a `heroTag`) fly with every
/// transition.
enum PageTransition {
  /// The platform's default page transition (Flutter's `MaterialPageRoute`):
  /// zoom on Android, slide on iOS and macOS.
  platform,

  /// No animation: the screen is shown at once.
  none,

  /// The screen fades in.
  fade,

  /// The screen fades in while it rises a little (3% of its height).
  fadeUp,

  /// The screen slides up from the bottom edge.
  slideUp,

  /// The screen slides in from the right edge (from the left for
  /// right-to-left text).
  slideLeft,

  /// The screen fades in while it grows from 90% of its size.
  scale;

  /// Displayable name.
  String get prettify => switch (this) {
    PageTransition.platform => 'Platform default',
    PageTransition.none => 'None',
    PageTransition.fade => 'Fade',
    PageTransition.fadeUp => 'Fade up',
    PageTransition.slideUp => 'Slide up',
    PageTransition.slideLeft => 'Slide left',
    PageTransition.scale => 'Scale',
  };

  /// Milliseconds the transition takes when the action doesn't give
  /// [NavigationAction.transitionMs].
  int get defaultDurationMs => switch (this) {
    PageTransition.platform => 300,
    PageTransition.none => 0,
    PageTransition.fade => 250,
    PageTransition.fadeUp => 520,
    PageTransition.slideUp => 400,
    PageTransition.slideLeft => 350,
    PageTransition.scale => 300,
  };
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

  /// How the destination screen comes in for a push, replace or reset (and
  /// leaves when going back from it). Ignored by a pop, which plays the
  /// reverse of the transition the screen came in with.
  final PageTransition transition;

  /// Milliseconds the [transition] takes. Null uses the transition's
  /// default ([PageTransition.defaultDurationMs]). Not used by
  /// [PageTransition.platform], whose timing belongs to the platform. With
  /// [PageTransition.none] the screen still shows at once, but its shared
  /// elements fly for this long.
  final int? transitionMs;

  /// Milliseconds the [transition] takes in reverse, when going back from
  /// the destination. Null uses [resolvedTransitionMs].
  final int? reverseTransitionMs;

  /// Milliseconds the [transition] takes forward.
  int get resolvedTransitionMs =>
      (transitionMs ?? transition.defaultDurationMs).clamp(0, 60000);

  /// Milliseconds the [transition] takes in reverse.
  int get resolvedReverseTransitionMs =>
      (reverseTransitionMs ?? resolvedTransitionMs).clamp(0, 60000);

  /// Creates a new [NavigationAction].
  NavigationAction({
    this.navigationType = NavigationType.push,
    this.destinationId = '',
    Map<String, dynamic>? params,
    this.baseDestinationId,
    this.baseParams,
    this.transition = PageTransition.platform,
    this.transitionMs,
    this.reverseTransitionMs,
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
    transition,
    transitionMs,
    reverseTransitionMs,
  ];

  /// Duplicates this [NavigationAction] with given data overrides.
  NavigationAction copyWith({
    NavigationType? navigationType,
    String? destinationId,
    Map<String, String>? params,
    String? baseDestinationId,
    Map<String, dynamic>? baseParams,
    PageTransition? transition,
    int? transitionMs,
    int? reverseTransitionMs,
  }) => NavigationAction(
    navigationType: navigationType ?? this.navigationType,
    destinationId: destinationId ?? this.destinationId,
    params: {...this.params, ...params ?? {}},
    baseDestinationId: baseDestinationId ?? this.baseDestinationId,
    baseParams: baseParams ?? this.baseParams,
    transition: transition ?? this.transition,
    transitionMs: transitionMs ?? this.transitionMs,
    reverseTransitionMs: reverseTransitionMs ?? this.reverseTransitionMs,
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
