import 'dart:math';

import 'package:flutter_test/flutter_test.dart';


void main(){
  test("\nTest random numbers\n", (){
    for (var i = 0; i < 20; ++i) {
      final param = Random().nextInt(3);
      print("$param");
    }
    print(DateTime.now().toIso8601String());
  });
}