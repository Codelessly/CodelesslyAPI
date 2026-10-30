import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('EditTextAction', () {
    test('round-trips through JSON', () {
      final EditTextAction action = EditTextAction(
        nodeId: 'composer',
        operation: EditTextOperation.wrap,
        before: '[',
        after: '](https://)',
      );
      final Map json = action.toJson();
      expect(json, {
        'type': 'editText',
        'nodeId': 'composer',
        'operation': 'wrap',
        'before': '[',
        'after': '](https://)',
      });
      final ActionModel read = ActionModel.fromJson(json);
      expect(read, isA<EditTextAction>());
      expect(read, action);
      expect(read.type, ActionType.editText);
    });

    test('reads each operation and its inputs', () {
      final EditTextAction list = ActionModel.fromJson({
        'type': 'editText',
        'nodeId': 'f',
        'operation': 'toggleList',
        'numbered': true,
      }) as EditTextAction;
      expect(list.operation, EditTextOperation.toggleList);
      expect(list.numbered, isTrue);
      final EditTextAction replace = ActionModel.fromJson({
        'type': 'editText',
        'nodeId': 'f',
        'operation': 'replaceWord',
        'text': r'@${item.handle} ',
      }) as EditTextAction;
      expect(replace.text, r'@${item.handle} ');
      expect(replace.after, isNull);
      for (final EditTextOperation op in EditTextOperation.values) {
        final ActionModel read = ActionModel.fromJson({
          'type': 'editText',
          'operation': op.name,
        });
        expect((read as EditTextAction).operation, op);
        expect(op.prettify, isNotEmpty);
      }
    });

    test('copyWith clears after on request', () {
      final EditTextAction action = EditTextAction(before: '**', after: '!');
      expect(action.copyWith(text: 'x').after, '!');
      expect(action.copyWith(clearAfter: true).after, isNull);
    });
  });

  group('text field', () {
    Map<String, dynamic> fieldJson(Map<String, dynamic> properties) => {
      'type': 'textField',
      'id': 'f',
      'name': 'Composer',
      'basicBoxLocal': [0, 0, 300, 80],
      'properties': properties,
    };

    test('takes key down reactions', () {
      final TextFieldNode node = TextFieldNode.fromJson(fieldJson({}));
      expect(node.triggerTypes, contains(TriggerType.keyDown));
    });

    test('is plain unless it has a markdown style', () {
      final TextFieldNode plain = TextFieldNode.fromJson(fieldJson({}));
      expect(plain.properties.markdown, isNull);
      expect(
        (plain.toJson()['properties'] as Map).containsKey('markdown'),
        isFalse,
      );
      final TextFieldNode rich = TextFieldNode.fromJson(
        fieldJson({
          'markdown': {'showMarkers': true, 'bulletColor': '#7C6CF2'},
        }),
      );
      expect(rich.properties.markdown!.showMarkers, isTrue);
      final TextFieldNode again = TextFieldNode.fromJson(rich.toJson());
      expect(again.properties.markdown, rich.properties.markdown);
      expect(rich.properties.copyWith(clearMarkdown: true).markdown, isNull);
      expect(
        plain.properties.copyWith(markdown: const MarkdownStyle()).markdown,
        const MarkdownStyle(),
      );
    });
  });

  test('MarkdownStyle.copyWith replaces only what it is given', () {
    final MarkdownStyle style = MarkdownStyle(
      mentions: const ['maya'],
      bulletColor: ColorRGBA.fromHex('#7C6CF2'),
    );
    final MarkdownStyle live = style.copyWith(showMarkers: true);
    expect(live.showMarkers, isTrue);
    expect(live.mentions, ['maya']);
    expect(live.bulletColor, style.bulletColor);
    expect(live.copyWith(showMarkers: false), style);
  });

  group('TriggerModel', () {
    test('when round-trips', () {
      final TriggerModel trigger = TriggerModel.fromJson({
        'type': 'keyDown',
        'key': 'Enter',
        'when': r'${= acOpen}',
      });
      expect(trigger.when, r'${= acOpen}');
      expect(trigger.toJson(), {
        'type': 'keyDown',
        'key': 'Enter',
        'when': r'${= acOpen}',
      });
      expect(trigger.copyWith(key: 'Tab').when, r'${= acOpen}');
      expect(TriggerModel(type: TriggerType.keyDown).toJson(), {
        'type': 'keyDown',
      });
    });
  });

  group('KeyCombo', () {
    test('parses keys and modifiers', () {
      expect(
        KeyCombo.tryParse('Meta+Enter'),
        const KeyCombo('enter', meta: true),
      );
      expect(
        KeyCombo.tryParse('Ctrl+Enter'),
        const KeyCombo('enter', meta: true),
      );
      expect(KeyCombo.tryParse('cmd + b'), const KeyCombo('b', meta: true));
      expect(
        KeyCombo.tryParse('Shift+Enter'),
        const KeyCombo('enter', shift: true),
      );
      expect(
        KeyCombo.tryParse('Alt+Shift+Arrow Up'),
        const KeyCombo('arrowup', shift: true, alt: true),
      );
      expect(KeyCombo.tryParse('ArrowDown'), const KeyCombo('arrowdown'));
      expect(KeyCombo.tryParse('Esc'), const KeyCombo('escape'));
      expect(KeyCombo.tryParse('Tab'), const KeyCombo('tab'));
      expect(KeyCombo.tryParse('+'), const KeyCombo('+'));
      expect(KeyCombo.tryParse('Meta++'), const KeyCombo('+', meta: true));
      expect(KeyCombo.tryParse(''), isNull);
      expect(KeyCombo.tryParse(null), isNull);
      expect(KeyCombo.tryParse('Hyper+x'), isNull);
      expect(
        TriggerModel(type: TriggerType.keyDown, key: 'Meta+b').keyCombo,
        const KeyCombo('b', meta: true),
      );
    });

    test('matches exactly the named modifiers', () {
      final KeyCombo send = KeyCombo.tryParse('Meta+Enter')!;
      expect(send.matches('Enter', meta: true), isTrue);
      expect(send.matches('Enter'), isFalse);
      expect(send.matches('Enter', meta: true, shift: true), isFalse);

      final KeyCombo enter = KeyCombo.tryParse('Enter')!;
      expect(enter.matches('Enter'), isTrue);
      expect(enter.matches('Enter', shift: true), isFalse);
      expect(enter.matches('Enter', meta: true), isFalse);

      final KeyCombo newline = KeyCombo.tryParse('Shift+Enter')!;
      expect(newline.matches('Enter', shift: true), isTrue);
      expect(newline.matches('Enter'), isFalse);

      final KeyCombo down = KeyCombo.tryParse('ArrowDown')!;
      expect(down.matches('Arrow Down'), isTrue);
      expect(down.matches('ArrowDown'), isTrue);
      expect(down.matches('ArrowUp'), isFalse);

      // A character typed with Shift still matches.
      expect(KeyCombo.tryParse('?')!.matches('?', shift: true), isTrue);
      expect(KeyCombo.tryParse('Meta+b')!.matches('B', meta: true), isTrue);
    });
  });
}
