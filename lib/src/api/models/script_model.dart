import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'script_model.g.dart';

/// What a script may do besides computing. A script gets only the
/// capabilities granted to it; calling anything else fails with a
/// `CapabilityError`.
@JsonEnum(valueField: 'id')
enum ScriptCapability {
  /// Read variables: `vars.get(name)`, `vars.has(name)`, `vars.all()`.
  variablesRead('variables.read', 'Read variables'),

  /// Change variables: `vars.set(name, value)`.
  variablesWrite('variables.write', 'Change variables'),

  /// Read the values of inputs on screen: `nodes.value(id)`.
  nodesRead('nodes.read', 'Read input values'),

  /// Navigate: `app.navigate(page, params)` and `app.back(result)`.
  navigation('navigation', 'Navigate'),

  /// Call the project's APIs: `app.callApi(name, inputs)`.
  api('api', 'Call APIs'),

  /// Read and write cloud data: `app.cloudData(request)`.
  cloud('cloud', 'Cloud data'),

  /// Run actions: `app.runAction(action)`, `app.toast(text)`,
  /// `app.delay(ms)`.
  actions('actions', 'Run actions'),

  /// Read the current time: `Date.now()` and `new Date()`. Without it, a
  /// script's result depends only on its inputs.
  clock('clock', 'Read the clock');

  /// The name scripts and the driver use, e.g. `variables.read`.
  final String id;

  /// A short label for the Editor.
  final String label;

  const ScriptCapability(this.id, this.label);

  /// The capability named [id], or null.
  static ScriptCapability? fromId(String id) {
    for (final ScriptCapability c in values) {
      if (c.id == id || c.name == id) return c;
    }
    return null;
  }
}

List<ScriptCapability> _capabilitiesFromJson(Object? json) => [
      if (json is List)
        for (final Object? id in json)
          if (id is String && ScriptCapability.fromId(id) != null) ScriptCapability.fromId(id)!,
    ];

/// A parameter of a [ScriptModel].
@JsonSerializable()
class ScriptParam with Equatable, SerializableMixin {
  /// The parameter's name: a JavaScript identifier, e.g. `principal`.
  final String name;

  /// What the parameter is for, shown in the Editor and to agents.
  final String description;

  /// The value used when a caller doesn't pass one, as JSON.
  final Object? defaultValue;

  /// Creates a [ScriptParam].
  const ScriptParam({
    required this.name,
    this.description = '',
    this.defaultValue,
  });

  /// Creates a [ScriptParam] from JSON.
  factory ScriptParam.fromJson(Map json) => _$ScriptParamFromJson(json);

  @override
  Map toJson() => _$ScriptParamOmitDefaults(this, _$ScriptParamToJson(this));

  @override
  List<Object?> get props => [name, description, defaultValue];
}

/// A script: JavaScript that computes what formulas and actions can't
/// express cleanly, such as validation across fields, multi-step
/// calculations, data shaping, small state machines and reducers.
///
/// A script runs in a sandbox: an isolated JavaScript engine (QuickJS on
/// devices, a Web Worker on the web) with no network, files or timers. It
/// reaches the app only through the host APIs its [capabilities] grant, and
/// stops when it exceeds [timeoutMs] or [memoryLimitMb].
///
/// The script's [params] are variables in its [source]; what it returns at
/// its top level (or what its `main` function returns) is its result.
/// Actions run it with a "Run script" action ([RunScriptAction]), whose
/// result is `${result}`; formulas call it as `script.name(args)`.
@JsonSerializable()
class ScriptModel with Equatable, SerializableMixin {
  /// The script's id.
  final String id;

  /// The script's name: a JavaScript identifier, unique in the project.
  /// Formulas and other scripts call it as `script.<name>(...)`.
  final String name;

  /// What the script does.
  final String description;

  /// The parameters, in order.
  final List<ScriptParam> params;

  /// The JavaScript source.
  final String source;

  /// Increases each time the script is saved, so caches and agents can
  /// tell versions apart.
  final int version;

