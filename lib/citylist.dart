import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import './string.dart';

class ListWidgetScreen extends StatefulWidget {
  @override
  _ListWidgetState createState() => new _ListWidgetState();
}

class _ListWidgetState extends State<ListWidgetScreen> {
  List<String> items;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.add),
              onPressed: () {
                _skipAddScreen();
              })
        ],
        title: new Text("列表"),
      ),
      body: new Container(child: _showList()),
    );
  }

  @override
  initState() {
    super.initState();
    _getSaveData();
  }

  _getSaveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> temp = prefs.getStringList(Strings.saveCityKey);
    if (temp != null) {
      items = new List();
      for (int i = 0; i < temp.length; i++) {
        items.add(temp[i]);
      }
    }
    setState(() {});
  }

  _savetCity() async {
    debugPrint(items.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (items.length == 0) {
      prefs.setStringList(Strings.saveCityKey, []);
      return;
    }
    prefs.setStringList(Strings.saveCityKey, items);
  }

  Widget _showList() {
    if (items != null) {
      return new ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, int position) {
            return new Dismissible(
              key: new Key(items[position]),
              child: new ListTile(
                onTap: () {
                  debugPrint(position.toString());
                  _closeScreen(items[position]);
                },
                title: new Text(items[position]),
              ),
              background: new Container(
                color: Colors.amber,
              ),
              onDismissed: (direction) {
                items.removeAt(position);
                Scaffold
                    .of(context)
                    .showSnackBar(new SnackBar(content: new Text("已删除")));
                _savetCity();
                _getSaveData();
              },
            );
          });
    } else {
      return new Center(
        child: new Container(
          child: new Text("添加"),
        ),
      );
    }
  }

  _closeScreen(String name) {
    Navigator.pop(context, name);
  }

  _skipAddScreen() async {
    bool isAdd = await Navigator.pushNamed(context, "/add");
    if (isAdd) {
      _getSaveData();
    }
  }
}
