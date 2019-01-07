import 'package:flutter/material.dart';
import 'package:quiet/model/model.dart';
import 'package:quiet/service/channel_downloads.dart';

class DownloadService extends StatefulWidget {
  final Widget child;

  const DownloadService({Key key, this.child}) : super(key: key);

  @override
  DownloadServiceState createState() => DownloadServiceState();
}

class DownloadServiceState extends State<DownloadService> {
  DownloadStateValue value;

  @override
  void initState() {
    super.initState();
    value = downloadManager.value;
    downloadManager.addListener(_onDownloadStateChanged);
  }

  void _onDownloadStateChanged() {
    setState(() {
      value = downloadManager.value;
    });
  }

  @override
  void dispose() {
    downloadManager.removeListener(_onDownloadStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DownloadState(child: widget.child, value: value);
  }
}

class DownloadState extends InheritedWidget {
  DownloadState({@required Widget child, @required this.value})
      : super(child: child);

  final DownloadStateValue<Music> value;

  static DownloadStateValue<Music> of(BuildContext context) {
    final widget =
        context.inheritFromWidgetOfExactType(DownloadState) as DownloadState;
    assert(widget != null, "must wrap widget by [DownloadService]");
    return widget.value;
  }

  @override
  bool updateShouldNotify(DownloadState oldWidget) {
    return value != oldWidget.value;
  }
}
