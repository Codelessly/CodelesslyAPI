import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

/// Encodes [node] to JSON text and reads it back through the registry, the
/// way a stored layout is loaded.
BaseNode roundTrip(BaseNode node) => NodeJsonConverter.instance.fromJson(
  jsonDecode(jsonEncode(node.toJson())) as Map,
)!;

Object? encodeDecode(Object? json) => jsonDecode(jsonEncode(json));

void main() {
  final customNodes = <BaseNode>[
    BadgeNode(
      id: 'badge_custom',
      name: 'Badge',
      basicBoxLocal: NodeBox(0, 0, 40, 40),
      childID: 'icon',
      reactions: [
        Reaction(
          trigger: TriggerModel(type: TriggerType.click),
          action: NavigationAction(destinationId: 'page'),
        ),
      ],
      properties: BadgeProperties(
        badgeType: BadgeType.label,
        label: 'NEW',
        maxCount: 99,
        backgroundColor: ColorRGBA.black,
        textColor: ColorRGBA.white,
        textStyle: TextProp.general(fontSize: 10),
        alignment: BadgeAlignment.bottomLeft,
        offsetX: 2,
        offsetY: 3,
        isLabelVisible: false,
        smallSize: 8,
        largeSize: 20,
        padding: const EdgeInsetsModel.all(2),
      ),
    ),
    ChipNode(
      id: 'chip_custom',
      name: 'Chip',
      basicBoxLocal: NodeBox(0, 0, 120, 32),
      properties: ChipProperties(
        chipType: ChipType.input,
        label: 'a@b.c',
        labelStyle: TextProp.general(fontSize: 13),
        icon: const MultiSourceIconModel(size: 18),
        avatar: 'https://example.com/a.png',
        deleteIcon: const MultiSourceIconModel(size: 16),
        deleteIconColor: ColorRGBA.transparent,
        selected: true,
        showCheckmark: false,
        checkmarkColor: ColorRGBA.white,
        backgroundColor: ColorRGBA.white,
        selectedColor: ColorRGBA.black,
        borderColor: ColorRGBA.transparent,
        borderWidth: 2,
        cornerRadius: 16,
        elevation: 1,
        shadowColor: ColorRGBA.black,
        padding: const EdgeInsetsModel.all(4),
        labelPadding: const EdgeInsetsModel.symmetric(horizontal: 4),
        tooltip: 'Remove',
        autofocus: true,
      ),
    ),
    SegmentedButtonNode(
      id: 'segmented_custom',
      name: 'Segmented',
      basicBoxLocal: NodeBox(0, 0, 200, 40),
      properties: SegmentedButtonProperties(
        segments: const [
          ButtonSegmentModel(value: 'a', label: 'A', tooltip: 'First'),
          ButtonSegmentModel(
            value: 'b',
            icon: MultiSourceIconModel(size: 18),
            enabled: false,
          ),
        ],
        selected: const ['a', 'b'],
        multiSelectionEnabled: true,
        emptySelectionAllowed: true,
        showSelectedIcon: false,
        selectedIcon: const MultiSourceIconModel(size: 18),
        direction: AxisC.vertical,
        borderColor: ColorRGBA.transparent,
        borderWidth: 2,
        selectedBackgroundColor: ColorRGBA.black,
        backgroundColor: ColorRGBA.white,
        selectedForegroundColor: ColorRGBA.white,
        foregroundColor: ColorRGBA.black,
        cornerRadius: const CornerRadius.all(RadiusModel.circular(4)),
      ),
    ),
  ];

  group('round trip through NodeJsonConverter', () {
    for (final node in [
      BadgeNode.empty(),
      ChipNode.empty(),
      SegmentedButtonNode.empty(),
      ...customNodes,
    ]) {
      test('${node.type} "${node.id}"', () {
        final restored = roundTrip(node);
        expect(restored.runtimeType, node.runtimeType);
        expect(restored, node);
        expect(
          (restored as CustomPropertiesMixin).properties,
          (node as CustomPropertiesMixin).properties,
        );
        expect(encodeDecode(restored.toJson()), encodeDecode(node.toJson()));
      });
    }
  });

  group('defaults are omitted from JSON', () {
    test('badge', () {
      final json = encodeDecode(BadgeProperties().toJson()) as Map;
      expect(json.keys, ['labelStyle']);
    });

    test('chip', () {
      final json = encodeDecode(ChipProperties().toJson()) as Map;
      expect(json.keys, ['labelStyle']);
    });

    test('segmented button', () {
      expect(SegmentedButtonProperties().toJson(), isEmpty);
      expect(
        SegmentedButtonProperties.fromJson({}),
        SegmentedButtonProperties(),
      );
    });

    test('custom values are written under the original keys', () {
      final badge = BadgeProperties(
        smallSize: 9,
        textStyle: TextProp.general(fontSize: 9),
      ).toJson();
      expect(badge, contains('dotSize'));
      expect(badge, contains('labelStyle'));
      final segmented = SegmentedButtonProperties(
        selected: const ['x'],
        selectedBackgroundColor: ColorRGBA.black,
        backgroundColor: ColorRGBA.white,
      ).toJson();
      expect(segmented['selectedSegments'], ['x']);
      expect(segmented, contains('selectedColor'));
      expect(segmented, contains('unselectedColor'));
    });
  });

  group('JSON written by the migrate-json-serializable branch', () {
    final branch = fixture('node_json_branch.json');

    test('badge', () {
      final node =
          NodeJsonConverter.instance.fromJson(branch['branch_badge'])!
              as BadgeNode;
      expect(node.childID, 'icon-1');
      final properties = node.properties;
      expect(properties.badgeType, BadgeType.count);
      expect(properties.label, '1200');
      expect(properties.effectiveLabel(), '999+');
      expect(
        properties.backgroundColor,
        const ColorRGBA(r: 1, g: 0, b: 0, a: 1),
      );
      expect(properties.alignment, BadgeAlignment.topLeft);
      // The branch always wrote its offsets, so its 0 default is kept.
      expect(properties.offsetX, 0);
      expect(properties.offsetY, 0);
      expect(properties.smallSize, 6);
      expect(properties.textStyle.fontSize, 12);
      expect(roundTrip(node), node);
    });

    test('chip', () {
      final node =
          NodeJsonConverter.instance.fromJson(branch['branch_chip'])!
              as ChipNode;
      final properties = node.properties;
      expect(properties.chipType, ChipType.filter);
      expect(properties.label, 'Category');
      expect(properties.selected, isTrue);
      expect(properties.icon?.size, 18);
      expect(properties.selectedColor, const ColorRGBA(r: 1, g: 0, b: 0, a: 1));
      // The branch always wrote its paddings, so its old defaults are kept.
      expect(
        properties.padding,
        const EdgeInsetsModel.symmetric(horizontal: 12),
      );
      expect(
        properties.labelPadding,
        const EdgeInsetsModel.symmetric(horizontal: 8, vertical: 4),
      );
      expect(roundTrip(node), node);
    });

    test('segmented button', () {
      final node =
          NodeJsonConverter.instance.fromJson(
                branch['branch_segmented_button'],
              )!
              as SegmentedButtonNode;
      final properties = node.properties;
      expect(properties.segments.map((s) => s.value), ['day', 'week', 'month']);
      expect(properties.selected, ['week']);
      expect(
        properties.selectedBackgroundColor,
        const ColorRGBA(r: 1, g: 0, b: 0, a: 1),
      );
      expect(properties.backgroundColor, isNull);
      expect(
        properties.cornerRadius,
        const CornerRadius.all(RadiusModel.circular(20)),
      );
      expect(roundTrip(node), node);
    });

    test('badge fixtures', () {
      final basic =
          NodeJsonConverter.instance.fromJson(fixture('badge_01_basic.json'))!
              as BadgeNode;
      expect(basic.properties.label, '5');
      expect(basic.properties.isLabelVisible, isTrue);
      expect(basic.childID, isNull);
      expect(basic.basicBoxLocal.width, 24);

      final withChild =
          NodeJsonConverter.instance.fromJson(
                fixture('badge_02_with_child.json'),
              )!
              as BadgeNode;
      expect(withChild.childID, 'icon-1');
      expect(withChild.properties.label, '99+');
      expect(withChild.properties.textColor, ColorRGBA.white);
      expect(
        withChild.properties.backgroundColor,
        const ColorRGBA(r: 1, g: 0, b: 0, a: 1),
      );
    });
  });

  group('field access', () {
    test('uses the JSON keys', () {
      expect(
        BadgeProperties().fields.keys,
        containsAll(['labelStyle', 'dotSize', 'textColor', 'maxCount']),
      );
      expect(
        SegmentedButtonProperties().fields.keys,
        containsAll(['selectedSegments', 'selectedColor', 'unselectedColor']),
      );
      expect(
        ChipProperties().fields.keys,
        containsAll(['chipType', 'showCheckmark', 'tooltip']),
      );
    });

    test('sets values', () {
      final badge = BadgeProperties();
      badge.fields['dotSize']!.setValue(10.0);
      badge.fields['badgeType']!.setValue(BadgeType.dot);
      expect(badge.smallSize, 10);
      expect(badge.badgeType, BadgeType.dot);

      final chip = ChipProperties();
      chip.fields['selected']!.setValue(true);
      chip.fields['avatar']!.setValue('');
      expect(chip.selected, isTrue);
      expect(chip.avatar, isNull);

      final segmented = SegmentedButtonProperties();
      segmented.fields['selectedSegments']!.setValue(['option2']);
      expect(segmented.selected, ['option2']);
    });
  });

  group('badge count', () {
    test('caps numeric counts at maxCount', () {
      final properties = BadgeProperties(maxCount: 99);
      expect(properties.effectiveLabel('5'), '5');
      expect(properties.effectiveLabel('99'), '99');
      expect(properties.effectiveLabel('100'), '99+');
      expect(properties.effectiveLabel('new'), 'new');
    });

    test('leaves label badges alone', () {
      final properties = BadgeProperties(
        badgeType: BadgeType.label,
        maxCount: 9,
      );
      expect(properties.effectiveLabel('100'), '100');
    });
  });

  test('chip exposes selected only for selectable types', () {
    for (final type in ChipType.values) {
      final node = ChipNode.fromProperties(ChipProperties(chipType: type));
      expect(
        node.propertyVariables.any((v) => v.name == 'selected'),
        type.supportsSelection,
      );
    }
  });
}
