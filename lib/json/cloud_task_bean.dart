// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель списка задач из облачного хранилища
// Используется для синхронизации задач между устройствами
// ============================================================================

import 'package:todo_list/json/task_bean.dart';

class CloudTaskBean {
  /*
   * description : "Список задач успешно получен"
   * status : 0
   * taskList : [{"id":16,"taskName":"123123123","taskType":"运动","account":"772565130@qq.com","taskStatus":"0","taskDetailNum":"1","uniqueId":"772565130@qq.com1566799964054","overallProgress":"1.0","changeTimes":"1","createDate":"2019-08-26 14:12:44 下午","finishDate":"2019-08-22T15:57:09.985443","startDate":null,"deadLine":null,"taskIconBean":{"taskName":"运动","iconBean":{"codePoint":58726,"fontFamily":"MaterialIcons","fontPackage":"","iconName":"","matchTextDirection":"false"},"colorBean":{"red":151,"green":215,"blue":178,"opacity":1}},"detailList":[{"taskDetailName":"123123123","itemProgress":1}]}]
   */

  late String description;
  late int status;
  late List<TaskBean> taskList;

  static CloudTaskBean fromMap(Map<String, dynamic> map) {
    CloudTaskBean cloudTaskBean = new CloudTaskBean();
    cloudTaskBean.description = map['description'] as String;
    cloudTaskBean.status = map['status'] as int;
    cloudTaskBean.taskList =
        TaskBean.fromNetMapList(map['taskList'] as List<dynamic>);
    return cloudTaskBean;
  }

  static List<CloudTaskBean> fromMapList(dynamic mapList) {
    List<CloudTaskBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}
