/// The compact notation (docs/design/13-compact-notation.md): the form an
/// agent writes for a small UI, expanded to an ordinary document.
library;

export 'src/core/notation/notation.dart'
    show
        NotationIssue,
        NotationOptions,
        NotationResult,
        NotationStream,
        WantedBlock,
        buttonVariants,
        defaultTextVariants,
        notationScreen,
        notationTypes,
        parseNotation;
export 'src/core/notation/define.dart' show DefinedLine, DefinedWords, NotationDefinition, checkDefinitions, definitionLines, readDefinitions, readPageDefinitions;
export 'src/core/notation/vocabulary.dart' show LinePart, LineParts, NotationVocabulary, TypeAlias, VocabularyUse;
export 'src/core/notation/universal.dart' show UniversalKind, UniversalWord, isUniversal, notationUniversal, universalWords;
export 'src/core/notation/print.dart' show notationOptionsFor, printNotation;
export 'src/core/notation/prompt.dart' show notationDefinePreface, notationGlossary, notationGlossaryLead, notationPrompt;
export 'src/core/a2ui/a2ui.dart' show A2uiResult, a2uiToDocument, parseA2ui;
