import 'dart:math' as math;

/// Modeled after base64 web-safe chars, but ordered by ASCII.
const String _kPushChars =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';

/// Timestamp of the most recently generated ID. Kept at library level so
/// that consecutive calls within the same millisecond can detect the
/// collision and increment [_lastRandomSuffix] instead of re-rolling it.
int _lastPushTime = 0;

/// Random suffix of the most recently generated ID, as indices into
/// [_kPushChars].
final List<int> _lastRandomSuffix = List<int>.filled(12, 0);

final math.Random _random = math.Random.secure();

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
  final int now = DateTime.now().toUtc().millisecondsSinceEpoch;
  String id = _toPushIdBase64(now, 8);

  if (now != _lastPushTime) {
    for (int i = 0; i < 12; i += 1) {
      _lastRandomSuffix[i] = _random.nextInt(_kPushChars.length);
    }
  } else {
    // Same millisecond: increment the previous suffix by one (base-N with
    // carry) so this ID sorts strictly after the previous one.
    int i;
    for (
      i = 11;
      i >= 0 && _lastRandomSuffix[i] == _kPushChars.length - 1;
      i--
    ) {
      _lastRandomSuffix[i] = 0;
    }
    _lastRandomSuffix[i] += 1;
  }
  final String suffixStr = _lastRandomSuffix
      .map((int i) => _kPushChars[i])
      .join();
  _lastPushTime = now;

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
