// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель ответа от сервера при загрузке задачи в облако
// Содержит уникальный ID задачи в облачной базе данных
// ============================================================================

class UploadTaskBean {
  /*
   * description : "Задача успешно создана"
   * uniqueId : "772565130@qq.com1566790167339"
   * status : 0
   */

  late String description;
  late String uniqueId;
  late int status;

  static UploadTaskBean fromMap(Map<String, dynamic> map) {
    UploadTaskBean uploadTaskBean = new UploadTaskBean();
    uploadTaskBean.description = map['description'] as String? ?? '';
    uploadTaskBean.uniqueId = map['uniqueId'] as String? ?? '';
    uploadTaskBean.status = map['status'] as int? ?? 0;
    return uploadTaskBean;
  }

  static List<UploadTaskBean> fromMapList(dynamic mapList) {
    List<UploadTaskBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }

  @override
  String toString() {
    return 'UploadTaskBean{description: $description, uniqueId: $uniqueId, status: $status}';
  }
}
