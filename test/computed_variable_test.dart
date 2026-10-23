import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  const String formula =
      r"${= sortBy(filter(records, r => crateId == 'all' || r.crate == crateId), sortBy)}";

  group('computed variables', () {
    test('a normal variable has no formula and writes none', () {
      final variable = VariableData(id: 'a', name: 'a', value: 'x');
      expect(variable.formula, isNull);
      expect(variable.isComputed, isFalse);
      expect(variable.toJson().containsKey('formula'), isFalse);
    });

    test('formula round-trips through JSON', () {
      final variable = VariableData(
        id: 'v1',
        name: 'visible',
        type: VariableType.list,
        formula: formula,
      );
      final Map<String, dynamic> json = variable.toJson();
      expect(json, {
        'id': 'v1',
        'name': 'visible',
        'type': 'list',
        'formula': formula,
      });
      final VariableData decoded = VariableData.fromJson(json);
      expect(decoded.formula, formula);
      expect(decoded.isComputed, isTrue);
      expect(decoded, variable);
    });

    test('canvas variables keep the formula', () {
      final canvasVariable = VariableData(
        id: 'v1',
        name: 'count',
        type: VariableType.integer,
        formula: r'${= length(records)}',
      ).withCanvas('canvas1');
      expect(canvasVariable.formula, r'${= length(records)}');
      final decoded = CanvasVariableData.fromJson({
        ...canvasVariable.toJson(),
        'canvasId': 'canvas1',
      });
      expect(decoded.formula, r'${= length(records)}');
      expect(decoded.copyWith(name: 'n').formula, r'${= length(records)}');
    });

    test('a blank formula counts as none, so copyWith can clear it', () {
      expect(VariableData(id: 'a', name: 'a', formula: '  ').formula, isNull);
      final computed = VariableData(id: 'a', name: 'a', formula: 'x + 1');
      expect(computed.copyWith(formula: '').isComputed, isFalse);
      expect(computed.copyWith(value: '3').formula, 'x + 1');
    });

    test('the formula takes part in equality', () {
      expect(
        VariableData(id: 'a', name: 'a', formula: 'x'),
        isNot(VariableData(id: 'a', name: 'a', formula: 'y')),
      );
    });
  });
}
