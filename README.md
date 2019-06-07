# Quiet 
[![Build Status](https://travis-ci.com/boyan01/flutter-netease-music.svg?branch=master)](https://travis-ci.com/boyan01/flutter-netease-music)
[![codecov](https://codecov.io/gh/boyan01/flutter-netease-music/branch/master/graph/badge.svg)](https://codecov.io/gh/boyan01/flutter-netease-music)

仿网易云音乐。 

---

**因无iOS设备，故平台化代码暂只写Android部分，欢迎PR。**

**For personal reasons(have not iOS devices), the platformized code will only write the Android part. PULL REQUESTS are welcome**


## How to start

  1. install [Flutter](https://flutter.io/docs/get-started/install)
  2. check flutter branch to **dev**, ([how to switch flutter channel](https://flutter.dev/docs/development/tools/sdk/upgrading#switching-flutter-channels))
  3. run in Command Line
 ```bash
 flutter run --profile
 ```

## 基本组件依赖

* 页面加载：[**loader**](https://github.com/boyan01/loader)
* Toast及应用内通知： [**overlay_support**](https://github.com/boyan01/overlay_support)

## 交互效果
| playing | playlist  | ios |
|------|------|------|
|<img src="./_preview/playing_Interaction.gif" width="200">| <img src="https://boyan01.github.io/quiet/interation_playlist.gif" width="200"> |   <img src="https://boyan01.github.io/quiet/ios_playlist_detail.jpg" width="200"> |


## 图片预览

| ![main_playlist](https://boyan01.github.io/quiet/main_playlist.png) |        ![main_cloud](./_preview/main_cloud.jpg)        | ![playlist_detail](https://boyan01.github.io/quiet/playlist_detail.png) |        ![artist_detail](./_preview/artist_detail.jpg)        |
| :----------------------------------------------------------: | :----------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|         ![page_comment](./_preview/page_comment.jpg)         |           ![playing](./_preview/playing.jpg)           |               ![search](./_preview/search.jpg)               |        ![search_result](./_preview/search_result.jpg)        |
|      ![music_selection](./_preview/music_selection.jpg)      | ![playlist_selector](./_preview/playlist_selector.jpg) | ![music video](https://boyan01.github.io/quiet/music_video.png) | ![每日推荐](https://boyan01.github.io/quiet/daily_playlist.png) |


