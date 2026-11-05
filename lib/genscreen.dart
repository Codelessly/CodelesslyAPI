/// Screens generated from a one-line prompt and a DESIGN.md design kit:
/// the kit format (parser, writer, exporter, Codelessly theme bridge), the
/// screen plan an LLM writes, its validator, and the compiler that turns a
/// plan into responsive Codelessly node trees.
///
/// See `CodelesslyEditor/docs/design_md_spec.md`.
library;

export 'src/genscreen/design_kit.dart';
export 'src/genscreen/design_md_parser.dart';
export 'src/genscreen/design_md_writer.dart';
export 'src/genscreen/icon_vocabulary.dart';
export 'src/genscreen/screen_compiler.dart';
export 'src/genscreen/screen_plan.dart';
export 'src/genscreen/screen_prompt.dart';
export 'src/genscreen/screen_checks.dart';
export 'src/genscreen/kit_bridge.dart';
