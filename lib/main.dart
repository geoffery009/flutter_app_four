import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import './string.dart';
import './citylist.dart' as ListScreen;
import './SearchCityScreen.dart' as AddScreen;
import './DotsIndicator.dart';
import 'package:package_info/package_info.dart';
import './PageContentWidget.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final String selectedUrl = "http://fir.im/LiveWeathe";

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
        '/add': (BuildContext context) => new AddScreen.SearchCityScreen(),
        "/web": (BuildContext context) => new WebviewScaffold(
              url: selectedUrl,
              appBar: new AppBar(
                title: new Text("Widget webview"),
              ),
              withZoom: true,
              withLocalStorage: true,
            )
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
  List savedCitys;
  StreamSubscription<Map<String, double>> _locationSubscription;

  final GlobalKey<ScaffoldState> _curState = new GlobalKey<ScaffoldState>();

  final PageController _controller = new PageController();
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

  _skipAddScreen() async {
    bool isAdd = await Navigator.pushNamed(context, "/add");
    if (isAdd) {
      _getCity();
    }
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
          _skipListScreen();
        } else if (actionString.length == 3) {
          _skipWebScreen();
        }
      },
    );
  }

  _skipWebScreen() {
    Navigator.pushNamed(context, "/web");
  }

  _skipListScreen() async {
    String data = await Navigator.pushNamed(context, "/list");
    debugPrint("back-----------------");
    _getCity().then((bool) {
      if (data != null && data.length > 0) {
        int pageIndex = -1;
        for (int i = 0; i < savedCitys.length; i++) {
          if (data.contains(savedCitys[i])) {
            pageIndex = i;
            break;
          }
        }
        debugPrint(
            "Selected:" + data.toString() + ",index:" + pageIndex.toString());
        if (pageIndex >= 0) {
          _controller.animateToPage(pageIndex,
              duration: kTabScrollDuration, curve: Curves.ease);
        }
      }
    });
  }

  _shareText() async {
    share(Strings.share_text);
  }

  _showPageview() {
    if (savedCitys != null) {
      return new Stack(
        children: <Widget>[
          new PageView.custom(
            controller: _controller,
            physics: new AlwaysScrollableScrollPhysics(),
            //滚动效果，Android的波纹效果和ios的越界回弹效果
            childrenDelegate: new SliverChildBuilderDelegate(
                (context, index) =>
                    new PageContent(savedCitys[index], _currentLocationDes),
                childCount: savedCitys.length),
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
      return new GestureDetector(
          onTap: _skipAddScreen,
          child: new Center(
            child: new Container(
              padding: const EdgeInsets.only(top: 48.0),
              child: new Column(
                children: <Widget>[new Text("轻点添加")],
              ),
            ),
          ));
    }
  }

  Future<bool> _getCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        savedCitys = prefs.getStringList(Strings.saveCityKey);
        debugPrint("city count:" +
            (savedCitys == null ? "0" : savedCitys.length.toString()));
      });
    }
    return true;
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

  @override
  initState() {
    super.initState();
    _initPackageInfo();
    _initPlatformState();

    _locationSubscription =
        _location.onLocationChanged.listen((Map<String, double> result) {
      _getLocationDesFromAPI();
      if (mounted) {
        setState(() {
          debugPrint("location:" + _currentLocation.toString());
          _currentLocation = result;
        });
      }
    });

    _getCity();
  }

  _initPlatformState() async {
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

  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  _getLocationDesFromAPI() async {
    if (_currentLocation != null) {
      String lat = _currentLocation["latitude"].toString();
      String lng = _currentLocation["longitude"].toString();
      String url = Strings.get_location_description + 'location=$lat,$lng';
//      debugPrint("search url:" + url);
      http.get(url, headers: null).then((response) {
//        debugPrint(response.body);

        Map<String, dynamic> res = JSON.decode(response.body);
        if (res["status"].toString().length == 2) {
          String cityStr = res["results"][0]["vicinity"].toString();
          cityStr = cityStr.substring(0, cityStr.length - 1);
          _saveLocationCity();
          if (mounted) {
            setState(() {
              _currentLocationDes = cityStr;
            });
          }
        } else {
          debugPrint(res["error_message"]);
        }
      });
    }
  }

  _saveLocationCity() async {
    if (_currentLocationDes == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        Strings.saveLocationCityKey, _currentLocationDes.toString());
  }
}
