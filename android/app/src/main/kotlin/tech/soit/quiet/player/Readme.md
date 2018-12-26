播放需要的功能有

* 上/下一曲
* 播放/暂停
* 获取/改变当前播放中的音乐
* 获取/改变当前音乐列表
* 获取/改变当前音乐播放模式(单曲，顺序,随机)
* 电台模式和普通音乐播放器之间切换

依据上述功能设计的播放器如 `player` 包下可见

`MusicPlayerManager`以 LiveData 来提供获取播放器状态的 API ，是个单例类

`QuietMusicPlayer` 提供API来改变播放器的状态（切换歌曲，暂停...）

# 播放器状态值

 * 状态 (`playing`,`pausing`,`buffering`,`idle`,`complete`,`error`)
 * 错误内容?
 * 缓冲进度

 * 播放列表 (token + 歌曲列表)?
 * 当前播放歌曲?
 * 播放模式 ( single , sequence , shuffle)