# Quiet

[![CI](https://github.com/boyan01/flutter-netease-music/workflows/CI/badge.svg)](https://github.com/boyan01/flutter-netease-music/actions)

仿[网易云音乐](https://music.163.com/#/download), 支持全平台。

A Universal copy app of [NeteaseMusic](https://music.163.com/#/download)

## How to start (如何开始)

1. clone project to local

    ```bash
    git clone https://github.com/boyan01/flutter-netease-music.git 
    ```

2. install [Flutter](https://flutter.io/docs/get-started/install)

    * require latest flutter stable channel.

3. build & run

    ```bash
    flutter run --profile
    ```

## Development (开发)

### generate l10n

```shell
flutter pub global activate intl_utils
flutter pub global run intl_utils:generate
```

### Linux requirement.

debian:

   ```shell
   sudo apt install libavcodec-dev libavformat-dev libavdevice-dev
   sudo apt-get install libsdl2-dev
   ```

## Dependency backend

* Toast and InApp notification：
  [**overlay_support**](https://github.com/boyan01/overlay_support)
* music player(mobile):
  [**flutter-music-player**](https://github.com/boyan01/flutter-music-player)
* music player(desktop):
  [**lychee_player**](https://github.com/boyan01/lychee_player)
* netease api service:
  [**NeteaseCloudMusicApi**](https://github.com/ziming1/NeteaseCloudMusicApi)

## Desktop Preview

| light                                                            | dark                                                           |
|------------------------------------------------------------------|----------------------------------------------------------------|
| ![playlist](https://boyan01.github.io/quiet/playlist_light.png ) | ![playlist](https://boyan01.github.io/quiet/playlist_dark.png) |
| ![playing](https://boyan01.github.io/quiet/playing_light.png)    | ![playing](https://boyan01.github.io/quiet/playing_dark.png)   |

## Mobile Dark Mode Preview

| ![main_playlist](https://boyan01.github.io/quiet/mobile_main_playlist.png) | ![playlist detail](https://boyan01.github.io/quiet/mobile_playlist_detail.png) | ![add to playlist](https://boyan01.github.io/quiet/mobile_add_to_playlist.png) | ![artist_detail](https://boyan01.github.io/quiet/mobile_artist_detail.png) |
|:--------------------------------------------------------------------------:|:------------------------------------------------------------------------------:|:------------------------------------------------------------------------------:|:--------------------------------------------------------------------------:|
|  ![album detail](https://boyan01.github.io/quiet/mobile_album_detail.png)  |   ![playing cover](https://boyan01.github.io/quiet/mobile_playing_cover.png)   |   ![playing lyric](https://boyan01.github.io/quiet/mobile_playing_lyric.png)   |        ![search](https://boyan01.github.io/quiet/mobile_search.png)        |
|    ![leaderboard](https://boyan01.github.io/quiet/mobile_leadboard.png)    |         ![setting](https://boyan01.github.io/quiet/mobile_setting.png)         |   ![search result](https://boyan01.github.io/quiet/mobile_search_result.png)   |      ![每日推荐](https://boyan01.github.io/quiet/mobile_playing_list.png)      |
|         ![daily](https://boyan01.github.io/quiet/mobile_daily.png)         |                                                                                |                                                                                |                                                                            |
