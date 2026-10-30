import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> textJson(Object? markdown) => {
    'type': 'text',
    'id': 't',
    'name': 'Body',
    'basicBoxLocal': [0, 0, 200, 20],
    'data': '**hi** @maya',
    'textMixedProps': [
      {'start': 0, 'end': 12, 'fontSize': 13},
    ],
    'markdown': ?markdown,
  };

  test('a text is plain unless it has a markdown style', () {
    expect(TextNode.fromJson(textJson(null)).markdown, isNull);
    expect(TextNode.fromJson(textJson(null)).toJson().containsKey('markdown'), isFalse);
  });

  test('markdown styles read hex colors and round-trip', () {
    final TextNode node = TextNode.fromJson(
      textJson({
        'codeColor': '#E4B5F2',
        'mentionBackground': '#1F7C6CF2',
        'mentions': ['maya', 'sam'],
      }),
    );
    final MarkdownStyle style = node.markdown!;
    expect(style.codeColor, ColorRGBA.fromHex('#E4B5F2'));
    expect(style.mentionBackground!.a, closeTo(0x1F / 255, 0.01));
    expect(style.mentions, ['maya', 'sam']);
    expect(style.codeFontFamily, 'JetBrains Mono');
    final Map json = node.toJson();
    expect((json['markdown'] as Map).containsKey('paragraphGap'), isFalse);
    expect(TextNode.fromJson(json).markdown, style);
  });

  test('an empty style turns markdown on with the defaults', () {
    final TextNode node = TextNode.fromJson(textJson(<String, dynamic>{}));
    expect(node.markdown, const MarkdownStyle());
    expect(node.toJson()['markdown'], <String, dynamic>{});
  });
}
