// Command line for the screen generator's model-free steps.
//
//   dart run tool/genscreen.dart prompt <kit.design.md>              # system prompt
//   dart run tool/genscreen.dart user "<request>"                    # user prompt
//   dart run tool/genscreen.dart validate <kit.design.md> <plan.json>
//   dart run tool/genscreen.dart compile <kit.design.md> <plan.json> # layout nodes JSON
//   dart run tool/genscreen.dart kit <kit.design.md>                 # parse + issues
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/genscreen.dart';

DesignKit _kit(String path) {
  final DesignMdParseResult r = const DesignMdParser().parse(File(path).readAsStringSync());
  for (final DesignMdIssue i in r.issues) {
    stderr.writeln(i);
  }
  return r.kit;
}

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: genscreen.dart prompt|user|validate|compile|kit ...');
    exit(64);
  }
  switch (args.first) {
    case 'prompt':
      stdout.write(ScreenPrompt(_kit(args[1])).system());
    case 'user':
      stdout.write(ScreenPrompt(const DesignKit(name: '')).user(args[1]));
    case 'kit':
      final DesignKit kit = _kit(args[1]);
      stdout.writeln('${kit.name} ${kit.fingerprint}');
    case 'validate':
      final DesignKit kit = _kit(args[1]);
      final List<PlanIssue> issues = ScreenPlanValidator(kit).validate(
        extractPlanJson(File(args[2]).readAsStringSync()),
      );
      for (final PlanIssue i in issues) {
        stdout.writeln(i);
      }
      exit(issues.any((i) => i.severity == PlanSeverity.error) ? 1 : 0);
    case 'compile':
      final CompiledScreen s = ScreenCompiler(_kit(args[1])).compile(
        extractPlanJson(File(args[2]).readAsStringSync()),
      );
      stdout.write(jsonEncode({'nodes': s.toLayoutNodes(), 'variables': s.variables, 'report': s.report.toJson()}));
  }
}
