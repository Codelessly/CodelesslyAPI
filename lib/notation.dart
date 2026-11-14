/// The compact notation (docs/design/13-compact-notation.md): the form an
/// agent writes for a small UI, expanded to an ordinary document.
library;

export 'src/core/notation/notation.dart'
    show NotationIssue, NotationOptions, NotationResult, NotationStream, buttonVariants, defaultTextVariants, notationTypes, parseNotation;
export 'src/core/notation/prompt.dart' show notationPrompt;
