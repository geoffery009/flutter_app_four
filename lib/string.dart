
class Strings {
  //搜索地名查询经纬度
  //city apikey AIzaSyC39y589UkDARiEXsiHTH_TFaV0yC2YPVs
  //https://maps.googleapis.com/maps/api/place/textsearch/json|xml?query=xxx&key=AIzaSyC39y589UkDARiEXsiHTH_TFaV0yC2YPVs
  static const String TEXT_SEARCH =
      "https://maps.googleapis.com/maps/api/place/textsearch/json?key=AIzaSyC39y589UkDARiEXsiHTH_TFaV0yC2YPVs&language=zh-CN&";

  //根据地名查询天气
  static const String get_6_days_weather =
      "https://www.sojson.com/open/api/weather/json.shtml?city=";

  //location=32.0386238,118.7813916&
  //经纬度获取位置描述
  static const String get_location_description =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?radius=200&types=political&key=AIzaSyC39y589UkDARiEXsiHTH_TFaV0yC2YPVs&language=zh-CN&";

  static const String share_text = "app下载链接：http://fir.im/LiveWeathe";

  static const String saveCityKey = "save_city_key";
  //当前位置城市
  static const String saveLocationCityKey = "save_location_city_key";
}