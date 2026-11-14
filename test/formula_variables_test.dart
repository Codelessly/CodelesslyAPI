// A computed variable's formula is checked like a node's expressions: it
// must parse and read only declared names (its parameters too). A name that
// is a field of a list variable's records is an item's field written
// without its item (`filter(invoices, status == 'Paid')`, which is computed
// once, outside the list, and matches nothing): the message says how to read
// it through a lambda. The edit layer checks the formulas of the variables a
// `vars` op declares; while a stream runs an unknown name is a warning, and
// `unresolvedReferences` reports what is still unknown when it ends.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

/// A stand-in for the SDK's formula parser: the names each formula reads.
const _reads = {
  "filter(invoices, (statusF == 'All' || status == statusF) && contains(lower(cust), lower(search)))": {
    'invoices', 'statusF', 'status', 'cust', 'search', //
  },
  "filter(invoices, i => (statusF == 'All' || i.status == statusF) && contains(lower(i.cust), lower(search)))": {
    'invoices', 'statusF', 'search', //
  },
  'slice(shown, page * 5, page * 5 + 5)': {'shown', 'page'},
  "'\$' + round(n)": {'n'},
  'count(rows, r => r.done) + missing': {'rows', 'missing'},
};

final _options = ValidateOptions(formulas: (f) => (error: f.endsWith('+') ? 'Unexpected end' : null, paths: _reads[f] ?? <String>{}));

const _bad = "filter(invoices, (statusF == 'All' || status == statusF) && contains(lower(cust), lower(search)))";
const _good = "filter(invoices, i => (statusF == 'All' || i.status == statusF) && contains(lower(i.cust), lower(search)))";

Map<String, Object?> _doc(List<Map<String, Object?>> computed) => {
      'schema': kSchemaVersion,
      'roots': ['inv'],
      'nodes': {
        'inv': {'type': 'canvas', 'layout': {'width': 390, 'height': 600}},
      },
      'variables': {
        'inv': [
          {
            'name': 'invoices',
            'type': 'list',
            'value': [
              {'num': 'INV-1', 'cust': 'Acme', 'status': 'Paid'},
              {'num': 'INV-2', 'cust': 'Globex', 'status': 'Pending'},
            ],
          },
          {'name': 'statusF', 'type': 'text', 'value': 'All'},
          {'name': 'search', 'type': 'text', 'value': ''},
          {'name': 'page', 'type': 'integer', 'value': 0},
          ...computed,
        ],
      },
    };

LayoutDocument _layout(List<Map<String, Object?>> computed) => LayoutDocument.fromJson(_doc(computed));