  /// What the script may do besides computing. Capabilities this version
  /// doesn't know are dropped when reading JSON, so a newer project can't
  /// grant more than an older SDK understands.
  @JsonKey(fromJson: _capabilitiesFromJson)
  final List<ScriptCapability> capabilities;

  /// The longest the script may compute, in milliseconds, not counting time
  /// waiting for the app (actions, API calls).
  final int timeoutMs;

  /// The most memory the script may use, in megabytes. Enforced on devices;
  /// on the web only [timeoutMs] applies.
  final int memoryLimitMb;

  /// The id of the Editor page whose screens can use the script, or null
  /// for a project script every screen can use. Like page and app
  /// variables, a page script of the same name wins over a project script.
  final String? pageId;

  /// Creates a [ScriptModel].
  const ScriptModel({
    required this.id,
    required this.name,
    this.description = '',
    this.params = const [],
    this.source = '',
    this.version = 1,
    this.capabilities = const [],
    this.timeoutMs = 1000,
    this.memoryLimitMb = 32,
    this.pageId,
  });

  /// The default CPU time limit.
  static const int defaultTimeoutMs = 1000;

  /// The default memory limit.
  static const int defaultMemoryLimitMb = 32;

  /// The longest timeout a script may set.
  static const int maxTimeoutMs = 30000;

  /// Names a script or parameter can't have: they're the host APIs.
  static const Set<String> reservedNames = {
    'vars', 'nodes', 'app', 'console', 'fmt', 'script', 'params', 'main',
  };

  /// Whether [name] can name a script or a parameter.
  static bool isValidName(String name) =>
      RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$').hasMatch(name) &&
      !reservedNames.contains(name) &&
      !_jsReserved.contains(name);

  static const Set<String> _jsReserved = {
    'break', 'case', 'catch', 'class', 'const', 'continue', 'debugger', //
    'default', 'delete', 'do', 'else', 'export', 'extends', 'finally', 'for',
    'function', 'if', 'import', 'in', 'instanceof', 'new', 'return', 'super',
    'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void', 'while',
    'with', 'yield', 'let', 'static', 'enum', 'await', 'implements',
    'package', 'protected', 'interface', 'private', 'public', 'null', 'true',
    'false', 'undefined', 'NaN', 'Infinity', 'arguments', 'eval',
  };

  /// Whether this is a project script rather than a page script.
  bool get isProjectScope => pageId == null;

  /// The names of the [params], in order.
  List<String> get paramNames => [for (final ScriptParam p in params) p.name];

  /// The ids of the [capabilities], e.g. `variables.read`.
  List<String> get capabilityIds => [for (final ScriptCapability c in capabilities) c.id];

  /// What's wrong with this script's name, params or limits, or empty when
  /// nothing is. Doesn't check the source; the engine does.
  List<String> validate() => [
        if (!isValidName(name))
          'Name "$name" must be a JavaScript identifier and not one of ${reservedNames.join(', ')}.',
        for (final ScriptParam p in params)
          if (!isValidName(p.name))
            'Parameter "${p.name}" must be a JavaScript identifier and not one of ${reservedNames.join(', ')}.',
        if (params.map((p) => p.name).toSet().length != params.length)
          'Parameter names must be unique.',
        if (timeoutMs < 1 || timeoutMs > maxTimeoutMs)
          'timeoutMs must be from 1 to $maxTimeoutMs.',
        if (memoryLimitMb < 1 || memoryLimitMb > 256)
          'memoryLimitMb must be from 1 to 256.',
      ];

  /// A copy with the given fields replaced.
  ScriptModel copyWith({
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
  }) =>
      ScriptModel(
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
      );

  /// Creates a [ScriptModel] from JSON.
  factory ScriptModel.fromJson(Map json) => _$ScriptModelFromJson(json);

  @override
  Map toJson() => _$ScriptModelOmitDefaults(this, _$ScriptModelToJson(this));

  @override
  List<Object?> get props => [
        id, name, description, params, source, version, capabilities, //
        timeoutMs, memoryLimitMb, pageId,
      ];
}
