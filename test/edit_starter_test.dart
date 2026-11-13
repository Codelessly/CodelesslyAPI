// The runtime starter and the compact tools: generated from the
// declarations, within the runtime budget (design 08 §4: ≤ 6k tokens for
// the system prompt and the tools), with examples that apply cleanly.
import 'dart:convert';

import 'package:codelessly_api/core.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

/// Tokens estimated at 3.5 characters each (no tokenizer here).
int _tokens(String s) => (s.length / 3.5).ceil();

/// Tokens estimated at the ratio the API measured for the full prompt
/// (28,768 tokens for the 60,225-character system prompt and 7,813 characters
/// of tools: 2.37 characters per token; examples/stream_chat).
int _measuredTokens(String s) => (s.length / 2.37).ceil();

void main() {
  final slice = TrustProfile.agent.restrict(Catalog.core);

  test('the examples apply with no error, warning or lint, and the edit applies to the build', () {
    var r = applyOps(LayoutDocument(catalog: Catalog.core), starterBuildExample,
        catalog: Catalog.core, profile: TrustProfile.agent, check: strictEditCheck(), incomplete: true, protectRoots: true);
    expect(r.diagnostics, isEmpty, reason: '${r.diagnostics}');
    expect(endOfStream(r.document), isEmpty);
    expect(uiLints(r.document), isEmpty);
    // Streamed, op by op, as a session applies it.
    final d = OpStreamDecoder();
    var doc = LayoutDocument(catalog: Catalog.core);
    for (final s in d.add(jsonEncode(starterBuildExample))) {
      final one = applyOps(doc, [s.op], catalog: Catalog.core, profile: TrustProfile.agent, check: strictEditCheck(), incomplete: true);
      expect(one.errors, isEmpty);
      doc = one.document;
    }
    expect(d.close().diagnostics, isEmpty);
    r = applyOps(r.document, starterEditExample,
        catalog: Catalog.core, profile: TrustProfile.agent, check: strictEditCheck(), protectRoots: true);
    expect(r.diagnostics, isEmpty, reason: '${r.diagnostics}');
    expect(r.document['card']!.children, ['head', 'opt0', 'note', 'go']);
  });

  test('the starter is generated from the declarations of the allowed types', () {
    final s = runtimeStarter();
    for (final w in slice.widgets) {
      expect(s, contains(w.type), reason: w.type);
    }
    for (final a in slice.actions) {
      expect(s, contains(a.type));
    }
    for (final op in EditOp.specs) {
      expect(s, contains('`${op.op}`'));
    }
    // A type the profile does not allow is not offered.
    final narrow = runtimeStarter(profile: TrustProfile.agent.copyWith(widgets: {'canvas', 'column', 'row', 'text', 'box'}));
    expect(narrow, isNot(contains('filledButton')));
    expect(narrow, isNot(contains('slider')));
    // The rules live generations showed models need.
    expect(s, allOf(contains('balanced'), contains('must be defined'), contains('icon nodes'), contains('visible label')));
    expect(runtimeStarter(kind: 'page'), contains('1440'));
  });

  test('budget: the compact starter and tools are within 6k tokens; the full tools are not compact', () {
    final starter = runtimeStarter();
    final compact = jsonEncode(uiTools(slice, compact: true));
    final full = jsonEncode(uiTools(slice));
    final total = _tokens(starter) + _tokens(compact);
    // ignore: avoid_print
    print('runtime starter ${starter.length} chars, compact tools ${compact.length}, full tools ${full.length}: '
        '≈ $total tokens at 3.5 characters per token');
    final measured = _measuredTokens(starter) + _measuredTokens(compact);
    // ignore: avoid_print
    print('≈ $measured tokens at the 2.37 characters per token the API counted for the full prompt');
    expect(total, lessThan(6000));
    expect(measured, lessThan(6000));
    expect(compact.length, lessThan(full.length ~/ 3));
  });

  test('the compact ui_apply schema is the op envelope, strict', () {
    final schema = uiApplyCompactInputSchema();
    final item = ((schema['properties']! as Map)['ops'] as Map)['items'] as Map;
    expect(item['additionalProperties'], isFalse);
    expect((item['properties'] as Map)['op'], {'enum': [for (final s in EditOp.specs) s.op]});
    final keys = {for (final s in EditOp.specs) for (final f in s.fields) f.key};
    expect((item['properties'] as Map).keys.toSet(), keys);
  });

  test('ui_read describes node types on demand', () {
    final doc = applyOps(LayoutDocument(catalog: Catalog.core), starterBuildExample, catalog: Catalog.core).document;
    final r = readUi(doc, {'types': ['slider', 'nope']}, catalog: slice);
    final slider = (r['types']! as Map)['slider'] as Map;
    expect((slider['props'] as Map).keys, containsAll(['value', 'min', 'max']));
    expect(((r['types']! as Map)['nope'] as Map)['error'], contains('Not a node type'));
    expect(r.containsKey('outline'), isFalse);
    expect(readUi(doc, const {}).containsKey('outline'), isTrue);
  });
}
