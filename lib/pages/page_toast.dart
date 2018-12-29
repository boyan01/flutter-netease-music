import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class ToastPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text("Test"),
          ),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                child: Text("faijsofjaisjfioajsfk"),
              ),
              RaisedButton(
                onPressed: () {
                  showSimpleNotification(context, Text("操作失败"),
                      icon: Icon(Icons.error),background: Colors.red);
                },
                child: Text("button"),
              )
            ],
          ),
        ),
//        Notification()
      ],
    );
  }
}
