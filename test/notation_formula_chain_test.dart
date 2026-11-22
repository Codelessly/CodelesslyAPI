// A chain of worked-out states where each reads the one before twice
// (`state q1={q0*q0}` … `state q10={q9*q9}`: a power by squaring, a
// mortgage's payment): each was written out in the next, so the formulas
// doubled every step (twelve short lines read as 935,000 characters, half a
// second a read, a Text the session refused). One that has grown and is
// read again is kept by its name, a variable with its formula.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _chain = '''
state price=300000
state dep=10
state rate=4.5
state years=25
state lnf=0.00374
state loan={price*(1-dep/100)}
state mr={rate/1200}
state mn={years*12}
state ex={mn*lnf}
state q0={1+ex/1024}
state q1={q0*q0}
state q2={q1*q1}
state q3={q2*q2}
state q4={q3*q3}
state q5={q4*q4}
state q6={q5*q5}
state q7={q6*q6}
state q8={q7*q7}
state q9={q8*q8}
state q10={q9*q9}
state monthly={loan*mr*q10/(q10-1)}
state interest={monthly*mn-loan}
''';

void main() {
  test('app.txt: the chain reads at once, and no formula is longer than a few of the lines written', () {
    final watch = Stopwatch()..start();
    final app = readNotationAppState(_chain, catalog: standardCatalog);
    expect(watch.elapsedMilliseconds, lessThan(2000), reason: "it took half a second before, on an idle machine; the sizes below are the measure");
    expect(app.issues, isEmpty);
    expect(jsonEncode(app.variables).length, lessThan(2500));
    for (final e in app.variables.entries) {
      final formula = e.value['formula'] ?? e.value[notationInlineFormulaKey];
      if (formula is String) expect(formula.length, lessThan(120), reason: '${e.key}: $formula');
    }
    // What is read twice after others were written out in it is a variable
    // with its formula, read by its name; a formula read once is written
    // out where it is read, as it was.
    expect(app.variables['q0'], {'type': 'decimal', 'formula': '1+((years*12)*lnf)/1024'});
    expect(app.variables['q1'], {notationInlineFormulaKey: 'q0*q0'});
    expect(app.variables['q2'], {'type': 'decimal', 'formula': '(q0*q0)*(q0*q0)'});
    expect(app.variables['q10'], {'type': 'decimal', 'formula': '(q8*q8)*(q8*q8)'});
    expect(app.variables['monthly'], {notationInlineFormulaKey: '(price*(1-dep/100))*(rate/1200)*q10/(q10-1)'});
    expect(app.variables['interest'], {notationInlineFormulaKey: '((price*(1-dep/100))*(rate/1200)*q10/(q10-1))*(years*12)-(price*(1-dep/100))'});
  });

  test('written from the last to the first, the same', () {
    final lines = _chain.trim().split('\n');
    final app = readNotationAppState('${[...lines.take(5), ...lines.skip(5).toList().reversed].join('\n')}\n', catalog: standardCatalog);
    expect(app.issues, isEmpty);
    expect(jsonEncode(app.variables).length, lessThan(4000));
  });

  test('on a page: the same chain, and a Text that reads its end is a short formula', () {
    final watch = Stopwatch()..start();
    final r = parseNotation('${_chain}Column\n  Text#t "{monthly}"\n', catalog: standardCatalog, options: const NotationOptions(width: 1440));
    expect(watch.elapsedMilliseconds, lessThan(2000));
    expect(r.issues, isEmpty);
    expect(jsonEncode(r.document).length, lessThan(6000));
    expect((((r.document['nodes'] as Map)['t'] as Map)['props'] as Map)['text'], r'${= ((price*(1-dep/100))*(rate/1200)*q10/(q10-1))}');
    final formulas = {
      for (final scope in (r.document['variables'] as Map).values)
        for (final v in scope as List)
          if ((v as Map)['formula'] != null) v['name']: v['formula'],
    };
    expect(formulas.keys, containsAll(['q0', 'q2', 'q4', 'q6', 'q8', 'q10']));
    expect(formulas['q10'], '(q8*q8)*(q8*q8)');
  });

  test('a state read once by each of the next is written out as it was; a ring is still said', () {
    final app = readNotationAppState('state a=2\nstate b={a+1}\nstate c={b*2}\nstate d={c-1}\n', catalog: standardCatalog);
    expect(app.variables['d'], {notationInlineFormulaKey: '((a+1)*2)-1'});
    final ring = readNotationAppState('state a={b+1}\nstate b={a+1}\n', catalog: standardCatalog);
    expect(ring.issues.map((i) => i.message), everyElement(contains('reads itself')));
  });

  test('a control bound to a field of a state kept by its name says why it has nowhere to write', () {
    final r = parseNotation('''
state rows=[{"id":1,"on":true}]
state shown={filter(rows,x=>x.on)}
state cur={find(shown,x=>x.id==1)}
state a={cur.id}
state b={cur.id+1}
Column
  Toggle @cur.on
''', catalog: standardCatalog, options: const NotationOptions(width: 1440));
    expect(r.issues.single.message, startsWith('@cur.on: "cur" is worked out (state cur={find((filter(rows,x=>x.on)),x=>x.id==1)}), so a change has nowhere to be written.'));
  });
}
