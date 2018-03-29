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
    setState(() {
      items = prefs.getStringList(Strings.saveCityKey);
      debugPrint("get " + (items == null ? "null" : items.length));
    });
  }

  Widget _showList() {
    if (items != null) {
      return new ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, int position) {
            return new Dismissible(
              key: new Key(items[position]),
              child: new ListTile(
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
}
