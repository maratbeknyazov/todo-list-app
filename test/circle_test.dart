import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

void main(){



  //Calculate the angle corresponding to side a of a triangle
  double getAngle(double a,double b, double c){
    double numerator = (pow(b,2) + pow(c,2) - pow(a,2)).toDouble();
    double denominator = 2 * b * c;
    double angle = acos(numerator / denominator);
    return angle;
  }

  //Calculate the distance between two coordinates
  double getDistance(Offset one, Offset two){
    double deltaX = one.dx - two.dx;
    double deltaY = one.dy - two.dy;
    double num = (pow(deltaX, 2) + pow(deltaY, 2)).toDouble();
    double distance = sqrt(num);
    return distance;
  }

  test("\nTest circle angle calculation\n", (){


    double angle = getAngle(sqrt(2), sqrt(2), 2);
    print("Angle: $angle");

    double distance = getDistance(Offset(0, sqrt(2)), Offset(sqrt(2), 0));
    print("Length: $distance");



  });


  test(("Test"), (){

    final a = 20 / 20;
    final b = 40 / 20;
    final c = 44 / 20;

    print("a:$a  b:$b  c:${c.toInt()}");

  });
}