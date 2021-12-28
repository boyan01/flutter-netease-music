# Quiet

[![CI](https://github.com/boyan01/flutter-netease-music/workflows/CI/badge.svg)](https://github.com/boyan01/flutter-netease-music/actions)
[![codecov](https://codecov.io/gh/boyan01/flutter-netease-music/branch/master/graph/badge.svg)](https://codecov.io/gh/boyan01/flutter-netease-music)

仿[网易云音乐](https://music.163.com/#/download), 支持全平台。

A Universal copy app of [NeteaseMusic](https://music.163.com/#/download)

## How to start (如何开始)

1. clone project to local

  ```bash
  git clone https://github.com/boyan01/flutter-netease-music.git 
  ```

2. install [Flutter](https://flutter.io/docs/get-started/install)

    * require latest flutter master channel.

3. build & run

 ```bash
 flutter run --profile
 ```

### Linux requirement.

debian:

   ```shell
   sudo apt-get install vlc
   sudo apt-get install libvlc-dev
   ```

## Dependency backend

* Toast and InApp notification：
  [**overlay_support**](https://github.com/boyan01/overlay_support)
* music player(mobile):
  [**flutter-music-player**](https://github.com/boyan01/flutter-music-player)
* music player(desktop):
  [**dart_vlc**](https://github.com/alexmercerind/dart_vlc)
* netease api service:
  [**NeteaseCloudMusicApi**](https://github.com/ziming1/NeteaseCloudMusicApi)

## Desktop Preview

| light                                                           | dark                                                           |
|-----------------------------------------------------------------|----------------------------------------------------------------|
| ![playlist](https://boyan01.github.io/quiet/playlist_light.png) | ![playlist](https://boyan01.github.io/quiet/playlist_dark.png) |
| ![playing](https://boyan01.github.io/quiet/playing_light.png)   | ![playing](https://boyan01.github.io/quiet/playing_dark.png)   |

## Mobile Platforms Preview

|   ![main_playlist](https://boyan01.github.io/quiet/main_playlist.png)   |    ![main_cloud](https://boyan01.github.io/quiet/main_playlist_dark.png)    | ![main_cloud](https://boyan01.github.io/quiet/main_cloud.jpg) | ![artist_detail](https://boyan01.github.io/quiet/artist_detail.jpg) |
|:-----------------------------------------------------------------------:|:---------------------------------------------------------------------------:|:-------------------------------------------------------------:|:-------------------------------------------------------------------:|
| ![playlist_detail](https://boyan01.github.io/quiet/playlist_detail.png) |                                                                             |    ![playing](https://boyan01.github.io/quiet/playing.png)    |        ![search](https://boyan01.github.io/quiet/search.jpg)        |
| ![music_selection](https://boyan01.github.io/quiet/music_selection.png) | ![playlist_selector](https://boyan01.github.io/quiet/playlist_selector.jpg) |                                                               |     ![每日推荐](https://boyan01.github.io/quiet/daily_playlist.png)     |
|     ![ios](https://boyan01.github.io/quiet/ios_playlist_detail.jpg)     |           ![ios](https://boyan01.github.io/quiet/user_detail.png)           |                                                               |                                                                     |