void main() {
  group('the validator checks computed variables', () {
    test('a filter that reads its records\' fields without the item is reported, with the lambda to write', () {
      final out = validateDocument(_doc([
        {'name': 'shown', 'type': 'list', 'formula': _bad},
      ]), options: _options);
      final names = [for (final d in out) if (d.code == Codes.unknownName) d];
      expect([for (final d in names) d.path], everyElement('/variables/inv/4/formula'));
      expect(names, hasLength(2), reason: '$names'); // status and cust
      final status = names.firstWhere((d) => d.message.startsWith('"status"'));
      expect(status.message, contains('a field of the records of "invoices"'));
      expect(status.message, contains('filter(invoices, r => r.status == x)'));
      expect(status.suggestion, 'r => r.status');
    });

    test('the same filter written with a lambda passes', () {
      final out = validateDocument(_doc([
        {'name': 'shown', 'type': 'list', 'formula': _good},
        {'name': 'rows', 'type': 'list', 'formula': 'slice(shown, page * 5, page * 5 + 5)'},
      ]), options: _options);
      expect(out.where((d) => d.isError), isEmpty, reason: '$out');
    });

    test('a function variable reads its parameters', () {
      final out = validateDocument(_doc([
        {'name': 'usd', 'type': 'text', 'parameters': ['n'], 'formula': "'\$' + round(n)"},
      ]), options: _options);
      expect(out.where((d) => d.isError), isEmpty, reason: '$out');
    });

    test('a name that is no variable and no field gets the plain message', () {
      final out = validateDocument(_doc([
        {'name': 'rows', 'type': 'list', 'value': []},
        {'name': 'n', 'type': 'integer', 'formula': 'count(rows, r => r.done) + missing'},
      ]), options: _options);
      final d = out.singleWhere((d) => d.code == Codes.unknownName);
      expect(d.message, startsWith('"missing" is not a declared variable of canvas "inv"'));
    });

    test('a computed variable whose formula does not parse is reported', () {
      final out = validateDocument(_doc([
        {'name': 'n', 'type': 'integer', 'formula': 'page +'},
      ]), options: _options);
      expect(out.singleWhere((d) => d.code == Codes.expressionSyntax).path, '/variables/inv/4/formula');
    });
  });

  group('the edit layer checks the formulas of the variables an op declares', () {
    final check = strictEditCheck(_options);
    final base = _layout(const []);
    Map<String, Object?> vars(String formula) => {
          'op': 'vars',
          'scope': 'inv',
          'set': {
            'shown': {'type': 'list', 'formula': formula},
          },
        };

    test('a vars op whose filter reads an item\'s field without the item is an error naming the variable; the op stays applied', () {
      final r = applyOps(base, [vars(_bad)], check: check);
      expect(r.applied, [0], reason: 'a wrong formula is reported, not a reason to drop the variables beside it');
      final d = r.errors.firstWhere((d) => d.code == 'unknown_name');
      expect(d.message, startsWith('Variable "shown": "status" is not a variable'));
      expect(d.path, '/variables/inv/4/formula');
      expect(d.op, 0);
    });

    test('one formula that does not parse leaves the other variables of its vars op declared, so the UI that reads them still shows', () {
      // A recorded reservation card (reservation@claude-sonnet-5-5, SSUI)
      // declared its days, slots, party and chosen time in one vars op with
      // a slot formula written as JavaScript; rejecting the op left every
      // node reading nothing (25 unknown names, no days, no party size).
      final r = applyOps(base, [
        {
          'op': 'vars',
          'scope': 'inv',
          'set': {
            'party': {'type': 'integer', 'value': 2},
            'slotData': {'type': 'list', 'formula': 'page +'},
          },
        },
      ], check: check, incomplete: true);
      expect(r.applied, [0]);
      final names = [for (final v in readList(readMap(r.document.extra['variables'])?['inv'])!) (v as Map)['name']];
      expect(names, containsAll(['party', 'slotData']));
      final d = r.errors.single;
      expect((d.code, d.op, d.path), ('expression_syntax', 0, '/variables/inv/5/formula'));
      expect(d.message, contains('"slotData" is declared but gives nothing until its formula is fixed'));
    });

    test('the same op with a lambda applies', () {
      final r = applyOps(base, [vars(_good)], check: check);
      expect(r.applied, [0]);
      expect(r.errors, isEmpty);
    });

    test('while a stream runs it is a warning, and an error once the stream has ended', () {
      final r = applyOps(base, [vars(_bad)], check: check, incomplete: true);
      expect(r.applied, [0]);
      expect(r.diagnostics.where((d) => d.code == 'unknown_name').map((d) => d.error), everyElement(isFalse));
      final changed = changedVariables(base, r.document);
      expect(changed, {
        'inv': {'shown'},
      });
      final end = unresolvedReferences(r.document, check, catalog: Catalog.core, nodes: const [], variables: changed);
      expect([for (final d in end) (d.code, d.error, d.op)], [('unknown_name', true, -1), ('unknown_name', true, -1)]);
    });

    test('a forward reference that arrives before the stream ends is not reported at the end', () {
      var doc = applyOps(base, [
        {
          'op': 'vars',
          'scope': 'inv',
          'set': {
            'rows': {'type': 'list', 'formula': 'slice(shown, page * 5, page * 5 + 5)'},
          },
        },
      ], check: check, incomplete: true).document;
      doc = applyOps(doc, [vars(_good)], check: check, incomplete: true).document;
      expect(unresolvedReferences(doc, check, catalog: Catalog.core, nodes: const [], variables: changedVariables(base, doc)), isEmpty);
    });
  });
}
