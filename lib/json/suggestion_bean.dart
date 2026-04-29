// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель отзывов и предложений пользователей
// Используется на странице "Стена отзывов"
// ============================================================================

class SuggestionBean {
  /*
   * description : "Запрос выполнен успешно"
   * status : 0
   * suggestions : [{"id":9,"account":"default","suggestion":"test for submitting suggestions with avatar","connect_way":"<emoji>2<emoji>","avatarUrl":"files/default/2019/7/icon.png","userName":"anonymous","time":"2019-08-15"},{"id":10,"account":"default","suggestion":"test for submitting suggestions with avatar","connect_way":"<emoji>2<emoji>","avatarUrl":"files/default/2019/7/icon.png","userName":"anonymous","time":"2019-08-15"},{"id":11,"account":"default","suggestion":"test for submitting suggestions with avatar","connect_way":"<emoji>2<emoji>","avatarUrl":"files/default/2019/7/icon.png","userName":"anonymous","time":"2019-08-15"},{"id":12,"account":"default","suggestion":"test for submitting suggestions with avatar","connect_way":"<emoji>2<emoji>","avatarUrl":"files/default/2019/7/icon.png","userName":"anonymous","time":"2019-08-15"}]
   */

  late String description;
  late int status;
  late List<SuggestionsListBean> suggestions;

  static SuggestionBean fromMap(Map<String, dynamic> map) {
    SuggestionBean suggestionBean = new SuggestionBean();
    suggestionBean.description = map['description'];
    suggestionBean.status = map['status'];
    suggestionBean.suggestions =
        SuggestionsListBean.fromMapList(map['suggestions']);
    return suggestionBean;
  }

  static List<SuggestionBean> fromMapList(dynamic mapList) {
    List<SuggestionBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }
}

class SuggestionsListBean {
  /*
   * account : "default"
   * suggestion : "test for submitting suggestions with avatar"
   * connect_way : "<emoji>2<emoji>"
   * avatarUrl : "files/default/2019/7/icon.png"
   * userName : "anonymous"
   * time : "2019-08-15"
   * id : 9
   */

  late String account;
  late String suggestion;
  late String connectWay;
  late String avatarUrl;
  late String userName;
  late String time;
  late int id;

  static SuggestionsListBean fromMap(Map<String, dynamic> map) {
    SuggestionsListBean suggestionsListBean = new SuggestionsListBean();
    suggestionsListBean.account = map['account'] ?? '';
    suggestionsListBean.suggestion = map['suggestion'] ?? '';
    suggestionsListBean.connectWay = map['connect_way'] ?? '';
    suggestionsListBean.avatarUrl = map['avatarUrl'] ?? '';
    suggestionsListBean.userName = map['userName'] ?? '';
    suggestionsListBean.time = map['time'] ?? '';
    suggestionsListBean.id = map['id'];
    return suggestionsListBean;
  }

  static List<SuggestionsListBean> fromMapList(dynamic mapList) {
    List<SuggestionsListBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }
}
