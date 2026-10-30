import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Object? resolve(Map json, String path) {
  Object? value = json;
  for (final part in path.split('.')) {
    if (value is! Map || !value.containsKey(part)) return null;
    value = value[part];
  }
  return value;
}

void main() {
  final descriptors =
      (jsonDecode(
            File('lib/src/schema/generated/dpp_descriptors.json')
                .readAsStringSync(),
          ) as Map)['descriptors']
          as List;
  final addedPaths = <String, Set<String>>{
    for (final type in const [
      'elevatedButton',
      'filledButton',
      'outlinedButton',
      'textButton',
      'iconButton',
    ])
      type: {
        'properties.buttonColor',
        'properties.shadowColor',
        'properties.elevation',
        'properties.shape',
        'properties.cornerRadius',
        'properties.borderWidth',
        'properties.borderColor',
        'properties.labelAlignment',
        'properties.labelStyle',
        'properties.placement',
        'properties.gap',
        for (final field in const [
          'fills',
          'fontName',
          'fontSize',
          'letterSpacing',
          'lineHeight',
          'link',
          'textDecoration',
        ])
          'properties.labelStyle.$field',
      },
    'floatingActionButton': {
      'properties.cornerRadius',
      'properties.borderWidth',
      'properties.borderColor',
    },
    'listTile': {
      'properties.cornerRadius',
      'properties.borderWidth',
      'properties.borderColor',
    },
    'badge': {
      'properties.badgeType',
      'properties.maxCount',
      'properties.offsetX',
      'properties.offsetY',
    },
  };

  test('each new properties path has one exact editor-only descriptor', () {
    expect(
      addedPaths.values.fold<int>(0, (sum, paths) => sum + paths.length),
      100,
    );
    for (final entry in addedPaths.entries) {
      for (final path in entry.value) {
        final matches = descriptors.cast<Map>().where(
          (descriptor) =>
              descriptor['nodeType'] == entry.key &&
              descriptor['fieldPath'] == path,
        );
        expect(matches, hasLength(1), reason: '${entry.key}.$path');
        expect(matches.single['flutterName'], isNull, reason: path);
      }
    }
  });

  test('new button style descriptors resolve on real nondefault wire JSON', () {
    for (final node in <ButtonNode>[
      ElevatedButtonNode.empty(),
      FilledButtonNode.empty(),
      OutlinedButtonNode.empty(),
      TextButtonNode.empty(),
      IconButtonNode.empty(),
    ]) {
      node.properties.buttonColor = ColorRGBA.red;
      node.properties.shadowColor = ColorRGBA.black;
      node.properties.elevation = 3;
      node.properties.shape = CShapeBorder.circle;
      node.properties.cornerRadius = const CornerRadius.all(
        RadiusModel.circular(8),
      );
      node.properties.borderWidth = 2;
      node.properties.borderColor = ColorRGBA.red;
      node.properties.labelAlignment = TextAlignHorizontalEnum.right;
      node.properties.labelStyle = TextProp.general(
        fontSize: 19,
        fontName: FontName.poppinsRegular,
        letterSpacing: const LetterSpacing.pixels(2),
        lineHeight: const LineHeight.pixels(23),
        textDecoration: TextDecorationEnum.underline,
        link: 'https://example.com',
      );
      node.properties.placement = IconPlacementEnum.end;
      node.properties.gap = 11;
      final json = node.toJson();
      expect(ButtonNode.fromJson(json).toJson(), json, reason: node.type);
      for (final path in addedPaths[node.type]!) {
        expect(resolve(json, path), isNotNull, reason: '${node.type}.$path');
      }
      expect(resolve(json, 'properties.backgroundColor'), isNull);
      expect(resolve(json, 'properties.labelStyle.props.fontSize'), isNull);
      expect(resolve(json, 'properties.buttonType'), isNull);
    }
  });

  test(
    'badge and shared border descriptors resolve on serialized properties',
    () {
      final badge = BadgeNode.empty();
      badge.properties.badgeType = BadgeType.label;
      badge.properties.maxCount = 27;
      badge.properties.offsetX = 9;
      badge.properties.offsetY = -7;
      final json = badge.toJson();
      for (final path in addedPaths['badge']!) {
        expect(resolve(json, path), isNotNull, reason: path);
      }
      final dotSize = descriptors.cast<Map>().singleWhere(
        (descriptor) =>
            descriptor['nodeType'] == 'badge' &&
            descriptor['fieldPath'] == 'properties.dotSize',
      );
      expect(dotSize['flutterName'], 'smallSize');
      expect(
        descriptors.cast<Map>().where(
          (descriptor) =>
              descriptor['nodeType'] == 'badge' &&
              descriptor['fieldPath'] == 'properties.smallSize',
        ),
        isEmpty,
      );
      badge.properties.smallSize = 12;
      expect(resolve(badge.toJson(), 'properties.dotSize'), 12);
      expect(resolve(badge.toJson(), 'properties.smallSize'), isNull);
    },
  );
}
