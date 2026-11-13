// Doc comments for the declarations, read with dart:mirrors: every static
// field of the package's classes (PropDefs, WidgetSpecs...) is found by its
// value, and its `///` comment read from its source location. Enum values,
// classes and instance fields likewise. Nothing here is hand-maintained:
// a declaration's documentation is its `doc:` string, else its dartdoc.
import 'dart:io';
// Mirrors read the declarations' source locations; this tool runs on the VM.
// ignore: deprecated_member_use
import 'dart:mirrors';

import 'package:codelessly_api/codelessly_api.dart';

/// Where a static field is declared.
final class Declared {
  Declared(this.owner, this.field, this.doc);

  /// The class (or `''` for a top-level declaration).
  final String owner;
  final String field;
  final String doc;

  String get name => owner.isEmpty ? field : '$owner.$field';
}

final class DocIndex {
  DocIndex._();

  /// Static field values → where they're declared (a const value can be
  /// declared in several places: equal consts are one object).
  final Map<Object, List<Declared>> _byValue = Map.identity();

  /// Class name → its dartdoc.
  final Map<String, String> classDocs = {};

  /// Class name → instance field name → dartdoc.
  final Map<String, Map<String, String>> fieldDocs = {};

  /// Class name → static field name → dartdoc.
  final Map<String, Map<String, String>> staticDocs = {};

  /// Enum name → value name → dartdoc.
  final Map<String, Map<String, String>> enumDocs = {};

  /// Enum name → its values, in order.
  final Map<String, List<String>> enumValues = {};

  final Map<String, List<String>> _files = {};

  /// An action's JSON type → its class (`navigate` → `NavigateAction`), by
  /// the classes' static `typeName`.
  final Map<String, String> classOfType = {};

  static DocIndex? _instance;
  static DocIndex get instance => _instance ??= DocIndex._().._build();

  void _build() {
    for (final lib in currentMirrorSystem().libraries.values) {
      if (!lib.uri.toString().startsWith('package:codelessly_api/')) continue;
      for (final d in lib.declarations.values) {
        if (d is VariableMirror && d.isConst) {
          _record(lib.getField(d.simpleName).reflectee, '', d);
        }
        if (d is! ClassMirror) continue;
        final name = MirrorSystem.getName(d.simpleName);
        classDocs[name] = _docAt(d.location, isClass: true);
        if (d.isEnum) {
          final values = <String>[];
          final docs = <String, String>{};
          for (final f in d.declarations.values) {
            if (f is VariableMirror && f.isStatic && f.isConst && !f.isPrivate) {
              final v = d.getField(f.simpleName).reflectee;
              if (v is Enum && v.runtimeType == d.reflectedType) {
                values.add(v.name);
                docs[v.name] = _docAt(f.location);
              }
            }
          }
          // Declaration order.
          final all = (d.getField(#values).reflectee as List).cast<Enum>();
          enumValues[name] = [for (final v in all) v.name];
          // Values that share one comment (`swipeLeft, swipeRight`) carry it
          // on the first only: the rest get it too.
          enumDocs[name] = _shareDocs(enumValues[name]!, docs, d);
          continue;
        }
        final fields = <String, String>{};
        for (final f in d.declarations.values) {
          if (f is! VariableMirror) continue;
          if (f.isStatic) {
            if (f.isPrivate) continue;
            try {
              final v = d.getField(f.simpleName).reflectee;
              _record(v, name, f);
              (staticDocs[name] ??= {})[MirrorSystem.getName(f.simpleName)] = _docAt(f.location);
              if (MirrorSystem.getName(f.simpleName) == 'typeName' && v is String) classOfType[v] = name;
            } catch (_) {}
          } else {
            fields[MirrorSystem.getName(f.simpleName)] = _docAt(f.location);
          }
        }
        fieldDocs[name] = fields;
      }
    }
  }

  Map<String, String> _shareDocs(List<String> values, Map<String, String> docs, ClassMirror d) {
    final out = <String, String>{};
    String? carried;
    int? carriedLine;
    for (final v in values) {
      final doc = docs[v] ?? '';
      final f = d.declarations[Symbol(v)] as VariableMirror?;
      final line = f?.location?.line;
      if (doc.isNotEmpty) {
        carried = doc;
        carriedLine = line;
        out[v] = doc;
      } else if (carried != null && line != null && carriedLine != null && line == carriedLine) {
        out[v] = carried; // on the same line as the documented value
      } else {
        out[v] = '';
        carried = null;
      }
    }
    return out;
  }

  void _record(Object? value, String owner, VariableMirror f) {
    if (value is! PropDef && value is! WidgetSpec && value is! ActionSpec) return;
    (_byValue[value as Object] ??= []).add(Declared(owner, MirrorSystem.getName(f.simpleName), _docAt(f.location)));
  }

  /// Where [value] is declared, best first: a declaration of [prefer] (a
  /// class name), then one with a doc.
  List<Declared> declarations(Object value, {Iterable<String> prefer = const []}) {
    final all = [...?_byValue[value]];
    int rank(Declared d) => prefer.contains(d.owner) ? 0 : (d.doc.isNotEmpty ? 1 : 2);
    // Equal declarations in several classes tie: by owner and name, so the
    // result doesn't depend on the order the libraries were loaded in.
    all.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      final o = a.owner.compareTo(b.owner);
      return o != 0 ? o : a.name.compareTo(b.name);
    });
    return all;
  }

