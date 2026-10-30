import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'code_theme.g.dart';

/// The programming language a [TextNode] shows as code, highlighted with
/// the colors of its [CodeThemeModel].
enum SyntaxLanguage {
  /// Plain text: no highlighting.
  none,

  /// Bash commands: `$` prompts, flags (`--header`), variables, strings and
  /// `#` comments.
  bash,

  /// Same as [bash].
  shell,

  /// JavaScript, template strings included.
  javascript,

  /// TypeScript: JavaScript with types.
  typescript,

  /// Python, triple-quoted strings and decorators included.
  python,

  /// Go, raw (backtick) strings included.
  go,

  /// Ruby, symbols and instance variables included.
  ruby,

  /// JSON: keys, strings, numbers and literals.
  json;

  /// Other names a language is often written as (e.g. a code fence's
  /// `sh`, `js` or `py`), read as the language they name.
  static const Map<String, SyntaxLanguage> aliases = {
    'sh': SyntaxLanguage.bash,
    'zsh': SyntaxLanguage.bash,
    'console': SyntaxLanguage.bash,
    'terminal': SyntaxLanguage.bash,
    'curl': SyntaxLanguage.bash,
    'js': SyntaxLanguage.javascript,
    'jsx': SyntaxLanguage.javascript,
    'node': SyntaxLanguage.javascript,
    'nodejs': SyntaxLanguage.javascript,
    'ts': SyntaxLanguage.typescript,
    'tsx': SyntaxLanguage.typescript,
    'py': SyntaxLanguage.python,
    'python3': SyntaxLanguage.python,
    'golang': SyntaxLanguage.go,
    'rb': SyntaxLanguage.ruby,
    'text': SyntaxLanguage.none,
    'plain': SyntaxLanguage.none,
    'plaintext': SyntaxLanguage.none,
    '': SyntaxLanguage.none,
  };

  /// The language [name] names, in any case, or an alias of one (see
  /// [aliases]). Null when it names none.
  static SyntaxLanguage? tryParse(String? name) {
    if (name == null) return null;
    final String key = name.trim().toLowerCase();
    for (final SyntaxLanguage language in values) {
      if (language.name == key) return language;
    }
    return aliases[key];
  }

  /// Displayable name.
  String get prettify => switch (this) {
    SyntaxLanguage.none => 'None',
    SyntaxLanguage.bash => 'Bash',
    SyntaxLanguage.shell => 'Shell',
    SyntaxLanguage.javascript => 'JavaScript',
    SyntaxLanguage.typescript => 'TypeScript',
    SyntaxLanguage.python => 'Python',
    SyntaxLanguage.go => 'Go',
    SyntaxLanguage.ruby => 'Ruby',
    SyntaxLanguage.json => 'JSON',
  };
}

/// The colors a [TextNode] showing code ([TextNode.codeLanguage]) gives each
/// kind of token. A color left null takes the default theme's (see
/// [defaults], made for a dark background). Text that is none of these
/// keeps the text's own color.
@JsonSerializable()
class CodeThemeModel with Equatable, SerializableMixin {
  /// Keywords: `const`, `def`, `func`, `if`, `return`, `true`, `null`...
  final ColorRGBA? keyword;

  /// Strings, template and triple-quoted ones included, and Ruby symbols.
  final ColorRGBA? string;

  /// Comments: `// ...`, `/* ... */` and `# ...`.
  final ColorRGBA? comment;

  /// Numbers.
  final ColorRGBA? number;

  /// Names of called functions (`fetch(`), and the command of a shell line.
  final ColorRGBA? function;

  /// Punctuation and operators, and a shell line's `$` prompt.
  final ColorRGBA? punctuation;

  /// Types, classes and built-ins: `string`, `Promise`, `print`, `self`...
  final ColorRGBA? type;

  /// Properties and keys: `.headers`, JSON keys, object keys, shell flags
  /// (`--data`) and variables (`$TOKEN`).
  final ColorRGBA? property;

  /// Creates a [CodeThemeModel].
  const CodeThemeModel({
    this.keyword,
    this.string,
    this.comment,
    this.number,
    this.function,
    this.punctuation,
    this.type,
    this.property,
  });

  /// The default theme, for code on a dark background.
  static final CodeThemeModel defaults = CodeThemeModel(
    keyword: ColorRGBA.fromHex('#FF7B72'),
    string: ColorRGBA.fromHex('#A5D6FF'),
    comment: ColorRGBA.fromHex('#8B949E'),
    number: ColorRGBA.fromHex('#79C0FF'),
    function: ColorRGBA.fromHex('#D2A8FF'),
    punctuation: ColorRGBA.fromHex('#C9D1D9'),
    type: ColorRGBA.fromHex('#FFA657'),
    property: ColorRGBA.fromHex('#7EE787'),
  );

  /// This theme with the colors it leaves null taken from [defaults].
  CodeThemeModel get resolved => CodeThemeModel(
    keyword: keyword ?? defaults.keyword,
    string: string ?? defaults.string,
    comment: comment ?? defaults.comment,
    number: number ?? defaults.number,
    function: function ?? defaults.function,
    punctuation: punctuation ?? defaults.punctuation,
    type: type ?? defaults.type,
    property: property ?? defaults.property,
  );

  /// The names of the token kinds, as JSON keys.
  static const List<String> tokens = [
    'keyword',
    'string',
    'comment',
    'number',
    'function',
    'punctuation',
    'type',
    'property',
  ];

  /// The color of the token kind [token] (one of [tokens]).
  ColorRGBA? colorOf(String token) => switch (token) {
    'keyword' => keyword,
    'string' => string,
    'comment' => comment,
    'number' => number,
    'function' => function,
    'punctuation' => punctuation,
    'type' => type,
    'property' => property,
    _ => throw ArgumentError.value(token, 'token'),
  };

  /// Returns a copy with the color of [token] set to [color], or back to the
  /// default when [color] is null.
  CodeThemeModel withColor(String token, ColorRGBA? color) => CodeThemeModel(
    keyword: token == 'keyword' ? color : keyword,
    string: token == 'string' ? color : string,
    comment: token == 'comment' ? color : comment,
    number: token == 'number' ? color : number,
    function: token == 'function' ? color : function,
    punctuation: token == 'punctuation' ? color : punctuation,
    type: token == 'type' ? color : type,
    property: token == 'property' ? color : property,
  );

  @override
  List<Object?> get props => [
    keyword,
    string,
    comment,
    number,
    function,
    punctuation,
    type,
    property,
  ];

  /// Creates a [CodeThemeModel] from JSON.
  factory CodeThemeModel.fromJson(Map json) => _$CodeThemeModelFromJson(json);

  @override
  Map toJson() =>
      _$CodeThemeModelOmitDefaults(this, _$CodeThemeModelToJson(this));
}
