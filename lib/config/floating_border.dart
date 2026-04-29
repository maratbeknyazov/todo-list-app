import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo_list/utils/geometry_util.dart';

///Реализация правильного шестиугольника
class FloatingBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    ///Центр правильного шестиугольника
    Offset center = rect.center;

    ///Длина стороны правильного шестиугольника
    double length = rect.width / 2;

    ///Координаты шести точек правильного шестиугольника, начиная с самой левой точки, по часовой стрелке
    Point<double> one = Point<double>(center.dx - length, center.dy);
    Point<double> two = Point<double>(
      length / 2 + one.x,
      center.dy - ((sqrt(3) / 2) * length),
    );
    Point<double> three = Point<double>(two.x + length, two.y);
    Point<double> four = Point<double>(one.x + length * 2, one.y);
    Point<double> five = Point<double>(
      three.x,
      center.dy + ((sqrt(3) / 2) * length),
    );
    Point<double> six = Point<double>(two.x, five.y);

    return _drawRoundPolygon([one, two, three, four, five, six], 3);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  Path _drawRoundPolygon(List<Point<double>> ps, double distance) {
    var path = Path();
    ps.add(ps[0]);
    ps.add(ps[1]);
    var p0 = LineInterCircle.intersectionPoint(ps[1], ps[0], distance);
    path.moveTo(p0.x.toDouble(), p0.y.toDouble());
    for (int i = 0; i < ps.length - 2; i++) {
      var p1 = ps[i];
      var p2 = ps[i + 1];
      var p3 = ps[i + 2];
      var interP1 = LineInterCircle.intersectionPoint(p1, p2, distance);
      var interP2 = LineInterCircle.intersectionPoint(p3, p2, distance);
      path.lineTo(interP1.x.toDouble(), interP1.y.toDouble());
      path.arcToPoint(
        Offset(interP2.x.toDouble(), interP2.y.toDouble()),
        radius: Radius.circular(distance * 6),
      );
    }
    return path;
  }
}
