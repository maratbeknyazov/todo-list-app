import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/utils/icon_utils.dart';

void main() {
//  test("\nTest getting variables from class\n", () {
//    File file = new File(
//        "/Users/lichen/flutter/packages/flutter/lib/src/material/icons.dart");
//    expect(true, file.existsSync());
//    final text = file.readAsStringSync();
//    final listOne = text.split("static const IconData ");
//    List<String> names = [];
//    for (var o in listOne) {
//      final theNames = o.split(" = IconData(");
//      names.add("\"${theNames[0]}\"");
//    }
//    print("Result:\n:${names}");
//  });


  Map<String, dynamic> toMap(IconData icon, String name) {
    return {
      '\"codePoint\"': "\"${icon.codePoint}\"",
      '\"fontFamily\"': "\"${icon.fontFamily}\"",
      '\"fontPackage\"': "\"${icon.fontPackage}\"",
      '\"iconName\"': "\"$name\"",
      '\"matchTextDirection\"': "\"${icon.matchTextDirection}\""
    };
    //When converting list to string, don't use toString directly, use jsonEncode
  }

  test("Test icondata conversion", (){
    final list = IconUtil.getInstance().icons;
//    print("icons:\n${list.toString()}");


    List<Map<String, dynamic>> jsons = List.generate(list.length, (index){
      return toMap(list[index], IconUtil.getInstance().iconNames[index]);
    });
   print("Data:\n$jsons");
  });


  test("Local json conversion test", (){
//    final data = IconBean.loadAsset();
//    print("data:${data}");
//    data.then((list){
//      print("list:${list}");
//    });
  });

}