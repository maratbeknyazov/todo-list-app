// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель ответа от сервера при регистрации нового пользователя
// Похожа на LoginBean, но для процесса регистрации
// ============================================================================

class RegisterBean {
  late String description;
  late String token;
  late String avatarUrl;
  late int status;

  static RegisterBean fromMap(Map<String, dynamic> map) {
    RegisterBean diaryBase = new RegisterBean();
    diaryBase.description = map['description'] as String;
    diaryBase.token = map['token'] as String;
    diaryBase.avatarUrl = map['avatarUrl'] as String;
    diaryBase.status = map['status'] as int;
    return diaryBase;
  }

  static List<RegisterBean> fromMapList(dynamic mapList) {
    List<RegisterBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}
