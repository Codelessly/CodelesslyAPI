// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:math';

import 'package:vector_math/vector_math.dart';

import 'models/models.dart';

/// Calculates the cosine of [degrees] in degrees
double cosDeg(int degrees) => cos(degrees * pi / 180);

/// Calculates the cosine of [radians] in radians
double cosRad(double radians) => cos(radians);

///calculates the sine of [degrees] in degrees
double sinDeg(int degrees) => sin(degrees * pi / 180);

///calculates the sine of [radians] in radians
double sinRad(double radians) => sin(radians);

/// Convert [a] degrees to radians.
double deg2rad(double a) => a * pi / 180;

/// Normalize [value] between [start] and [end].
num normalizeToInterval(num value, num start, num end) {
  final width = end - start;
  final offset = value - start;
  final res = (offset - (offset / width).floor() * width) + start;
  // Since 180 and -180 is the same, we prefer to use 180.
  if (res == -180) return 180;
  return res;
}

/// Returns an Vec unrotated by [radians] around the center of a rectangle
/// described by [x, y, width, height].
Vec calculateUnrotatedVecFromRotatedVec({
  required double x,
  required double y,
  required double width,
  required double height,
  required double radians,
}) {
  final Vec globalParentCenter = localRotatedVecToGlobalVec(
    localX: width / 2,
    localY: height / 2,
    parentX: x,
    parentY: y,
    radians: radians,
  );

  final unrotated = rotatePointAroundOrigin(
      globalParentCenter.x, globalParentCenter.y, -radians, [x, y, 0]);

  return Vec(unrotated[0], unrotated[1]);
}

/// Returns an Vec rotated by [radians] around the center of a rectangle
/// described by [x1, y1, x2, y2].
/// Returns the rotated top left corner of this box.
///
/// The returned box is NOT translated inside the parent boxes. It only
/// rotates the given box around it's own center point.
Vec calculateRotatedBoxTopLeftAroundSelf({
  required double radians,
  required double x2,
  required double y2,
  required double x1,
  required double y1,
}) {
  // Find center.
  final minX = min(x1, x2);
  final maxX = max(x1, x2);
  final minY = min(y1, y2);
  final maxY = max(y1, y2);
  final centerX = minX + (maxX - minX) / 2;
  final centerY = minY + (maxY - minY) / 2;

  final List<double> rotated = rotatePointAroundOrigin(
    centerX,
    centerY,
    radians,
    [minX, minY, 0],
  );

  return Vec(rotated[0], rotated[1]);
}

/// Rotates all points in [vector3] by [radians] around [origin]
/// [vector3] is a flat list of one or more x,y,z triplets.
List<double> rotatePointAroundOrigin(
    double originX, double originY, double radians, List<double> vector3) {
  assert(
      vector3.length == 3, 'The last number must be the Z axis. Let it be 0');
  final transform = Matrix4.translationValues(originX, originY, 0)
    ..rotateZ(radians)
    ..translate(-originX, -originY, 0);

  return transform.applyToVector3Array(vector3);
}

/// Rotates a point [point] around [origin] by the given [radians]
/// and returns the new coordinates as a [Vec] object
Vec rotatePointAroundVec(Vec origin, double radians, Vec point) {
  final transform = Matrix4.translationValues(origin.x, origin.y, 0)
    ..rotateZ(radians)
    ..translate(-origin.x, -origin.y, 0);

  final rotated = transform.applyToVector3Array([point.x, point.y, 0]);
  return Vec(rotated[0], rotated[1]);
}

/// Converts a [global] offset to [parentContext]'s local system, where [parentContext] is
/// rotated by [radians] angle.
Vec globalToRotatedLocalVec({
  required double globalX,
  required double globalY,
  required double parentX,
  required double parentY,
  required int degrees,
}) {
  final diffX = globalX - parentX;
  final diffY = globalY - parentY;

  if (degrees == 0) {
    return Vec(diffX, diffY);
  }

  final cosA = cosDeg(degrees);
  final sinA = sinDeg(degrees);

  return Vec(
    diffX * cosA + diffY * sinA,
    diffY * cosA - diffX * sinA,
  );
}

