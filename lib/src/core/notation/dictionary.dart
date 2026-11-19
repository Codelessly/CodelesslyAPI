// The built-in dictionary (docs/design/23-base-and-dictionary.md section
// 5.2): words the notation has as definitions written in its base words
// (`dictionary/*.txt` of this package, embedded by tool/dictionary/generate.dart
// in dictionary.g.dart, since an app and the web read no files), read once.
//
// A design system's definition of a word wins over the dictionary's, and so
// does its component of that name, as either wins over a page word; a page's
// own `define` of a dictionary word is not used (notationBuiltInWord), as for
// any word the notation has.
import 'define.dart' show NotationDefinition, readDefinitions;
import 'dictionary.g.dart';

/// Where a dictionary word is written: its definitions' file names start so
/// (`dictionary/computed.txt`), which the vocabulary record reads.
const notationDictionaryFolder = 'dictionary/';

/// The built-in dictionary's definitions, by word.
final Map<String, List<NotationDefinition>> notationDictionary = readDefinitions({
  for (final e in notationDictionaryTexts.entries) '$notationDictionaryFolder${e.key}': e.value,
}).words;

/// The words of the built-in dictionary.
Set<String> get notationDictionaryWords => notationDictionary.keys.toSet();

/// Whether [d] is one of the built-in dictionary's.
bool isDictionaryDefinition(NotationDefinition d) => d.file.startsWith(notationDictionaryFolder);
