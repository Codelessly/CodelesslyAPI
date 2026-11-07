// Scripts: JavaScript a layout runs for what formulas and actions can't say
// cleanly (validation across fields, multi-step calculations, data
// shaping, small state machines). Stored in the layout document next to
// its variables (`scripts`); a run script action runs one, and the SDK's
// script runner (an app service) executes it in a sandbox. Pure data.
import 'package:meta/meta.dart';

import 'document.dart';
import 'json.dart';

/// What a script may do besides computing; anything else it calls fails.
/// JSON: the capability's [id].
enum ScriptCapability {
  /// `vars.get(name)`, `vars.has(name)`, `vars.all()`.
  variablesRead('variables.read'),

  /// `vars.set(name, value)`.
  variablesWrite('variables.write'),

  /// `nodes.value(id)`: the values of inputs on screen.
  nodesRead('nodes.read'),

  /// `app.navigate(page, params)`, `app.back(result)`.
  navigation('navigation'),

  /// `app.callApi(name, inputs)`.
  api('api'),

  /// `app.cloudData(request)`.
  cloud('cloud'),

  /// `app.runAction(action)`, `app.toast(text)`, `app.delay(ms)`.
  actions('actions'),

  /// `Date.now()`, `new Date()`. Without it a script's result depends
  /// only on its inputs.
  clock('clock');

  const ScriptCapability(this.id);

  /// The name scripts and the runner use (`variables.read`).
  final String id;

  /// The capability named [v] (its [id] or its name); null for one this
  /// version doesn't know.
  static ScriptCapability? parse(Object? v) {
    for (final c in values) {
      if (c.id == v || c.name == v) return c;
    }
    return null;
  }
}

/// A parameter of a [ScriptDef]: a JavaScript identifier, and the value a
/// caller that passes none gets ([defaultValue], JSON).
@immutable
final class ScriptParam {
  const ScriptParam({required this.name, this.description = '', this.defaultValue});

  final String name;
  final String description;
  final Object? defaultValue;

  static ScriptParam? fromJson(Object? json) {
    final m = readMap(json);
    final name = readString(m?['name']);
    if (m == null || name == null || name.isEmpty) return null;
    return ScriptParam(name: name, description: readString(m['description']) ?? '', defaultValue: m['defaultValue']);
  }

  Json toJson() => {
        'name': name,
        if (description.isNotEmpty) 'description': description,
        'defaultValue': ?defaultValue,
      };

  @override
  bool operator ==(Object other) => other is ScriptParam && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// A sample run of a [ScriptDef] and what it should give (the editor's test
/// console): [args] by parameter, sample [vars] and input [nodes] values,
/// and the result [expect]ed, or the error type [expectError].
@immutable
final class ScriptTest {
  const ScriptTest({
    this.name = '',
    this.args = const {},
    this.vars = const {},
    this.nodes = const {},
    this.expect,
    this.expectError,
  });

  final String name;
  final Json args, vars, nodes;
  final Object? expect;
  final String? expectError;

  static ScriptTest? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return ScriptTest(
      name: readString(m['name']) ?? '',
      args: readMap(m['args']) ?? const {},
      vars: readMap(m['vars']) ?? const {},
      nodes: readMap(m['nodes']) ?? const {},
      expect: m['expect'],
      expectError: readString(m['expectError']),
    );
  }

  Json toJson() => {
        if (name.isNotEmpty) 'name': name,
        if (args.isNotEmpty) 'args': args,
        if (vars.isNotEmpty) 'vars': vars,
        if (nodes.isNotEmpty) 'nodes': nodes,
        'expect': ?expect,
        'expectError': ?expectError,
      };

  @override
  bool operator ==(Object other) => other is ScriptTest && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// A script. Its [params] are variables in its [source]; what it returns at
/// its top level (or what its `main` returns) is its result. It runs in a
/// sandbox with no network, files or timers, reaching the app only through
/// what its [capabilities] grant, and stops past [timeoutMs] of computing
/// or [memoryLimitMb]. A page script ([pageId] set) wins over a project
/// script of the same [name]. JSON (sparse):
///
/// ```json
/// {"id": "s1", "name": "payment", "params": [{"name": "principal"}],
///  "source": "return principal * 0.05;", "capabilities": ["variables.read"]}
/// ```
@immutable
final class ScriptDef {
  const ScriptDef({
    required this.id,
    required this.name,
    this.description = '',
    this.params = const [],
    this.source = '',
    this.version = 1,
    this.capabilities = const [],
    this.timeoutMs = defaultTimeoutMs,
    this.memoryLimitMb = defaultMemoryLimitMb,
    this.pageId,
    this.tests = const [],
  });

  static const int defaultTimeoutMs = 1000;
  static const int defaultMemoryLimitMb = 32;

  /// The longest [timeoutMs] a script may set.
  static const int maxTimeoutMs = 30000;

  final String id;

  /// A JavaScript identifier, unique in its scope: formulas and other
  /// scripts call it as `script.<name>(...)`.
  final String name;
  final String description;
  final List<ScriptParam> params;
  final String source;

  /// Goes up each time the script is saved.
  final int version;

  /// Capabilities this version doesn't know are dropped when read.
  final List<ScriptCapability> capabilities;
  final int timeoutMs;

  /// Enforced on devices; on the web only [timeoutMs] applies.
  final int memoryLimitMb;

  /// The editor page whose screens use it; null: every screen of the project.
  final String? pageId;
  final List<ScriptTest> tests;

