import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/service/channel_downloads.dart';

///下载管理页面
class DownloadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DownloadService(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("下载管理"),
            bottom: TabBar(tabs: [Tab(text: "下载完成"), Tab(text: "下载中")]),
          ),
          body: TabBarView(children: [_DownloadedPage(), _DownloadingPage()]),
        ),
      ),
    );
  }
}

class _DownloadedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final completed = DownloadState.of(context).completed;
    return ListView.builder(
        itemCount: completed.length,
        itemBuilder: (context, index) {
          return SongTile(completed[index].extras, 0,
              leadingType: SongTileLeadingType.none);
        });
  }
}

class _DownloadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final downloading = DownloadState.of(context).downloading;
    if (downloading.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Text("暂无内容"),
        ),
      );
    } else {
      return ListView.builder(
          itemCount: downloading.length,
          itemBuilder: (context, index) {
            return _DownloadingTile(download: downloading[index]);
          });
    }
  }
}

class _DownloadingTile extends StatelessWidget {
  const _DownloadingTile({Key key, @required this.download}) : super(key: key);

  final Download<Music> download;

  Widget _buildSecondRow(BuildContext context) {
    switch (download.status) {
      case DownloadStatus.NONE:
      case DownloadStatus.QUEUED:
      case DownloadStatus.DOWNLOADING:
      case DownloadStatus.PAUSED:
      case DownloadStatus.COMPLETED:
      case DownloadStatus.CANCELLED:
      case DownloadStatus.FAILED:
      case DownloadStatus.REMOVED:
      case DownloadStatus.DELETED:
      case DownloadStatus.ADDED:
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 56,
        child: Row(
          children: <Widget>[
            Container(color: Colors.grey, width: 48),
            Expanded(
                child: Column(
              children: <Widget>[
                Spacer(),
                Text(download.extras.title),
                _buildSecondRow(context),
                Spacer(),
                Divider(height: 0)
              ],
            )),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  debugPrint("remove ${download.id}");
                })
          ],
        ),
      ),
    );
  }
}
