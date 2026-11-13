// Round-trips every layout document, node, reaction and action found in the
// JSON files listed in a file, writing one line per value found:
// `path#pointer kind digest(encode(decode(value)))`.
//
//   dart run tool/corpus_roundtrip.dart files.txt out.txt
//
// Run it before and after a change to the decoders and compare the outputs:
// equal files mean every document encodes byte for byte as before. (The
// catalog work was checked this way on 65 documents, 47,555 nodes and
// 20,573 reactions and actions from the reference apps and the SDK's
// fixtures.)
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';

String digest(Object? json) {
  // FNV-1a (64 bits) of the encoding, and its length; no crypto dependency.
  final s = jsonEncode(json);
  var h = 0xcbf29ce484222325;
  for (final c in utf8.encode(s)) {
    h ^= c;
    h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return '${h.toUnsigned(64).toRadixString(16)}:${s.length}';
}

void main(List<String> args) {
  final out = StringBuffer();
  var docs = 0, actions = 0, nodeCount = 0;
  for (final path in File(args.first).readAsLinesSync()) {
    if (path.trim().isEmpty) continue;
    Object? json;
    try {
      json = jsonDecode(File(path).readAsStringSync());
    } catch (_) {
      continue;
    }
    void walk(Object? v, String at) {
      if (v is Map) {
        final nodes = v['nodes'];
        if (nodes is Map && nodes.values.any((n) => n is Map && n['type'] is String)) {
          docs++;
          out.writeln('$path#$at doc ${digest(LayoutDocument.fromJson(v).toJson())}');
        }
        if (v['type'] is String && v['layout'] is Map) {
          nodeCount++;
          out.writeln('$path#$at node ${digest(Node.fromJson(v)?.toJson())}');
        }
        final acts = v['actions'];
        if (acts is List) {
          for (var i = 0; i < acts.length; i++) {
            final a = acts[i];
            if (a is Map && a['trigger'] != null) {
              actions++;
              out.writeln('$path#$at/actions/$i reaction ${digest(Reaction.fromJson(a)?.toJson())}');
            } else if (a is Map && a['type'] is String) {
              actions++;
              out.writeln('$path#$at/actions/$i action ${digest(ActionDef.fromJson(a)?.toJson())}');
            }
          }
        }
        for (final e in v.entries) {
          walk(e.value, '$at/${e.key}');
        }
      } else if (v is List) {
        for (var i = 0; i < v.length; i++) {
          walk(v[i], '$at/$i');
        }
      } else if (v is String && v.length > 20 && v.trimLeft().startsWith('{') && v.contains('"nodes"')) {
        // Payloads stored as JSON text (managed component versions).
        try {
          walk(jsonDecode(v), '$at(text)');
        } catch (_) {}
      }
    }

    walk(json, '');
  }
  File(args[1]).writeAsStringSync(out.toString());
  stdout.writeln('documents: $docs, nodes: $nodeCount, reactions/actions: $actions');
}