  /// Names a script or parameter can't have: they're the host APIs.
  static const Set<String> reservedNames = {'vars', 'nodes', 'app', 'console', 'fmt', 'script', 'params', 'main'};

  static const Set<String> _jsReserved = {
    'break', 'case', 'catch', 'class', 'const', 'continue', 'debugger', //
    'default', 'delete', 'do', 'else', 'export', 'extends', 'finally', 'for',
    'function', 'if', 'import', 'in', 'instanceof', 'new', 'return', 'super',
    'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void', 'while',
    'with', 'yield', 'let', 'static', 'enum', 'await', 'implements',
    'package', 'protected', 'interface', 'private', 'public', 'null', 'true',
    'false', 'undefined', 'NaN', 'Infinity', 'arguments', 'eval',
  };

  /// Whether [name] can name a script or a parameter: a JavaScript
  /// identifier, not a keyword or one of [reservedNames].
  static bool isValidName(String name) =>
      RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$').hasMatch(name) && !reservedNames.contains(name) && !_jsReserved.contains(name);

  /// What's wrong with this script's name, params or limits; empty when
  /// nothing is. Doesn't check the source (the engine does).
  List<String> validate() => [
        if (!isValidName(name)) 'Name "$name" must be a JavaScript identifier and not one of ${reservedNames.join(', ')}.',
        for (final p in params)
          if (!isValidName(p.name))
            'Parameter "${p.name}" must be a JavaScript identifier and not one of ${reservedNames.join(', ')}.',
        if (params.map((p) => p.name).toSet().length != params.length) 'Parameter names must be unique.',
        if (timeoutMs < 1 || timeoutMs > maxTimeoutMs) 'timeoutMs must be from 1 to $maxTimeoutMs.',
        if (memoryLimitMb < 1 || memoryLimitMb > 256) 'memoryLimitMb must be from 1 to 256.',
      ];

  /// A copy with the given fields replaced.
  ScriptDef copyWith({
    String? id,
    String? name,
    String? description,
    List<ScriptParam>? params,
    String? source,
    int? version,
    List<ScriptCapability>? capabilities,
    int? timeoutMs,
    int? memoryLimitMb,
    String? pageId,
    bool clearPageId = false,
    List<ScriptTest>? tests,
  }) =>
      ScriptDef(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        params: params ?? this.params,
        source: source ?? this.source,
        version: version ?? this.version,
        capabilities: capabilities ?? this.capabilities,
        timeoutMs: timeoutMs ?? this.timeoutMs,
        memoryLimitMb: memoryLimitMb ?? this.memoryLimitMb,
        pageId: clearPageId ? null : pageId ?? this.pageId,
        tests: tests ?? this.tests,
      );

  bool get isProjectScope => pageId == null;

  List<String> get paramNames => [for (final p in params) p.name];

  bool allows(ScriptCapability c) => capabilities.contains(c);

  static ScriptDef? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    final name = readString(m?['name']);
    if (m == null || id == null || name == null) return null;
    final page = readString(m['pageId']);
    return ScriptDef(
      id: id,
      name: name,
      description: readString(m['description']) ?? '',
      params: [...?readList(m['params'])?.map(ScriptParam.fromJson).nonNulls],
      source: readString(m['source']) ?? '',
      version: readInt(m['version']) ?? 1,
      capabilities: [...?readList(m['capabilities'])?.map(ScriptCapability.parse).nonNulls],
      timeoutMs: (readInt(m['timeoutMs']) ?? defaultTimeoutMs).clamp(1, maxTimeoutMs),
      memoryLimitMb: (readInt(m['memoryLimitMb']) ?? defaultMemoryLimitMb).clamp(1, 256),
      pageId: page == null || page.isEmpty ? null : page,
      tests: [...?readList(m['tests'])?.map(ScriptTest.fromJson).nonNulls],
    );
  }

  static List<ScriptDef> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  Json toJson() => {
        'id': id,
        'name': name,
        if (description.isNotEmpty) 'description': description,
        if (params.isNotEmpty) 'params': [for (final p in params) p.toJson()],
        if (source.isNotEmpty) 'source': source,
        if (version != 1) 'version': version,
        if (capabilities.isNotEmpty) 'capabilities': [for (final c in capabilities) c.id],
        if (timeoutMs != defaultTimeoutMs) 'timeoutMs': timeoutMs,
        if (memoryLimitMb != defaultMemoryLimitMb) 'memoryLimitMb': memoryLimitMb,
        'pageId': ?pageId,
        if (tests.isNotEmpty) 'tests': [for (final t in tests) t.toJson()],
      };

  @override
  bool operator ==(Object other) => other is ScriptDef && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => 'ScriptDef($name)';
}

/// The scripts of a layout document (its `scripts` key, in
/// [LayoutDocument.extra]): project scripts and its page's.
extension LayoutDocumentScripts on LayoutDocument {
  /// The document key they're stored under.
  static const String key = 'scripts';

  List<ScriptDef> get scripts => ScriptDef.listFromJson(extra[key]);

  /// The script [idOrName] names: by id, else by name, a page script over a
  /// project one.
  ScriptDef? script(String idOrName) => findScript(scripts, idOrName);
}

/// The script of [scripts] that [idOrName] names: by id, else by name, a
/// page script over a project one.
ScriptDef? findScript(Iterable<ScriptDef> scripts, String idOrName) {
  ScriptDef? byName;
  for (final s in scripts) {
    if (s.id == idOrName) return s;
    if (s.name == idOrName && (byName == null || (byName.isProjectScope && !s.isProjectScope))) byName = s;
  }
  return byName;
}