/// Converts a [local] offset in [parentContext]'s system, where [parentContext] is
/// rotated by [radians] angle, to a global offset.
Vec localRotatedVecToGlobalVec({
  required double localX,
  required double localY,
  required double parentX,
  required double parentY,
  required double radians,
}) {
  final cosA = cosRad(radians);
  final sinA = sinRad(radians);

  return Vec(
    parentX + localX * cosA - localY * sinA,
    parentY + localY * cosA + localX * sinA,
  );
}

/// Returns the size of the bounding box for a box sized
/// [width], [height] that is rotated by [rotationDegrees] degrees.
SizeC getBoundsSizeAfterRotation(
    double width, double height, double rotationRad) {
  if (rotationRad == 0) return SizeC(width, height);

  final double sinA = sin(rotationRad);
  final double cosA = cos(rotationRad);
  return SizeC(
    (width * cosA).abs() + (height * sinA).abs(),
    (width * sinA).abs() + (height * cosA).abs(),
  );
}

/// For a box of size [width] and [height], rotated by [rotationDegrees] degrees,
/// this returns it's bounding box, with top, left offset to [y] and [x].
///
/// The returned box is NOT translated inside the parent boxes. It only
/// rotates the given box around it's own center point.
RectC getRotatedBoundingBoxAroundSelf(
  double x,
  double y,
  double width,
  double height,
  double rotationRad,
) {
  if (rotationRad == 0) return RectC.fromLTWH(x, y, width, height);

  final SizeC rotatedSize =
      getBoundsSizeAfterRotation(width, height, rotationRad);
  return RectC.fromLTWH(
    (x + (width / 2)) - (rotatedSize.width / 2),
    (y + (height / 2)) - (rotatedSize.height / 2),
    rotatedSize.width,
    rotatedSize.height,
  );
}

/// Returns a vector that lies between the two points such that it is
/// perpendicular with the desired point.
Vec projectPointToLine(Vec p1, Vec p2, Vec toProject) {
  final Vec line = p2 - p1;
  final Vec toProjectToLine = toProject - p1;
  final double t = toProjectToLine.dot(line) / line.dot(line);
  return p1 + line * t;
}

/// Returns a vector of the point of intersection between two given lines.
/// First two vectors [p1] and [p2] are the first line, and the second two
/// vectors [p3] and [p4] are the second line.
///
/// [returns] The point of intersection. IF there is no intersection, then
/// the function returns null.
Vec? intersectionBetweenTwoLines(Vec p1, Vec p2, Vec p3, Vec p4) {
  final double t =
      ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) /
          ((p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x));
  final double u =
      ((p1.x - p3.x) * (p1.y - p2.y) - (p1.y - p3.y) * (p1.x - p2.x)) /
          ((p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x));

  if (0 <= t && t <= 1 && 0 <= u && u <= 1) {
    return Vec(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y));
  } else {
    return null;
  }
}

/// Returns a vector of the point of intersection between a given finite line
/// with a given rectangle.
///
/// The line is denoted by [inner] and [outer] vectors, and the rectangle
/// is denoted by [rect].
///
/// [returns] The point of intersection. IF there is no intersection, then
/// the function returns null.
Vec? intersectionBetweenLineAndRect(Vec inner, Vec outer, RectC rect) {
  final Vec topLeft = rect.topLeft;
  final Vec topRight = rect.topRight;
  final Vec bottomLeft = rect.bottomLeft;
  final Vec bottomRight = rect.bottomRight;

  final Vec? top = intersectionBetweenTwoLines(inner, outer, topLeft, topRight);
  final Vec? bottom =
      intersectionBetweenTwoLines(inner, outer, bottomLeft, bottomRight);
  final Vec? left =
      intersectionBetweenTwoLines(inner, outer, topLeft, bottomLeft);
  final Vec? right =
      intersectionBetweenTwoLines(inner, outer, topRight, bottomRight);

  final List<Vec> intersections = [top, bottom, left, right]
      .where((element) => element != null)
      .map((e) => e!)
      .toList();

  if (intersections.isEmpty) {
    return null;
  } else {
    return intersections.reduce((value, element) {
      return (value - inner).length < (element - inner).length
          ? value
          : element;
    });
  }
}
