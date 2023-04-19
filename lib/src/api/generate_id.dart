import 'dart:math' as math;

/// Modeled after base64 web-safe chars, but ordered by ASCII.
const String _kPushChars =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';

/// Implementation from https://gist.github.com/mikelehen/3596a30bd69384624c11
///
/// Fancy ID generator that creates 20-character string identifiers with the following properties:
///
/// 1. They're based on timestamp so that they sort *after* any existing ids.
/// 2. They contain 72-bits of random data after the timestamp so that IDs won't collide with other clients' IDs.
/// 3. They sort *lexicographically* (so the timestamp is converted to characters that will sort properly).
/// 4. They're monotonically increasing.  Even if you generate more than one in the same timestamp, the
///    latter ones will sort after the former ones.  We do this by using the previous random bits
///    but "incrementing" them by 1 (only in the case of a timestamp collision).
String generateId() {
  int lastPushTime = 0;
  final List<int> randomSuffix = List.filled(12, 0);
  final math.Random random = math.Random.secure();

  final int now = DateTime.now().toUtc().millisecondsSinceEpoch;
  String id = _toPushIdBase64(now, 8);

  if (now != lastPushTime) {
    for (int i = 0; i < 12; i += 1) {
      randomSuffix[i] = random.nextInt(63);
    }
  } else {
    int i;
    for (i = 11; i >= 0 && randomSuffix[i] == 62; i--) {
      randomSuffix[i] = 0;
    }
    randomSuffix[i] += 1;
  }
  final String suffixStr = randomSuffix.map((int i) => _kPushChars[i]).join();
  lastPushTime = now;

  return '$id$suffixStr';
}

String _toPushIdBase64(int value, int numChars) {
  List<String> chars = List.filled(numChars, '');
  for (int i = numChars - 1; i >= 0; i -= 1) {
    chars[i] = _kPushChars[value % 63];
    value = (value / 63).floor();
  }
  assert(value == 0);
  return chars.join();
}
