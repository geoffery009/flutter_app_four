import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './string.dart';
//import 'package:fluttie/fluttie.dart';

class PageContent extends StatefulWidget {
  PageContent(this.city, this._currentLocationDes);

  final String city;
  final String _currentLocationDes;

  @override
  PageContentState createState() => new PageContentState();
}

class PageContentState extends State<PageContent> {
  bool isLocationCity = false;
  bool isCTemp = true;
  String dateStr = "",
      today_tempStr = "",
      today_min_tempStr = "",
      today_max_tempStr = "",
      today_windyStr = "",
      today_windy_gradeStr = "",
      today_dityStr = "",
      today_pmStr = "",
      tipsStr = "";

  Map<String, dynamic> daysTemp;

//  var instance = new Fluttie();
  var emojiComposition;

//  FluttieAnimationController shockedEmoji;
  bool ready = false;
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new RefreshIndicator(
          child: new Stack(
            children: <Widget>[
              new ListView(
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
//              _showLoadingAnimation()
            ],
          ),
          onRefresh: () {
            return _getWeatherFromAPI();
          }),
    );
  }

  @override
  initState() {
    super.initState();
    _getWeather();
    _isLocationCityDes();
//    _initLoadingAnimation();
  }

  /**
      @override
      dispose() {
      super.dispose();

      /// When this widget gets removed (in this app, that won't happen, but it
      /// can happen for widgets using animations in other situations), we should
      /// free the resources used by our animations.
      shockedEmoji?.dispose();
      }

      _initLoadingAnimation() async {
      bool canBeUsed = await Fluttie.isAvailable();
      if (!canBeUsed) {
      print("Animations are not supported on this platform");
      return;
      }
      emojiComposition = await instance.loadAnimationFromResource(
      "assets/animations/emoji_shock.json",
      bundle: DefaultAssetBundle.of(context));
      shockedEmoji = await instance.prepareAnimation(emojiComposition,
      duration: const Duration(seconds: 2),
      repeatCount: const RepeatCount.infinite(),
      repeatMode: RepeatMode.START_OVER);
      if (mounted) {
      setState(() {
      ready = true; // The animations have been loaded, we're ready
      shockedEmoji.start(); //start our looped emoji animation
      });
      }
      }

      Widget _showLoadingAnimation() {
      if (ready && showLoading) {
      return new FluttieAnimation(shockedEmoji);
      }
      return new Container();
      }
   **/

  _getWeather() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(widget.city) != null) {
      debugPrint("got local data--" + widget.city);
      Map<String, dynamic> res = JSON.decode(prefs.getString(widget.city));
      _initWeatherData(res);
    } else {
      debugPrint("start get network data");
      _getWeatherFromAPI();
    }
  }

  _getWeatherFromAPI() async {
    if (mounted) {
      setState(() {
        showLoading = true;
      });
    }

    String url = Strings.get_6_days_weather + widget.city;
    debugPrint("search url:" + url);
    http.get(url, headers: null).then((response) {
      if (mounted) {
        setState(() {
          showLoading = false;
        });
      }
      Map<String, dynamic> res = JSON.decode(response.body);
      if (res["status"] == 200) {
        _saveWeather2Local(response.body);
        _initWeatherData(res);
      } else {
        _neverSatisfied(res["message"]);
      }
    });
  }

  _saveWeather2Local(String result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.city, result);
  }

  _initWeatherData(Map<String, dynamic> res) {
    if (mounted) {
      setState(() {
        daysTemp = res["data"];
        dateStr = res["data"]["forecast"][0]["date"].toString() +
            "," +
            res["data"]["forecast"][0]["type"].toString();
        today_tempStr = res["data"]["wendu"].toString();
        String low = res["data"]["forecast"][0]["low"].toString();
        today_min_tempStr = low.substring(2, low.length - 1);
        String max = res["data"]["forecast"][0]["high"].toString();
        today_max_tempStr = max.substring(2, max.length - 1);

        today_windyStr = res["data"]["forecast"][0]["fx"].toString();
        today_windy_gradeStr = res["data"]["forecast"][0]["fl"].toString();
        today_dityStr = res["data"]["shidu"].toString();
        today_pmStr = res["data"]["pm25"].toString();
        tipsStr = res["data"]["ganmao"].toString();
      });
    }
  }

  Widget _showTop1() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new Expanded(
            child: new Container(
          child: new Row(
            children: <Widget>[
              new Text(
                widget.city,
                style: new TextStyle(
                    fontSize: 28.0, color: Theme.of(context).primaryColor),
              ),
              _isLocation()
            ],
          ),
        )),
        new GestureDetector(
          child: _getTempColor(),
          onTap: _changeTempType,
        )
      ],
    );
  }

  Widget _isLocation() {
    if (isLocationCity) {
      if (widget._currentLocationDes == null) {
        return new Icon(
          Icons.location_on,
          color: Colors.grey,
        );
      }
      return new Icon(
        Icons.location_on,
        color: Colors.red,
      );
    } else {
      return new Container();
    }
  }

  Widget _getTempColor() {
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

  _changeTempType() {
    if (mounted) {
      setState(() {
        isCTemp = !isCTemp;
      });
    }
  }

  Widget _showTop2() {
    return new Container(
      child: new Text(dateStr),
      padding: const EdgeInsets.only(top: 28.0, bottom: 8.0),
    );
  }

  Widget _showTop3() {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(
            today_tempStr.toString().length != 0
                ? getTempByType(double.parse(today_tempStr))
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

  String getTempByType(double fTemp) {
    if (!isCTemp) {
      return (fTemp * 1.8 + 32).round().toString() + "°";
    }
    return fTemp.round().toString() + "°";
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
              today_min_tempStr.toString().length != 0
                  ? getTempByType(double.parse(today_min_tempStr))
                  : "",
              style: new TextStyle(color: Theme.of(context).primaryColor)),
          new Text(" "),
          new Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).primaryColor,
          ),
          new Text(
              today_max_tempStr.toString().length != 0
                  ? getTempByType(double.parse(today_max_tempStr))
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
                        today_windyStr,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
                        today_windy_gradeStr,
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
                        today_dityStr,
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
                          today_pmStr,
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
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(tipsStr)));
  }

  Widget _showDays() {
    if (daysTemp == null) {
      return new Container();
    }
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
                              daysTemp["yesterday"]["high"].toString().length -
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
              .substring(
                  2, daysTemp["forecast"][i]["high"].toString().length - 1))) +
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
                    style: new TextStyle(color: Theme.of(context).primaryColor),
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

  _isLocationCityDes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(Strings.saveLocationCityKey) != null &&
        widget.city != null) {
      if (mounted) {
        setState(() {
          isLocationCity = widget.city
              .contains(prefs.getString(Strings.saveLocationCityKey));
        });
      }
    }
  }
}
