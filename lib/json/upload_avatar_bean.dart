// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель ответа от сервера при загрузке аватара пользователя
// Возвращает путь к загруженному файлу на сервере
// ============================================================================

class UploadAvatarBean {
  /*
   * description : "Аватар успешно загружен"
   * filePath : "files/772565130@qq.com/2019/7/avatar.jpg"
   * status : 0
   */

  late String description;
  late String filePath;
  late int status;

  static UploadAvatarBean fromMap(Map<String, dynamic> map) {
    UploadAvatarBean uploadAvatarBean = new UploadAvatarBean();
    uploadAvatarBean.description = map['description'] as String;
    uploadAvatarBean.filePath = map['filePath'] as String;
    uploadAvatarBean.status = map['status'] as int;
    return uploadAvatarBean;
  }

  static List<UploadAvatarBean> fromMapList(dynamic mapList) {
    List<UploadAvatarBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}
