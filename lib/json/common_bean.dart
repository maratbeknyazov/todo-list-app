// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Простая модель для ответов от сервера (API responses)
// Содержит статус операции и описание результата
// ============================================================================

class CommonBean {
  late String description;
  late int status;

  static CommonBean fromMap(Map<String, dynamic> map) {
    CommonBean commonBean = new CommonBean();
    commonBean.description = map['description'] as String? ?? '';
    commonBean.status = map['status'] as int? ?? 0;
    return commonBean;
  }

  static List<CommonBean> fromMapList(dynamic mapList) {
    List<CommonBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}
