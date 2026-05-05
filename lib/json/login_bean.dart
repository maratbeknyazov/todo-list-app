// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель ответа от сервера при входе (login)
// Содержит токен авторизации, имя пользователя и URL аватара
// ============================================================================

class LoginBean {
  late String description;
  late int status;
  late String token;
  late String username;
  late String avatarUrl;

  static LoginBean fromMap(Map<String, dynamic> map) {
    LoginBean loginBean = new LoginBean();
    loginBean.description = map['description'] as String? ?? '';
    loginBean.status = map['status'] as int? ?? 0;
    loginBean.token = map['token'] as String? ?? '';
    loginBean.username = map['username'] as String? ?? '';
    loginBean.avatarUrl = map['avatarUrl'] as String? ?? '';
    return loginBean;
  }

  static List<LoginBean> fromMapList(dynamic mapList) {
    List<LoginBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}
