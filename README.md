# Quiet 
[![Build Status](https://travis-ci.com/boyan01/flutter-netease-music.svg?branch=master)](https://travis-ci.com/boyan01/flutter-netease-music)
[![codecov](https://codecov.io/gh/boyan01/flutter-netease-music/branch/master/graph/badge.svg)](https://codecov.io/gh/boyan01/flutter-netease-music)

仿网易云音乐。点颗**star**，为完成此项目添加动力。

netease music player. working in progress！

---

**运行项目需要API提供支持，需在本地或者远程搭建此API服务 [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi) 
同时在设置中修改对应的 host**

---

**因无iOS设备，故平台化代码只写Android部分，欢迎PR**

**For personal reasons(have not iOS devices), the platformized code will only write the Android part**


# How to start

 * install [Flutter](https://flutter.io/docs/get-started/install)
 * run in Command Line
 ```
 flutter run --profile
 ```

**NOTE**, this project used api not in stable version. so require **master channel**.[switch flutter channel](https://flutter.dev/docs/development/tools/sdk/upgrading#switching-flutter-channels).

# 基本组件依赖

* 页面加载：[**loader**](https://github.com/boyan01/loader)
* Toast及应用内通知： [**overlay_support**](https://github.com/boyan01/overlay_support)

# interaction
| playing | playlist  | ios |
|------|------|------|
|<img src="./_preview/playing_Interaction.gif" width="200">| <img src="https://boyan01.github.io/quiet/interation_playlist.gif" width="200"> |   <img src="https://boyan01.github.io/quiet/ios_playlist_detail.jpg" width="200"> |


# Preview

| ![main_playlist](https://boyan01.github.io/quiet/main_playlist.png) |        ![main_cloud](./_preview/main_cloud.jpg)        | ![playlist_detail](https://boyan01.github.io/quiet/playlist_detail.png) |        ![artist_detail](./_preview/artist_detail.jpg)        |
| :----------------------------------------------------------: | :----------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|         ![page_comment](./_preview/page_comment.jpg)         |           ![playing](./_preview/playing.jpg)           |               ![search](./_preview/search.jpg)               |        ![search_result](./_preview/search_result.jpg)        |
|      ![music_selection](./_preview/music_selection.jpg)      | ![playlist_selector](./_preview/playlist_selector.jpg) | ![music video](https://boyan01.github.io/quiet/music_video.png) | ![每日推荐](https://boyan01.github.io/quiet/daily_playlist.png) |


