# Quiet 
[![CI](https://github.com/boyan01/flutter-netease-music/workflows/CI/badge.svg)](https://github.com/boyan01/flutter-netease-music/actions)
[![codecov](https://codecov.io/gh/boyan01/flutter-netease-music/branch/master/graph/badge.svg)](https://codecov.io/gh/boyan01/flutter-netease-music)


仿[网易云音乐](https://music.163.com/#/download)。 

Imitation of [NeteaseMusic](https://music.163.com/#/download).


## How to start (如何开始)
  1. clone project to local
  ```bash
  git clone https://github.com/boyan01/flutter-netease-music.git 
  git submodule update --init --recursive
  ```
  2. install [Flutter](https://flutter.io/docs/get-started/install)
  
      * require use latest dev channel.
      
  3. build & run
 ```bash
 flutter run --profile
 ```

## Denpendency backend

* Toast and InApp notification： [**overlay_support**](https://github.com/boyan01/overlay_support)
* music play:  [**flutter-music-player**](https://github.com/boyan01/flutter-music-player)
* netease api service: [**NeteaseCloudMusicApi**](https://github.com/ziming1/NeteaseCloudMusicApi)

## 交互效果
| playing                                                      | playlist                                                     | lyric                                               |
| ------------------------------------------------------------ | ------------------------------------------------------------ | --------------------------------------------------- |
| ![playing](https://raw.githubusercontent.com/boyan01/boyan01.github.io/master/quiet/play_interaction.gif) | ![playlist](https://boyan01.github.io/quiet/interation_playlist.gif) | ![lyric](https://boyan01.github.io/quiet/lyric.gif) |
| ![theme](https://boyan01.github.io/quiet/theme_switch.gif)   |                                                              |                                                     |



## 图片预览

| ![main_playlist](https://boyan01.github.io/quiet/main_playlist.png) | ![main_cloud](https://boyan01.github.io/quiet/main_playlist_dark.png) | ![main_cloud](https://boyan01.github.io/quiet/main_cloud.jpg) | ![artist_detail](https://boyan01.github.io/quiet/artist_detail.jpg) |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![playlist_detail](https://boyan01.github.io/quiet/playlist_detail.png) | ![page_comment](https://boyan01.github.io/quiet/page_comment.png) |   ![playing](https://boyan01.github.io/quiet/playing.png)    |    ![search](https://boyan01.github.io/quiet/search.jpg)     |
| ![music_selection](https://boyan01.github.io/quiet/music_selection.png) | ![playlist_selector](https://boyan01.github.io/quiet/playlist_selector.jpg) | ![music video](https://boyan01.github.io/quiet/music_video.png) | ![每日推荐](https://boyan01.github.io/quiet/daily_playlist.png) |
| ![ios](https://boyan01.github.io/quiet/ios_playlist_detail.jpg) |   ![ios](https://boyan01.github.io/quiet/user_detail.png)    |                                                              |                                                              |

