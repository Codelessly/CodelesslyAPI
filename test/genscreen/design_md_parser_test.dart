import 'dart:io';

import 'package:codelessly_api/genscreen.dart';
import 'package:test/test.dart';

String fixture(String name) =>
    File('test/genscreen/fixtures/$name.design.md').readAsStringSync();

void main() {
  const DesignMdParser parser = DesignMdParser();

  for (final String name in ['aurora', 'kiosk', 'verdant']) {
    test('$name kit parses without errors and round-trips', () {
      final DesignMdParseResult result = parser.parse(fixture(name));
      expect(
        result.issues.where((i) => i.severity == DesignMdSeverity.error),
        isEmpty,
      );
      final DesignKit kit = result.kit;
      expect(kit.colors.keys, containsAll(requiredColorTokens));
      expect(kit.typography.keys, containsAll(requiredTextStyles));
      expect(
        kit.components.keys,
        containsAll(['button', 'card', 'listRow', 'input', 'appBar', 'navBar']),
      );
      expect(kit.breakpoints.map((b) => b.name), [
        'mobile',
        'tablet',
        'desktop',
      ]);
      final String written = const DesignMdWriter().write(kit);
      final DesignKit again = parser.parse(written).kit;
      expect(again, kit);
      expect(const DesignMdWriter().write(again), written);
    });
  }

  test('reads aurora tokens', () {
    final DesignKit kit = parser.parse(fixture('aurora')).kit;
    expect(kit.name, 'Aurora');
    expect(kit.version, '1.0.0');
    expect(kit.color('primary'), const KitColor(0x4F, 0x46, 0xE5));
    expect(kit.colors['primary']!.dark, const KitColor(0x81, 0x8C, 0xF8));
    expect(kit.typography['title']!.family, 'Manrope');
    expect(kit.typography['title']!.weight, 700);
    expect(kit.typography['caption']!.letterSpacing, 0.2);
    expect(kit.spacing['md'], 16);
    expect(kit.radius['pill'], 999);
    expect(kit.elevation['low'], hasLength(2));
    expect(kit.elevation['low']!.first.color.opacity, closeTo(0.06, 0.001));
    expect(kit.elevation['flat'], isEmpty);
    expect(kit.components['button']!['height'], '48');
    expect(kit.components['button']!.row('primary')!['fill'], 'primary');
    expect(kit.components['listRow']!['minHeight'], '56');
    expect(kit.layout['sectionGap'], 'lg');
    expect(kit.motion['standard']!.durationMs, 220);
    expect(kit.icons['size'], '24');
    expect(kit.accessibility['minTouchTarget'], '48');
    expect(kit.brand.dos, hasLength(3));
    expect(kit.brand.donts, hasLength(2));
    expect(kit.brand['voice'], startsWith('plain and direct'));
    expect(kit.brand.notes, startsWith('Aurora is for money'));
  });

  test('kiosk reads uppercase type and hard shadows', () {
    final DesignKit kit = parser.parse(fixture('kiosk')).kit;
    expect(kit.typography['label']!.uppercase, isTrue);
    expect(kit.typography['body']!.uppercase, isFalse);
    final KitShadow s = kit.elevation['low']!.single;
    expect([s.x, s.y, s.blur, s.spread], [3, 3, 0, 0]);
  });

  test('reports missing tokens, bad colors and low contrast with lines', () {
    final DesignMdParseResult result = parser.parse('''
---
name: Broken
---
## Colors
| Token | Light |
|---|---|
| primary | #FFEE00 |
| onPrimary | #FFFFFF |
| surface | blue |

## Typography
| Token | Family | Size |
|---|---|---|
| body | Inter | 15 |

## Spacing
| Token | Value |
|---|---|
| md | 16 |

## Mood board
Anything goes.
''');
    final List<String> messages = result.issues
        .map((i) => i.toString())
        .toList();
    expect(result.isValid, isFalse);
    expect(messages, contains(contains('surface" has no readable value')));
    expect(
      messages.firstWhere((m) => m.contains('surface" has no')),
      contains('line 9'),
    );
    expect(
      messages,
      contains(contains('Missing required color token "background"')),
    );
    expect(messages, contains(contains('Missing required text style "title"')));
    expect(messages, contains(contains('onPrimary on primary has contrast')));
    expect(
      messages,
      contains(contains('Section "Mood board" is not part of the format')),
    );
    expect(result.kit.extra['Mood board'], 'Anything goes.');
  });

  test('colors parse every documented form', () {
    expect(KitColor.tryParse('#abc'), const KitColor(0xAA, 0xBB, 0xCC));
    expect(KitColor.tryParse('#112233/50')!.opacity, 0.5);
    expect(
      KitColor.tryParse('rgba(10, 20, 30, 0.25)'),
      const KitColor(10, 20, 30, 0.25),
    );
    expect(KitColor.tryParse('#112233/50')!.nodeHex, '#80112233');
    expect(KitColor.tryParse('red'), isNull);
    expect(
      const KitColor(0, 0, 0).contrastWith(const KitColor(255, 255, 255)),
      closeTo(21, 0.01),
    );
  });

  test('fingerprint changes with any token', () {
    final DesignKit kit = parser.parse(fixture('aurora')).kit;
    final DesignKit edited = parser
        .parse(fixture('aurora').replaceFirst('| md | 16 |', '| md | 18 |'))
        .kit;
    expect(kit.fingerprint, startsWith('1.0.0+'));
    expect(edited.fingerprint, isNot(kit.fingerprint));
    expect(parser.parse(fixture('aurora')).kit.fingerprint, kit.fingerprint);
  });
}
