import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Round-trips [value] through JSON text, as Firestore and the network do.
T roundTrip<T>(Object? value) => jsonDecode(jsonEncode(value)) as T;

void main() {
  group('PropertyOverridePatch', () {
    final Map<String, dynamic> base = {
      'id': 'button',
      'opacity': 0.5,
      'properties': {
        'label': 'Save',
        'buttonColor': {'r': 0, 'g': 0, 'b': 1, 'a': 1},
      },
      'fills': [
        {'type': 'SOLID'},
      ],
    };

    test('apply patches nested objects key by key and replaces lists', () {
      final Map<String, dynamic> result = PropertyOverridePatch.apply(base, {
        'properties': {
          'buttonColor': {'r': 1, 'g': 0, 'b': 0, 'a': 1},
        },
        'fills': [],
      });
      expect(result['properties']['label'], 'Save');
      expect(result['properties']['buttonColor']['r'], 1);
      expect(result['fills'], isEmpty);
      expect(result['opacity'], 0.5);
      // The input is not changed.
      expect(base['properties']['buttonColor']['r'], 0);
    });

    test('a null value removes the key so the default applies', () {
      final Map<String, dynamic> result = PropertyOverridePatch.apply(base, {
        'opacity': null,
      });
      expect(result.containsKey('opacity'), isFalse);
    });

    test('diff records only what changed, and apply(diff) restores it', () {
      final Map<String, dynamic> hovered = {
        'id': 'button',
        'properties': {
          'label': 'Save',
          'buttonColor': {'r': 1, 'g': 0, 'b': 1, 'a': 1},
        },
        'fills': [
          {'type': 'SOLID'},
        ],
      };
      final Map<String, dynamic> patch = PropertyOverridePatch.diff(
        base,
        hovered,
      );
      expect(patch, {
        // Back to the default opacity, which toJson omits.
        'opacity': null,
        'properties': {
          'buttonColor': {'r': 1},
        },
      });
      expect(PropertyOverridePatch.apply(base, patch), hovered);
      expect(PropertyOverridePatch.diff(base, base), isEmpty);
    });

    test('numbers compare by value (1 == 1.0 after JSON)', () {
      expect(PropertyOverridePatch.diff({'a': 1}, {'a': 1.0}), isEmpty);
    });

    test('merge layers later overrides over earlier ones', () {
      final PropertyOverrides merged = PropertyOverridePatch.merge([
        {
          'button': {
            'opacity': 0.8,
            'properties': {'label': 'Hover'},
          },
        },
        {
          'button': {
            'properties': {'label': 'Pressed'},
          },
          'icon': {'visible': false},
        },
      ]);
      expect(merged, {
        'button': {
          'opacity': 0.8,
          'properties': {'label': 'Pressed'},
        },
        'icon': {'visible': false},
      });
    });
  });

  group('interaction states on a node', () {
    test('round-trip through JSON and are omitted when empty', () {
      final RectangleNode plain = RectangleNode(
        id: 'box',
        name: 'Box',
        basicBoxLocal: NodeBox(0, 0, 10, 10),
      );
      expect(plain.toJson().containsKey('interactionStates'), isFalse);
      expect(plain.hasInteractionStates, isFalse);

      plain.interactionStates = {
        InteractionState.hovered: {
          'box': {'opacity': 0.5},
        },
        InteractionState.disabled: {
          'box': {'visible': false},
        },
      };
      final BaseNode decoded = NodeJsonConverter().fromJson(
        roundTrip<Map>(plain.toJson()),
      )!;
      expect(decoded.hasInteractionStates, isTrue);
      expect(decoded.interactionStates[InteractionState.hovered], {
        'box': {'opacity': 0.5},
      });
      expect(decoded.interactionStates.keys, [
        InteractionState.hovered,
        InteractionState.disabled,
      ]);
    });

    test('selected and disabled are switched by a property', () {
      expect(InteractionState.selected.property, 'selected');
      expect(InteractionState.disabled.property, 'disabled');
      expect(InteractionState.hovered.property, isNull);
      expect(InteractionState.pressed.label, 'Pressed');
    });
  });

  group('property-override variants', () {
    VarianceNode states() => VarianceNode(
      id: 'states',
      name: 'States',
      basicBoxLocal: NodeBox(0, 0, 100, 40),
      variants: [
        Variant(id: 'default', name: 'Default', children: ['card']),
        Variant(
          id: 'active',
          name: 'Active',
          children: [],
          overrides: {
            'card': {'opacity': 0.5},
          },
        ),
        Variant(id: 'copy', name: 'Copy', children: ['card-copy']),
      ],
    );

    test('show the default variant children', () {
      final VarianceNode node = states()..currentVariantId = 'active';
      expect(node.currentVariant.isOverride, isTrue);
      expect(node.children, ['card']);
      expect(node.unloadedVariantsChildren, ['card-copy']);
      expect(node.allVariantsChildren, ['card', 'card-copy']);
    });

    test('setting children while an override variant is current sets the '
        'default variant children', () {
      final VarianceNode node = states()..currentVariantId = 'active';
      node.children = ['card', 'badge'];
      expect(node.defaultVariant.children, ['card', 'badge']);
      expect(node.variants[1].children, isEmpty);
    });

    test('round-trip through JSON', () {
      final VarianceNode node = states();
      final VarianceNode decoded = VarianceNode.fromJson(
        roundTrip<Map>(node.toJson()),
      );
      expect(decoded.variants[1].overrides, {
        'card': {'opacity': 0.5},
      });
      expect(decoded.variants[0].isOverride, isFalse);
      expect(decoded.variants[0].toJson().containsKey('overrides'), isFalse);
    });
  });
}
