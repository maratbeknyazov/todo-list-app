import 'package:flutter_test/flutter_test.dart';



mixin class Walker{
  void todo(){
    print("\nI can walk\n");
  }
}

mixin class Pilot{
  void todo(){
    print("\nI can fly\n");
  }
}

mixin class Jumper{
  void todo(){
    print("\nI can jump\n");
  }
}

class PersonOne with Pilot, Jumper{
  PersonOne(){
    print("${this.runtimeType}");
  }
}

class PersonTwo with Walker, Jumper{
  PersonTwo(){
    print("${this.runtimeType}");
  }
}

class PersonThree with Walker, Pilot{
  PersonThree(){
    print("${this.runtimeType}");
  }
}

void main(){
  test(("Test mixin mechanism:\n"), (){

    print(DateTime.now().millisecondsSinceEpoch);

    // PersonOne personOne = PersonOne()..todo();
    // PersonTwo personTwo = PersonTwo()..todo();
    // PersonThree personThree = PersonThree()..todo();
  });

}