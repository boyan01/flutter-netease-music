import 'package:flutter/material.dart';
import 'package:quiet/material/app.dart';

import 'material.dart';
import 'theme_picker.dart';

///App 设置页面
class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        titleSpacing: 0,
      ),
      body: Container(
        color: const Color.fromARGB(255, 243, 243, 243),
        child: ListView(
          children: <Widget>[
            SettingGroup(
              title: '通用',
              children: <Widget>[
                ListTile(
                  title: Text('更换主题'),
                  onTap: () => ThemePicker.show(context),
                ),
                _CopyRightCheckBox(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CopyRightCheckBox extends StatefulWidget {
  @override
  __CopyRightCheckBoxState createState() => __CopyRightCheckBoxState();
}

class __CopyRightCheckBoxState extends State<_CopyRightCheckBox> {
  bool _dismiss = false;

  @override
  void initState() {
    super.initState();
    _dismiss = CopyRightOverlay.isShouldDismiss(context);
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: _dismiss,
      onChanged: (value) {
        setState(() {
          _dismiss = value;
        });
        CopyRightOverlay.setDismiss(context, value);
      },
      title: Text('隐藏版权浮层'),
    );
  }
}
