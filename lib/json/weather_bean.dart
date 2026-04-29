// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель данных о погоде от API HeWeather
// Содержит температуру, влажность, ветер и другие метеоданные
// ============================================================================

class WeatherBean {
  //{"HeWeather6":[{"basic":{"cid":"TR3487004","location":"Akrotiri","parent_city":"Akrotiri","admin_area":"亚克罗提利与德凯利亚","cnty":"英国","lat":"34.60100174","lon":"32.95600128","tz":"+3.00"},"update":{"loc":"2019-07-24 16:57","utc":"2019-07-24 13:57"},"status":"ok","now":{"cloud":"35","cond_code":"100","cond_txt":"晴","fl":"30","hum":"87","pcpn":"0.0","pres":"1005","tmp":"26","vis":"16","wind_deg":"271","wind_dir":"西风","wind_sc":"0","wind_spd":"1"}}]}

  //{"HeWeather6":[{"status":"unknown location"}]} при ошибке

  late List<HeWeather6ListBean> heWeather6;

  static WeatherBean fromMap(Map<String, dynamic> map) {
    WeatherBean weatherBean = new WeatherBean();
    weatherBean.heWeather6 =
        HeWeather6ListBean.fromMapList(map['HeWeather6'] as List<dynamic>);
    return weatherBean;
  }

  static List<WeatherBean> fromMapList(dynamic mapList) {
    List<WeatherBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}

class HeWeather6ListBean {
  /*
   * status : "ok"
   * basic : {"cid":"TR3487004","location":"Akrotiri","parent_city":"Akrotiri","admin_area":"�ǿ���������¿�����","cnty":"Ӣ��","lat":"34.60100174","lon":"32.95600128","tz":"+3.00"}
   * now : {"cloud":"35","cond_code":"100","cond_txt":"��","fl":"30","hum":"87","pcpn":"0.0","pres":"1005","tmp":"26","vis":"16","wind_deg":"271","wind_dir":"����","wind_sc":"0","wind_spd":"1"}
   * update : {"loc":"2019-07-24 16:57","utc":"2019-07-24 13:57"}
   */

  late String status;
  late BasicBean basic;
  late NowBean now;
  late UpdateBean update;

  static HeWeather6ListBean fromMap(Map<String, dynamic> map) {
    HeWeather6ListBean heWeather6ListBean = new HeWeather6ListBean();
    heWeather6ListBean.status = map['status'] as String;
    heWeather6ListBean.basic =
        BasicBean.fromMap(map['basic'] as Map<String, dynamic>);
    heWeather6ListBean.now =
        NowBean.fromMap(map['now'] as Map<String, dynamic>);
    heWeather6ListBean.update =
        UpdateBean.fromMap(map['update'] as Map<String, dynamic>);
    return heWeather6ListBean;
  }

  static List<HeWeather6ListBean> fromMapList(dynamic mapList) {
    List<HeWeather6ListBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}

class BasicBean {
  /*
   * cid : "TR3487004"
   * location : "Akrotiri"
   * parent_city : "Akrotiri"
   * admin_area : "�ǿ���������¿�����"
   * cnty : "Ӣ��"
   * lat : "34.60100174"
   * lon : "32.95600128"
   * tz : "+3.00"
   */

  late String cid;
  late String location;
  late String parentCity;
  late String adminArea;
  late String cnty;
  late String lat;
  late String lon;
  late String tz;

  static BasicBean fromMap(Map<String, dynamic> map) {
    BasicBean basicBean = new BasicBean();
    basicBean.cid = map['cid'] as String;
    basicBean.location = map['location'] as String;
    basicBean.parentCity = map['parent_city'] as String;
    basicBean.adminArea = map['admin_area'] as String;
    basicBean.cnty = map['cnty'] as String;
    basicBean.lat = map['lat'] as String;
    basicBean.lon = map['lon'] as String;
    basicBean.tz = map['tz'] as String;
    return basicBean;
  }

  static List<BasicBean> fromMapList(dynamic mapList) {
    List<BasicBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}

class NowBean {
  /*
   * cloud : "35"
   * cond_code : "100"
   * cond_txt : "��"
   * fl : "30"
   * hum : "87"
   * pcpn : "0.0"
   * pres : "1005"
   * tmp : "26"
   * vis : "16"
   * wind_deg : "271"
   * wind_dir : "����"
   * wind_sc : "0"
   * wind_spd : "1"
   */

  late String cloud;
  late String condCode;
  late String condTxt;
  late String fl;
  late String hum;
  late String pcpn;
  late String pres;
  late String tmp;
  late String vis;
  late String windDeg;
  late String windDir;
  late String windSc;
  late String windSpd;

  static NowBean fromMap(Map<String, dynamic> map) {
    NowBean nowBean = new NowBean();
    nowBean.cloud = map['cloud'] as String;
    nowBean.condCode = map['cond_code'] as String;
    nowBean.condTxt = map['cond_txt'] as String;
    nowBean.fl = map['fl'] as String;
    nowBean.hum = map['hum'] as String;
    nowBean.pcpn = map['pcpn'] as String;
    nowBean.pres = map['pres'] as String;
    nowBean.tmp = map['tmp'] as String;
    nowBean.vis = map['vis'] as String;
    nowBean.windDeg = map['wind_deg'] as String;
    nowBean.windDir = map['wind_dir'] as String;
    nowBean.windSc = map['wind_sc'] as String;
    nowBean.windSpd = map['wind_spd'] as String;
    return nowBean;
  }

  static List<NowBean> fromMapList(dynamic mapList) {
    List<NowBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}

class UpdateBean {
  /*
   * loc : "2019-07-24 16:57"
   * utc : "2019-07-24 13:57"
   */

  late String loc;
  late String utc;

  static UpdateBean fromMap(Map<String, dynamic> map) {
    UpdateBean updateBean = new UpdateBean();
    updateBean.loc = map['loc'] as String;
    updateBean.utc = map['utc'] as String;
    return updateBean;
  }

  static List<UpdateBean> fromMapList(dynamic mapList) {
    List<UpdateBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}
