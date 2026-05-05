import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/utils/my_encrypt_util.dart';



void main(){


  test("Encryption test", (){

    String text = 'Flutter is really useful!';
    String encrypt = EncryptUtil.instance.encrypt(text);
    print("After encryption: $encrypt");
    String decrypt = EncryptUtil.instance.decrypt(encrypt);
    print("After decryption: $decrypt");

  });
}