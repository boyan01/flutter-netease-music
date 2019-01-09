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
            elevation: 0,
            title: Text("下载管理"),
            bottom: TabBar(
              indicator:
                  UnderlineTabIndicator(insets: EdgeInsets.only(bottom: 4)),
              tabs: [Tab(text: "下载完成"), Tab(text: "下载中")],
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
          body: BoxWithBottomPlayerController(
              TabBarView(children: [_DownloadedPage(), _DownloadingPage()])),
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
      return Column(
        children: <Widget>[
          _DownloadHeader(downloading: downloading),
          Expanded(
            child: ListView.separated(
              itemCount: downloading.length,
              itemBuilder: (context, index) {
                return _DownloadingTile(download: downloading[index]);
              },
              separatorBuilder: (context, index) {
                return Divider(indent: 40, height: 0);
              },
            ),
          )
        ],
      );
    }
  }
}

class _DownloadHeader extends StatelessWidget {
  ///the downloads which not completed
  ///can not be empty
  final List<Download<Music>> downloading;

  const _DownloadHeader({Key key, @required this.downloading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasDownloadingItem =
        downloading.indexWhere((d) => d.status == DownloadStatus.DOWNLOADING) >
            0;

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).dividerColor, width: 0.5))),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: FlatButton.icon(
                onPressed: () {
                  if (hasDownloadingItem) {
                    downloadManager.pauseAll();
                  } else {
                    downloadManager.resumeAll();
                  }
                },
                icon: Icon(
                  Icons.file_download,
                  color: Theme.of(context).iconTheme.color,
                ),
                label: Text(hasDownloadingItem ? "全部暂停" : "全部开始")),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: VerticalDivider(width: 0)),
          Expanded(
            child: FlatButton.icon(
                onPressed: () async {
                  if (await showConfirmDialog(context, Text("确定删除全部下载任务吗?"),
                      positiveLabel: "删就完事了")) {
                    downloadManager.deleteAll();
                  }
                },
                icon: Icon(Icons.delete,
                    color: Theme.of(context).iconTheme.color),
                label: Text("清空")),
          )
        ],
      ),
    );
  }
}

class _DownloadingTile extends StatelessWidget {
  const _DownloadingTile({Key key, @required this.download}) : super(key: key);

  final Download<Music> download;

  Widget _buildSecondRow(BuildContext context) {
    switch (download.status) {
      case DownloadStatus.NONE:
      case DownloadStatus.QUEUED:
      case DownloadStatus.ADDED:
        return Text("正在等待下载..");
      case DownloadStatus.DOWNLOADING:
        return Text("正在下载: ${download.progress}%");
      case DownloadStatus.PAUSED:
        return Text("已暂停,点击继续下载");
      case DownloadStatus.COMPLETED:
        return Text("下载已完成");
      case DownloadStatus.CANCELLED:
        return Text("下载已取消");
      case DownloadStatus.FAILED:
        return Text("下载失败,点击重试");
      case DownloadStatus.REMOVED:
      case DownloadStatus.DELETED:
        return Text("下载已被移除");
    }
    return Container();
  }

  void _removeClicked(BuildContext context) async {
    if (await showConfirmDialog(context, Text("确认不再下载吗?"))) {
      bool removeFile = download.status != DownloadStatus.COMPLETED;
      downloadManager.delete([download.id], removeFile: removeFile);
    }
  }

  void _itemClicked() {
    switch (download.status) {
      case DownloadStatus.NONE:
      case DownloadStatus.QUEUED:
      case DownloadStatus.ADDED:
      case DownloadStatus.DOWNLOADING:
        downloadManager.pause([download.id]);
        break;
      case DownloadStatus.FAILED:
        downloadManager.retry([download.id]);
        break;
      case DownloadStatus.PAUSED:
        downloadManager.resume([download.id]);
        break;
      case DownloadStatus.COMPLETED:
      case DownloadStatus.CANCELLED:
      case DownloadStatus.REMOVED:
      case DownloadStatus.DELETED:
        //do nothing
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _itemClicked,
      child: Container(
        height: 56,
        child: Row(
          children: <Widget>[
            SizedBox(width: 8),
            Container(
              child: Icon(
                Icons.album,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Spacer(),
                Text(download.extras.title),
                SizedBox(height: 4),
                DefaultTextStyle(
                    style: Theme.of(context).textTheme.caption,
                    child: _buildSecondRow(context)),
                Spacer(),
              ],
            )),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeClicked(context))
          ],
        ),
      ),
    );
  }
}
