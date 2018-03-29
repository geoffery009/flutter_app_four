import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'citybean.dart';
import 'package:share/share.dart';
import './string.dart';
import './citylist.dart' as ListScreen;
import './DotsIndicator.dart';
import 'package:package_info/package_info.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder>{
        '/list': (BuildContext context) => new ListScreen.ListWidgetScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Location _location = new Location();
  Map<String, double> _currentLocation;
  String _currentLocationDes;
  StreamSubscription<Map<String, double>> _locationSubscription;
  String _searchStr = "";
  String _searchDes = "";
  String _weatherDes = "";

  String temp = "℃|℉";
  List cityArr,
      dateArr,
      today_tempArr,
      today_temp_desArr,
      today_max_tempArr,
      today_min_tempArr,
      today_windyArr,
      today_windy_gradeArr,
      today_dityArr,
      today_pmArr,
      tipsArr;
  Map<String, dynamic> daysTemp;

  bool isCTemp = true;
  List savedCitys;
  int curPosition = 0;

  final GlobalKey<ScaffoldState> _curState = new GlobalKey<ScaffoldState>();
  AnimationController animationContrller;
  Animation animation;

  final _controller = new PageController();
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  final _kArrowColor = Colors.black.withOpacity(0.8);

  PackageInfo _packageInfo = new PackageInfo(
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _curState,
        appBar: new AppBar(
          title: new Text(""),
        ),
        body: _showPageview(),
        drawer: _showDrawer());
  }

  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _showDrawer() {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text("版本: " + _packageInfo.version),
            accountEmail: new Text("test@gmail.com"),
            currentAccountPicture: new CircleAvatar(
              child: new Image(
                  image: new AssetImage("assets/ic_person_white_36dp.png")),
              backgroundColor: Colors.amber,
            ),
          ),
          _getDrawerItem(
              "assets/ic_location_on_white_36dp.png",
              _currentLocationDes == null
                  ? "当前：定位中..."
                  : "当前：" + _currentLocationDes.toString(),
              "location"),
          _getDrawerItem("assets/ic_settings_white_36dp.png", "列表", "list"),
          _getDrawerItem("assets/ic_share_white_36dp.png", "分享", "share"),
          _getDrawerItem("assets/ic_bug_report_white_36dp.png", "实验室", "lab"),
        ],
      ),
    );
  }

  Widget _getDrawerItem(String iconName, String text, String actionString) {
    return new ListTile(
      leading: new Image(
          image: new AssetImage(iconName),
          color: Colors.amber,
          width: 28.0,
          height: 28.0),
      title: new Text(text),
      onTap: () {
        // change app state...
        Navigator.pop(context); // close the drawer
        if (actionString.length == 5) {
          _shareText();
        } else if (actionString.length == 4) {
          Navigator.pushNamed(context, "/list");
//或
//          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new ListScreen.ListWidgetScreen()));
        }
      },
    );
  }

  _shareText() async {
    share(Strings.share_text);
  }

  _showPageview() {
    if (savedCitys != null) {
      return new Stack(
        children: <Widget>[
          new PageView.builder(
            controller: _controller,
            physics: new AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext c, int position) {
              return new RefreshIndicator(
                  child: new ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      _showTop1(),
                      _showTop2(),
                      _showTop3(),
                      _showTop4(),
                      _showTop5(),
                      _showDays(),
                    ],
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, top: 10.0, bottom: 10.0),
                  ),
                  onRefresh: () {
                    return _getWeatherFromAPI(savedCitys[position]);
                  });
            },
            itemCount: savedCitys.length,
            onPageChanged: (position) {
              curPosition = position;
              _getWeather(savedCitys[position]);
              debugPrint(position.toString());
            },
          ),
          new Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: new Container(
              padding: const EdgeInsets.all(20.0),
              child: new Center(
                child: new DotsIndicator(
                  color: Colors.amber.withOpacity(0.5),
                  controller: _controller,
                  itemCount: savedCitys.length,
                  onPageSelected: (int page) {
                    _controller.animateToPage(
                      page,
                      duration: _kDuration,
                      curve: _kCurve,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return new Center(
          child: new Column(
        children: <Widget>[
          new Container(
            color: Colors.red,
            width: 14.0,
            height: 48 * animation.value,
          ),
          new Text("add city"),
          new TextField(
            onSubmitted: _savetCity,
          )
        ],
      ));
    }
  }

  _getCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCitys = prefs.getStringList(Strings.saveCityKey);
      cityArr = new List(savedCitys.length);
      dateArr = new List(savedCitys.length);
      today_tempArr = new List(savedCitys.length);
      today_temp_desArr = new List(savedCitys.length);
      today_max_tempArr = new List(savedCitys.length);
      today_min_tempArr = new List(savedCitys.length);
      today_windyArr = new List(savedCitys.length);
      today_windy_gradeArr = new List(savedCitys.length);
      today_dityArr = new List(savedCitys.length);
      today_pmArr = new List(savedCitys.length);
      tipsArr = new List(savedCitys.length);
      for (int i = 0; i < savedCitys.length; i++) {
        cityArr[i] = dateArr[i] = today_tempArr[i] = today_temp_desArr[i] =
            today_max_tempArr[i] = today_min_tempArr[i] = today_windyArr[i] =
                today_windy_gradeArr[i] =
                    today_dityArr[i] = today_pmArr[i] = tipsArr[i] = "";
      }

      debugPrint("city count:" +
          (savedCitys == null ? "0" : savedCitys.length.toString()));
    });
    _getWeather(savedCitys[0]);
  }

  _savetCity(String cityName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List list = prefs.getStringList(Strings.saveCityKey);
    if (list == null) {
      list = new List();
    }
    list.add(cityName);
    prefs.setStringList(Strings.saveCityKey, list);
    _getCity();
  }

  Widget _showTop1() {
    debugPrint("refresh," + cityArr[curPosition]);
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new Expanded(
            child: new Container(
          child: new Text(
            cityArr[curPosition],
            style: new TextStyle(
                fontSize: 28.0, color: Theme.of(context).primaryColor),
          ),
        )),
        new GestureDetector(
          child: getTempColor(),
          onTap: _changeTempType,
        )
      ],
    );
  }

  _changeTempType() {
    setState(() {
      isCTemp = !isCTemp;
    });
  }

  Widget getTempColor() {
    if (isCTemp) {
      return new Row(
        children: <Widget>[
          new Text("℃",
              style: new TextStyle(color: Theme.of(context).primaryColor)),
          new Text("|"),
          new Text("℉")
        ],
      );
    }
    return new Row(
      children: <Widget>[
        new Text("℃"),
        new Text("|"),
        new Text("℉",
            style: new TextStyle(color: Theme.of(context).primaryColor))
      ],
    );
  }

  Widget _showTop2() {
    return new Container(
      child: new Text(dateArr[curPosition]),
      padding: const EdgeInsets.only(top: 28.0, bottom: 8.0),
    );
  }

  Widget _showTop3() {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(
            today_tempArr[curPosition].toString().length != 0
                ? getTempByType(double.parse(today_tempArr[curPosition]))
                : "",
            style: new TextStyle(
                fontSize: 100.0, color: Theme.of(context).primaryColor),
          ),
        ),
        new Container(
          child: _showTop3_temp_icon(),
          width: 100.0,
        )
      ],
    );
  }

  Widget _showTop3_temp_icon() {
    return new Image(
      color: Colors.amber,
      image: new AssetImage("assets/ic_cloud_black_36dp.png"),
      width: 72.0,
      height: 72.0,
    );
  }

  Widget _showTop4() {
    return new Container(
      child: new Row(
        children: <Widget>[
          new Icon(
            Icons.arrow_drop_up,
            color: Theme.of(context).primaryColor,
          ),
          new Text(
              today_min_tempArr[curPosition].toString().length != 0
                  ? getTempByType(double.parse(today_min_tempArr[curPosition]))
                  : "",
              style: new TextStyle(color: Theme.of(context).primaryColor)),
          new Text(" "),
          new Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).primaryColor,
          ),
          new Text(
              today_max_tempArr[curPosition].toString().length != 0
                  ? getTempByType(double.parse(today_max_tempArr[curPosition]))
                  : "",
              style: new TextStyle(color: Theme.of(context).primaryColor))
        ],
      ),
      padding: const EdgeInsets.only(bottom: 8.0),
    );
  }

  Widget _showTop5() {
    return new Container(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Container(
            width: 70.0,
            child: new Column(
              children: <Widget>[
                new Container(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Icon(
                        Icons.directions,
                        color: Colors.amber,
                      ),
                      new Text(
                        today_windyArr[curPosition],
                        style: new TextStyle(
                            color: Theme.of(context).primaryColor),
                      )
                    ],
                  ),
                ),
                new Text("风向")
              ],
            ),
          ),
          new Container(
            width: 70.0,
            child: new Column(
              children: <Widget>[
                new Container(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Icon(
                        Icons.flash_on,
                        color: Colors.amber,
                      ),
                      new Text(
                        today_windy_gradeArr[curPosition],
                        style: new TextStyle(
                            color: Theme.of(context).primaryColor),
                      )
                    ],
                  ),
                ),
                new Text("风力")
              ],
            ),
          ),
          new Container(
            width: 70.0,
            child: new Column(
              children: <Widget>[
                new Container(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Icon(
                        Icons.donut_large,
                        color: Colors.amber,
                      ),
                      new Text(
                        today_dityArr[curPosition],
                        style: new TextStyle(
                            color: Theme.of(context).primaryColor),
                      )
                    ],
                  ),
                ),
                new Text("湿度")
              ],
            ),
          ),
          new GestureDetector(
            onTap: _getShowTips,
            child: new Container(
              width: 70.0,
              child: new Column(
                children: <Widget>[
                  new Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Icon(
                          Icons.warning,
                          color: Colors.amber,
                        ),
                        new Text(
                          today_pmArr[curPosition],
                          style: new TextStyle(
                              color: Theme.of(context).primaryColor),
                        )
                      ],
                    ),
                  ),
                  new Text("PM25")
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getShowTips() {
    debugPrint("tips");
    _curState.currentState
        .showSnackBar(new SnackBar(content: new Text(tipsArr[curPosition])));
  }

  Widget _showDays() {
    if (daysTemp != null) {
      List<Widget> items = new List();

      items.add(new Container(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Expanded(
                child: new Text(
              "昨天",
              style: new TextStyle(color: Theme.of(context).primaryColor),
            )),
            new Container(
              child: new Row(
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: new Text(
                      daysTemp["yesterday"]["type"].toString(),
                      style: new TextStyle(color: Colors.amber),
                    ),
                  ),
                  new Text(
                    getTempByType(double.parse(daysTemp["yesterday"]["high"]
                            .toString()
                            .substring(
                                2,
                                daysTemp["yesterday"]["high"]
                                        .toString()
                                        .length -
                                    1))) +
                        "/" +
                        getTempByType(double.parse(daysTemp["yesterday"]["low"]
                            .toString()
                            .substring(
                                2,
                                daysTemp["yesterday"]["low"].toString().length -
                                    1))),
                    style: new TextStyle(color: Theme.of(context).primaryColor),
                  )
                ],
              ),
            ),
          ],
        ),
        height: 40.0,
      ));

      for (int i = 1; i < daysTemp["forecast"].length; i++) {
        String date = daysTemp["forecast"][i]["date"].toString();
        String temp = getTempByType(double.parse(daysTemp["forecast"][i]["high"]
                .toString()
                .substring(2,
                    daysTemp["forecast"][i]["high"].toString().length - 1))) +
            "/" +
            getTempByType(double.parse(daysTemp["forecast"][i]["low"]
                .toString()
                .substring(
                    2, daysTemp["forecast"][i]["low"].toString().length - 1)));
        String tempStr = daysTemp["forecast"][i]["type"].toString();
        items.add(new Container(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Expanded(
                  child: new Text(
                date,
                style: new TextStyle(color: Theme.of(context).primaryColor),
              )),
              new Container(
                child: new Row(
                  children: <Widget>[
                    new Container(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: new Text(
                        tempStr,
                        style: new TextStyle(color: Colors.amber),
                      ),
                    ),
                    new Text(
                      temp,
                      style:
                          new TextStyle(color: Theme.of(context).primaryColor),
                    )
                  ],
                ),
              ),
            ],
          ),
          height: 40.0,
        ));
      }
      return new Column(
        children: items,
      );
    } else {
      return new Column();
    }
  }

  @override
  initState() {
    super.initState();
    _initAnimationState();
    initPlatformState();
    _locationSubscription =
        _location.onLocationChanged.listen((Map<String, double> result) {
      _getLocationDes();
      setState(() {
        debugPrint("location:" + _currentLocation.toString());
        _currentLocation = result;
      });
    });

    _getCity();

    _initPackageInfo();
  }

  _initAnimationState() {
    animationContrller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 800));
    animation = new CurvedAnimation(
        parent: animationContrller, curve: Curves.easeInOut);
    animationContrller.repeat();
  }

  @override
  void dispose() {
    animationContrller.dispose();
    super.dispose();
  }

  initPlatformState() async {
    Map<String, double> location;

    try {
      location = await _location.getLocation;
    } on PlatformException {
      location = null;
    }

    if (!mounted) return;

    setState(() {
      _currentLocation = location;
    });
  }

  Widget _showLocation() {
    if (_currentLocation != null) {
//      _getWeatherFromAPI(_currentLocation["latitude"].toString(),
//          _currentLocation["longitude"].toString());
      return new Text('$_currentLocation');
    } else {
      return new Container(child: new Text("location..."));
    }
  }

