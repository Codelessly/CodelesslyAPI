/// The interaction states a node can show, in the order they apply: when
/// more than one is active, the later one wins where they change the same
/// property (a pressed button that is also hovered looks pressed).
enum InteractionState {
  /// A pointer is over the node.
  hovered('Hover'),

  /// The node, or an input inside it, has keyboard focus.
  focused('Focused'),

  /// A pointer is pressing the node.
  pressed('Pressed'),

  /// The node's `selected` property is true (bound to a variable or set by a
  /// condition).
  selected('Selected'),

  /// The node's `disabled` property is true. A disabled node does not run
  /// its actions.
  disabled('Disabled');

  /// The name shown to builders.
  final String label;

  const InteractionState(this.label);

  /// The property a builder binds to switch this state on, for the states
  /// the app decides rather than the pointer or the keyboard.
  String? get property => switch (this) {
    InteractionState.selected => 'selected',
    InteractionState.disabled => 'disabled',
    _ => null,
  };
}

/// Changes to node properties that a state makes: a node id to the
/// properties of that node to change, as a sparse JSON patch of the node.
///
/// A patch holds only what differs from the node. Nested objects (such as a
/// node's `properties`) are patched key by key, lists and values are
/// replaced, and a null value removes the key so the node falls back to that
/// property's default.
typedef PropertyOverrides = Map<String, Map<String, dynamic>>;

/// Applying and recording [PropertyOverrides]. The SDK applies them to show
/// a state; the editor records them by diffing a node edited in a state
/// against the node outside of it. Both use these two functions so a patch
/// always means the same thing.
abstract final class PropertyOverridePatch {
  /// Returns [json] with [patch] applied.
  static Map<String, dynamic> apply(Map json, Map patch) {
    final Map<String, dynamic> result = {
      for (final MapEntry entry in json.entries) '${entry.key}': entry.value,
    };
    for (final MapEntry entry in patch.entries) {
      final String key = '${entry.key}';
      final Object? value = entry.value;
      final Object? current = result[key];
      if (value == null) {
        result.remove(key);
      } else if (value is Map && current is Map) {
        result[key] = apply(current, value);
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  /// The patch that turns [from] into [to]: what [apply] needs so that
  /// `apply(from, diff(from, to))` equals [to]. Empty when they are equal.
  static Map<String, dynamic> diff(Map from, Map to) {
    final Map<String, dynamic> patch = {};
    for (final MapEntry entry in to.entries) {
      final String key = '${entry.key}';
      final Object? before = from[key];
      final Object? after = entry.value;
      if (after is Map && before is Map) {
        final Map<String, dynamic> nested = diff(before, after);
        if (nested.isNotEmpty) patch[key] = nested;
      } else if (!_jsonEquals(before, after)) {
        patch[key] = after;
      }
    }
    for (final Object? key in from.keys) {
      if (!to.containsKey(key)) patch['$key'] = null;
    }
    return patch;
  }

  /// Merges [overrides] layered in order: a later one wins for the same
  /// node and property.
  static PropertyOverrides merge(Iterable<PropertyOverrides> overrides) {
    final PropertyOverrides merged = {};
    for (final PropertyOverrides layer in overrides) {
      for (final MapEntry<String, Map<String, dynamic>> entry
          in layer.entries) {
        final Map<String, dynamic>? current = merged[entry.key];
        merged[entry.key] = current == null
            ? {...entry.value}
            : _mergePatches(current, entry.value);
      }
    }
    return merged;
  }

  static Map<String, dynamic> _mergePatches(Map a, Map b) {
    final Map<String, dynamic> result = {
      for (final MapEntry entry in a.entries) '${entry.key}': entry.value,
    };
    for (final MapEntry entry in b.entries) {
      final String key = '${entry.key}';
      final Object? value = entry.value;
      final Object? current = result[key];
      result[key] = value is Map && current is Map
          ? _mergePatches(current, value)
          : value;
    }
    return result;
  }

  static bool _jsonEquals(Object? a, Object? b) {
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final MapEntry entry in a.entries) {
        if (!b.containsKey(entry.key)) return false;
        if (!_jsonEquals(entry.value, b[entry.key])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_jsonEquals(a[i], b[i])) return false;
      }
      return true;
    }
    if (a is num && b is num) return a == b;
    return a == b;
  }
}
