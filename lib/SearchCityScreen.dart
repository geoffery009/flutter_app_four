import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './string.dart';
import 'dart:async';
import 'dart:convert';

class SearchCityScreen extends StatefulWidget {
  @override
  _SearchCityScreenState createState() => new _SearchCityScreenState();
}

class _SearchCityScreenState extends State<SearchCityScreen> {
  List<Map<String, dynamic>> data = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("添加"),
      ),
      body: new Container(
        child: new Center(
          child: new ListView(
            children: _getItemData(),
          ),
        ),
      ),
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

  Future<Null> _getSearchFromAPI(String text) async {
    String url = Strings.TEXT_SEARCH + 'query=$text';
    debugPrint("search url:" + url);
    try {
      http.get(url, headers: null).then((response) {
        debugPrint(response.body);

        Map<String, dynamic> res = JSON.decode(response.body);
        /**
         * {
            "html_attributions" : [],
            "results" : [],
            "status" : "ZERO_RESULTS"
            }
         * **/
        if (res["status"].toString().length == 2) {
          setState(() {
            data = res["results"];
            debugPrint("search data:" + data.length.toString());
          });
        } else {
          data.clear();
        }
      });
    } catch (exception) {
      _neverSatisfied("需要使用vpn");
    }
  }

  List _getItemData() {
    List<Widget> item = new List();
    item.add(new Container(
      child: new TextField(
        onSubmitted: _getSearchFromAPI,
      ),
      padding: const EdgeInsets.all(24.0),
    ));

    if (data == null || data.length == 0) {
      item.add(new Container(
        padding: const EdgeInsets.all(24.0),
        child: new Text("无"),
      ));
    } else {
      for (int i = 0; i < data.length; i++) {
        item.add(new Container(
          padding: const EdgeInsets.all(10.0),
          child: new GestureDetector(
            onTap: () {
              _savetCity(_getCityByData(i));
              Navigator.pop(context, true);
              debugPrint("clicked " + _getCityByData(i));
            },
            child: new Text(_getCityByData(i)),
          ),
        ));
      }
    }
    return item;
  }

  _savetCity(String cityName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List list = prefs.getStringList(Strings.saveCityKey);
    List temp = new List();
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        temp.add(list[i]);
      }
    }
    temp.add(cityName);
    list == null;
    prefs.setStringList(Strings.saveCityKey, temp);
  }

  String _getCityByData(int index) {
    String cityStr = data[index]["name"].toString();
    cityStr = cityStr.substring(0, cityStr.length - 1);
    return cityStr;
  }

  String _getProvinceByData(int index) {
    String province = data[index]["formatted_address"];
    return province;
  }

  String _getLocationByData(int index) {
    double lat = data[index]["geometry"]["location"]["lat"];
    double lng = data[index]["geometry"]["location"]["lng"];
    return "${lat.toString()},${lng.toString()}";
  }
}
