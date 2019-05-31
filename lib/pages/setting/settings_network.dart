part of 'page_setting.dart';

class HostSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('网络请求Host: ${Settings.of(context).host}'),
      onTap: () async {
        final host = await showDialog<String>(
            context: context,
            builder: (context) {
              final controller = TextEditingController();
              //TODO, 分成3个 TextField，方便输入
              return AlertDialog(
                title: Text('处理请求的主机地址，形如http://xxxx.com/'),
                content: TextField(
                  controller: controller,
                  obscureText: false,
                ),
                actions: <Widget>[
                  FlatButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context)),
                  FlatButton(
                    child: Text('确认'),
                    onPressed: () =>
                        Navigator.pop(context, controller.value.text),
                  ),
                ],
              );
            });
        if (host != null && host.isNotEmpty) {
          Settings.of(context).host = host;
        }
      },
    );
  }
}