  /// [def]'s documentation: its `doc:`, else the dartdoc of its declaration
  /// (in [prefer] when it is declared in several classes), else the dartdoc
  /// of the model field of the same name ([models]).
  String docOf(PropDef<Object?> def, {Iterable<String> prefer = const [], Iterable<String> models = const []}) {
    if (def.doc.isNotEmpty) return clean(def.doc);
    final decls = declarations(def, prefer: prefer);
    // Equal consts are one object: `PropDef('color', ..., null)` declared in
    // several classes. Only a declaration in the class being documented, or
    // the only declaration, speaks for it; another class's comment may
    // describe another widget.
    final own = [for (final d in decls) if (prefer.contains(d.owner)) d];
    final speaking = own.isNotEmpty ? own : (decls.length == 1 ? decls : const <Declared>[]);
    for (final d in speaking) {
      if (d.doc.isNotEmpty) return d.doc;
    }
    // A *Fields class documents a model: its field of the same name.
    for (final d in speaking) {
      for (final model in [...models, _modelOf(d.owner), '${_modelOf(d.owner)}Action']) {
        final doc = fieldDocs[model]?[d.field] ?? fieldDocs[model]?[def.key];
        if (doc != null && doc.isNotEmpty) return doc;
      }
    }
    for (final model in models) {
      final doc = fieldDocs[model]?[def.key];
      if (doc != null && doc.isNotEmpty) return doc;
    }
    return '';
  }

  /// The declaration names of [def] (`TextProps.text`), for the missing
  /// docs list.
  String nameOf(PropDef<Object?> def, {Iterable<String> prefer = const []}) {
    final d = declarations(def, prefer: prefer);
    return d.isEmpty ? def.key : d.first.name;
  }

  static String _modelOf(String fieldsClass) =>
      fieldsClass.endsWith('Fields') ? fieldsClass.substring(0, fieldsClass.length - 'Fields'.length) : fieldsClass;

  String _docAt(SourceLocation? loc, {bool isClass = false}) {
    if (loc == null) return '';
    final path = _pathOf(loc.sourceUri);
    if (path == null) return '';
    final lines = _files[path] ??= File(path).readAsLinesSync();
    var i = loc.line - 2; // the line above the declaration (0-based)
    // A class's location is its name; skip modifiers and annotations above.
    while (i >= 0 && (lines[i].trim().startsWith('@') || (isClass && lines[i].trim().isEmpty))) {
      i--;
    }
    final doc = <String>[];
    while (i >= 0 && lines[i].trim().startsWith('///')) {
      doc.insert(0, lines[i].trim().substring(3).replaceFirst(RegExp(r'^ '), ''));
      i--;
    }
    return clean(_join(doc));
  }

  static String? _pathOf(Uri uri) {
    if (uri.scheme == 'file') return uri.toFilePath();
    if (uri.scheme == 'package' && uri.pathSegments.first == 'codelessly_api') {
      return '${Directory.current.path}/lib/${uri.pathSegments.skip(1).join('/')}';
    }
    return null;
  }

  /// Dartdoc lines as Markdown: paragraphs joined, code fences kept.
  static String _join(List<String> lines) {
    final out = StringBuffer();
    var inCode = false;
    var para = <String>[];
    void flush() {
      if (para.isNotEmpty) {
        if (out.isNotEmpty) out.write('\n\n');
        out.write(para.join(' '));
        para = [];
      }
    }

    for (final l in lines) {
      if (l.trim().startsWith('```')) {
        flush();
        if (out.isNotEmpty) out.write('\n\n');
        out.write(l.trim());
        inCode = !inCode;
        if (!inCode) continue;
        continue;
      }
      if (inCode) {
        out.write('\n$l');
        continue;
      }
      if (l.trim().isEmpty) {
        flush();
      } else if (l.trimLeft().startsWith('* ') || l.trimLeft().startsWith('- ')) {
        flush();
        para.add(l.trim());
      } else {
        para.add(l.trim());
      }
    }
    flush();
    return out.toString();
  }

  /// Dartdoc references (`[Foo.bar]`) as code.
  static String clean(String doc) => doc.replaceAllMapped(RegExp(r'\[([A-Za-z_][\w.]*)\](?!\()'), (m) => '`${m[1]}`');
}
