part of 'comments.dart';

class _ItemTitle extends StatelessWidget {
  const _ItemTitle({
    Key? key,
    required this.commentThreadId,
    required this.payload,
  }) : super(key: key);

  final CommentThreadId commentThreadId;

  final CommentThreadPayload? payload;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () async {
            if (commentThreadId.type == CommentType.playlist) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                final playlist = payload!.obj as PlaylistDetail;
                return PlaylistDetailPage(
                  playlist.id,
                  previewData: playlist,
                );
              }));
            } else if (commentThreadId.type == CommentType.song) {
              final Track music = payload!.obj;
              if (context.player.current != music) {
                final dynamic result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text("开始播放 ${music.name} ?"),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("取消")),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text("播放")),
                        ],
                      );
                    });
                if (!(result is bool && result)) {
                  return;
                }
                context.player
                  ..insertToNext(music)
                  ..playFromMediaId(music.id);
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PlayingPage();
              }));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(3)),
                  child: Image(
                    fit: BoxFit.cover,
                    image: CachedImage(payload!.coverImage!),
                    width: 60,
                    height: 60,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 10)),
                SizedBox(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        payload!.title!,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      Text(
                        payload!.subtitle!,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right)
              ],
            ),
          ),
        ),
        Container(height: 7, color: Theme.of(context).dividerColor)
      ],
    );
  }
}

class _ItemLoadMore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
          ),
          Text("正在加载更多评论...")
        ],
      ),
    );
  }
}

class _ItemMoreHot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("go to hot comments");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            "全部精彩评论 >",
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }
}

class _ItemHeader extends StatelessWidget {
  const _ItemHeader({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}

class _ItemComment extends StatefulWidget {
  const _ItemComment({Key? key, required this.comment}) : super(key: key);

  final Comment comment;

  @override
  _ItemCommentState createState() {
    return _ItemCommentState();
  }
}

class _ItemCommentState extends State<_ItemComment> {
  @override
  Widget build(BuildContext context) {
    final user = widget.comment.user;
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    title: const Text("复制"),
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.comment.content));
                      Navigator.pop(context);
                      toast('复制成功');
                    },
                  ),
                  const Divider(height: 0),
                ],
              );
            });
      },
      child: DividerWrapper(
        indent: 60,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ClipOval(
                      child: InkResponse(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailPage(userId: user.userId)));
                    },
                    child: Image(
                      image: CachedImage(user.avatarUrl!),
                      width: 36,
                      height: 36,
                    ),
                  )),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        user.nickname!,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        getFormattedTime(widget.comment.time!),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  )),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.comment.likedCount.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 5)),
                      InkResponse(
                        onTap: () async {
                          //TODO
                        },
                        child: Icon(
                          Icons.thumb_up,
                          size: 15,
                          color: widget.comment.liked!
                              ? context.colorScheme.secondary
                              : Theme.of(context).disabledColor,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(left: 44),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Text(widget.comment.content!, maxLines: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
