// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель информации об обновлении приложения
// Проверяет версию и предлагает скачать новую версию
// ============================================================================

class UpdateInfoBean {
  /*
   * appVersion : "1.0.0"
   * appName : "Нет"
   * updateInfo : "Нет"
   * downloadUrl : "Нет"
   * appId : "001"
   */

  late String appVersion;
  late String appName;
  late String updateInfo;
  late String downloadUrl;
  late String appId;

  static UpdateInfoBean fromMap(Map<String, dynamic> map) {
    UpdateInfoBean updateInfoBean = new UpdateInfoBean();
    updateInfoBean.appVersion = map['appVersion'] as String? ?? '';
    updateInfoBean.appName = map['appName'] as String? ?? '';
    updateInfoBean.updateInfo = map['updateInfo'] as String? ?? '';
    updateInfoBean.downloadUrl = map['downloadUrl'] as String? ?? '';
    updateInfoBean.appId = map['appId'] as String? ?? '';
    return updateInfoBean;
  }

  static List<UpdateInfoBean> fromMapList(dynamic mapList) {
    List<UpdateInfoBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }

  static bool needUpdate(String oldVersion, String newVersion) {
    final oldList = oldVersion.split(".");
    final newList = newVersion.split(".");

    bool needUpdate = false;

    for (var i = 0; i < oldList.length; i++) {
      String oldNumString = oldList[i];
      String newNumString = newList[i];
      int oldNum = int.parse(oldNumString);
      int newNum = int.parse(newNumString);
      if (newNum > oldNum) {
        needUpdate = true;
        return needUpdate;
      } else if (oldNum > newNum) {
        return false;
      }
    }
    return needUpdate;
  }
}
