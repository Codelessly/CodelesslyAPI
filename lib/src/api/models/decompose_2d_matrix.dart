// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:math' as math;

/// From https://stackoverflow.com/questions/4361242/extract-rotation-scale-values-from-2d-transformation-matrix
dynamic decompose2dMatrix(List<num> matrixList) {
  final num a = matrixList[0];
  final num b = matrixList[1];
  final num c = matrixList[2];
  final num d = matrixList[3];
  final num e = matrixList[4];
  final num f = matrixList[5];

  final num delta = a * d - b * c;

  final Map result = {
    'translation': [e, f],
    'rotation': 0.0,
    'scale': [0.0, 0.0],
    'skew': [0.0, 0.0],
  };

  // Apply the QR-like decomposition.
  if (a != 0 || b != 0) {
    var r = math.sqrt(a * a + b * b);
    result['rotation'] = (b > 0.0) ? math.acos(a / r) : -math.acos(a / r);
    result['scale'] = [r, delta / r];
    result['skew'] = [math.atan((a * c + b * d) / (r * r)), 0.0];
  } else if (c != 0.0 || d != 0.0) {
    var s = math.sqrt(c * c + d * d);
    result['rotation'] =
        math.pi / 2 - ((d > 0) ? math.acos(-c / s) : -math.acos(c / s));
    result['scale'] = [delta / s, s];
    result['skew'] = [0.0, math.atan((a * c + b * d) / (s * s))];
  } else {
    // a = b = c = d = 0
  }

  return result;
}