//  Widget _showWeather(List weatherList){

//  }

  _getWeather(String cityNameStr) async {
    cityArr[curPosition] = cityNameStr;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(cityNameStr) != null) {
      debugPrint("got local data--" + cityNameStr);
      Map<String, dynamic> res = JSON.decode(prefs.getString(cityNameStr));
      _initWeatherData(res);
    } else {
      debugPrint("start get network data");
      _getWeatherFromAPI(cityNameStr);
    }
  }

  _saveWeather(String keyCity, String results) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(keyCity, results);
  }

  _initWeatherData(Map<String, dynamic> res) {
    debugPrint("result:" + res.toString());
    tipsArr[curPosition] = res["data"]["ganmao"].toString();
    daysTemp = res["data"];
    dateArr[curPosition] = res["data"]["forecast"][0]["date"].toString() +
        "," +
        res["data"]["forecast"][0]["type"].toString();
    today_temp_desArr[curPosition] =
        res["data"]["forecast"][0]["type"].toString();

    today_tempArr[curPosition] = res["data"]["wendu"].toString();
    String low = res["data"]["forecast"][0]["low"].toString();
    today_min_tempArr[curPosition] = low.substring(2, low.length - 1);
    String max = res["data"]["forecast"][0]["high"].toString();
    today_max_tempArr[curPosition] = max.substring(2, max.length - 1);

    today_windyArr[curPosition] = res["data"]["forecast"][0]["fx"].toString();
    today_windy_gradeArr[curPosition] =
        res["data"]["forecast"][0]["fl"].toString();
    today_dityArr[curPosition] = res["data"]["shidu"].toString();
    today_pmArr[curPosition] = res["data"]["pm25"].toString();

    setState(() {});
  }

  _getWeatherFromAPI(String cityNameStr) async {
    String url = Strings.get_6_days_weather + cityNameStr;
    debugPrint("search url:" + url);
    http.get(url, headers: null).then((response) {
      Map<String, dynamic> res = JSON.decode(response.body);
      if (res["status"] == 200) {
        _saveWeather(cityNameStr, response.body);
        _initWeatherData(res);
      } else {
        _neverSatisfied(res["message"]);
      }
    });
  }

  Future<Null> _neverSatisfied(String msg) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      child: new AlertDialog(
        title: new Text('notice'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text(msg),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<Null> _getSearchFromAPI(int position) async {
    String text = savedCitys[position];
    String url = Strings.TEXT_SEARCH + 'query=$text';
    debugPrint("search url:" + url);
    http.get(url, headers: null).then((response) {
      debugPrint(response.body);

      Map<String, dynamic> res = JSON.decode(response.body);
      if (res["status"].toString().length == 2) {
        String cityStr = res["results"][0]["name"].toString();
        cityStr = cityStr.substring(0, cityStr.length - 1);
        String province = res["results"][0]["formatted_address"];
        double lat = res["results"][0]["geometry"]["location"]["lat"];
        double lng = res["results"][0]["geometry"]["location"]["lng"];

        _getWeather(cityStr);
        setState(() {
          cityArr[position] = cityStr;
        });
      } else {
        _neverSatisfied(res["error_message"]);
      }
    });
  }

  _getLocationDes() async {
    if (_currentLocation != null) {
      String lat = _currentLocation["latitude"].toString();
      String lng = _currentLocation["longitude"].toString();
      String url = Strings.get_location_description + 'location=$lat,$lng';
      debugPrint("search url:" + url);
      http.get(url, headers: null).then((response) {
        debugPrint(response.body);

        Map<String, dynamic> res = JSON.decode(response.body);
        if (res["status"].toString().length == 2) {
          String cityStr = res["results"][0]["vicinity"].toString();
          cityStr = cityStr.substring(0, cityStr.length - 1);

//          _getWeatherFromAPI(cityStr);
          setState(() {
            _currentLocationDes = cityStr;
          });
        } else {
          _neverSatisfied(res["error_message"]);
        }
      });
    }
  }

//intl.dark
  String time2formatString(String formart, var time) {
    var y2k = new DateTime.fromMillisecondsSinceEpoch(time * 1000, isUtc: true);
    return new DateFormat(formart, "en_US").format(y2k);
  }

  String getTempByType(double fTemp) {
    if (!isCTemp) {
      return (fTemp * 1.8 + 32).round().toString() + "°";
    }
    return fTemp.round().toString() + "°";
  }
}
