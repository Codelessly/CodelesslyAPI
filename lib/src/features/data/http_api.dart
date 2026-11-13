// HTTP API definitions: what an API call action calls. Pure data: the SDK's
// API service builds and sends the request.
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../core/json.dart';

/// An HTTP request method.
enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  /// The method as sent (`GET`).
  String get verb => name.toUpperCase();

  /// Whether requests with this method carry a body.
  bool get hasBody => this != get;
}

/// How an API's body is sent.
enum HttpBodyType {
  /// [HttpApi.body] as text, with [HttpApi.contentType].
  text,

  /// [HttpApi.form] as `application/x-www-form-urlencoded` fields.
  form,
}

/// The content type of a text body.
enum HttpContentType {
  text('text/plain'),
  json('application/json'),
  xml('application/xml'),
  html('text/html');

  const HttpContentType(this.mimeType);

  /// The `Content-Type` header value.
  final String mimeType;
}

/// A header, query parameter or form field: [key] and [value] may hold
/// `${input}` placeholders. A disabled entry is kept but not sent.
@immutable
final class HttpParam {
  const HttpParam(this.key, this.value, {this.enabled = true});

  final String key;
  final String value;
  final bool enabled;

  /// Whether this entry is sent: enabled, with a key.
  bool get isSent => enabled && key.trim().isNotEmpty;

  static HttpParam? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return HttpParam(
      readString(m['key']) ?? '',
      _text(m['value']),
      enabled: readBool(m['enabled']) ?? true,
    );
  }

  Json toJson() => {'key': key, 'value': value, if (!enabled) 'enabled': false};

  static List<HttpParam> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  @override
  bool operator ==(Object other) =>
      other is HttpParam && other.key == key && other.value == value && other.enabled == enabled;

  @override
  int get hashCode => Object.hash(key, value, enabled);

  @override
  String toString() => 'HttpParam($key: $value${enabled ? '' : ', disabled'})';
}

/// An input of an API: `${name}` in its URL, headers, query, form or body
/// takes the value an action passes, else [defaultValue].
@immutable
final class ApiInput {
  const ApiInput(this.name, {this.defaultValue = ''});

  final String name;
  final String defaultValue;

  static ApiInput? fromJson(Object? json) {
    final m = readMap(json);
    final name = readString(m?['name']);
    if (m == null || name == null || name.isEmpty) return null;
    return ApiInput(name, defaultValue: _text(m['default']));
  }

  Json toJson() => {'name': name, if (defaultValue.isNotEmpty) 'default': defaultValue};

  @override
  bool operator ==(Object other) => other is ApiInput && other.name == name && other.defaultValue == defaultValue;

  @override
  int get hashCode => Object.hash(name, defaultValue);
}

/// An HTTP API the app calls: method, URL, headers, query parameters and
/// body, each of which may hold `${input}` placeholders.
///
/// ```json
/// {"id": "tides", "name": "Tides", "method": "post",
///  "url": "https://api.example.com/tides",
///  "headers": [{"key": "Authorization", "value": "Bearer ${token}"}],
///  "query": [{"key": "station", "value": "${station}"}],
///  "body": "{\"day\": \"${day}\"}", "contentType": "json",
///  "inputs": [{"name": "station", "default": "9414131"}]}
/// ```
@immutable
final class HttpApi {
  const HttpApi({
    this.id = '',
    this.name = '',
    this.method = HttpMethod.get,
    this.url = '',
    this.headers = const [],
    this.query = const [],
    this.bodyType = HttpBodyType.text,
    this.body = '',
    this.contentType = HttpContentType.json,
    this.form = const [],
    this.inputs = const [],
    this.extra = const {},
  });

  final String id;

  /// The name builders gave it.
  final String name;
  final HttpMethod method;
  final String url;
  final List<HttpParam> headers;

  /// Query parameters, added to (and winning over) those in [url].
  final List<HttpParam> query;
  final HttpBodyType bodyType;

  /// The text body ([HttpBodyType.text]).
  final String body;

  /// The text body's content type, sent unless a header sets one.
  final HttpContentType contentType;

  /// The form fields ([HttpBodyType.form]).
  final List<HttpParam> form;
  final List<ApiInput> inputs;

  /// Keys this version doesn't model, kept.
  final Json extra;

  /// The input named [name].
  ApiInput? input(String name) => inputs.firstWhereOrNull((i) => i.name == name);

  static const _keys = {
    'id', 'name', 'method', 'url', 'headers', 'query', 'bodyType', 'body', 'contentType', 'form', 'inputs', //
  };

  /// Decodes an API. Never throws: bad values fall back to the defaults.
  static HttpApi fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return HttpApi(
      id: readString(m['id']) ?? '',
      name: readString(m['name']) ?? '',
      method: readEnum(HttpMethod.values, m['method'], HttpMethod.get),
      url: readString(m['url']) ?? '',
      headers: HttpParam.listFromJson(m['headers']),
      query: HttpParam.listFromJson(m['query']),
      bodyType: readEnum(HttpBodyType.values, m['bodyType'], HttpBodyType.text),
      body: readString(m['body']) ?? '',
      contentType: readEnum(HttpContentType.values, m['contentType'], HttpContentType.json),
      form: HttpParam.listFromJson(m['form']),
      inputs: [...?readList(m['inputs'])?.map(ApiInput.fromJson).nonNulls],
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
        if (id.isNotEmpty) 'id': id,
        if (name.isNotEmpty) 'name': name,
        if (method != HttpMethod.get) 'method': method.name,
        if (url.isNotEmpty) 'url': url,
        if (headers.isNotEmpty) 'headers': [for (final h in headers) h.toJson()],
        if (query.isNotEmpty) 'query': [for (final q in query) q.toJson()],
        if (bodyType != HttpBodyType.text) 'bodyType': bodyType.name,
        if (body.isNotEmpty) 'body': body,
        if (contentType != HttpContentType.json) 'contentType': contentType.name,
        if (form.isNotEmpty) 'form': [for (final f in form) f.toJson()],
        if (inputs.isNotEmpty) 'inputs': [for (final i in inputs) i.toJson()],
        ...extra,
      };

  HttpApi copyWith({
    String? id,
    String? name,
    HttpMethod? method,
    String? url,
    List<HttpParam>? headers,
    List<HttpParam>? query,
    HttpBodyType? bodyType,
    String? body,
    HttpContentType? contentType,
    List<HttpParam>? form,
    List<ApiInput>? inputs,
  }) =>
      HttpApi(
        id: id ?? this.id,
        name: name ?? this.name,
        method: method ?? this.method,
        url: url ?? this.url,
        headers: headers ?? this.headers,
        query: query ?? this.query,
        bodyType: bodyType ?? this.bodyType,
        body: body ?? this.body,
        contentType: contentType ?? this.contentType,
        form: form ?? this.form,
        inputs: inputs ?? this.inputs,
        extra: extra,
      );

  @override
  bool operator ==(Object other) => other is HttpApi && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => 'HttpApi(${method.verb} $url)';
}

String _text(Object? v) => switch (v) {
      final String s => s,
      null => '',
      _ => '$v',
    };
