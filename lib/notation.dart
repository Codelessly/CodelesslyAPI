/// The compact notation (docs/design/13-compact-notation.md): the form an
/// agent writes for a small UI, expanded to an ordinary document.
library;

export 'src/core/notation/notation.dart'
    show NotationIssue, NotationOptions, NotationResult, NotationStream, buttonVariants, defaultTextVariants, notationTypes, parseNotation;
export 'src/core/notation/prompt.dart' show notationPrompt;
export 'src/core/a2ui/a2ui.dart' show A2uiResult, a2uiToDocument, parseA2ui;
