/*
 * @Creator: Odd
 * @Date: 2023-01-18 00:45:29
 * @LastEditTime: 2023-01-26 07:57:07
 * @FilePath: \fuzzy_music\lib\services\audio_service.dart
 * @Description: 
 */

import 'package:audioplayers/audioplayers.dart';
import 'package:fuzzy_music/api/lyrics.dart';
import 'package:fuzzy_music/api/playlist_track_all.dart';
import 'package:fuzzy_music/api/song_url.dart';
import 'package:fuzzy_music/models/index.dart';
import 'package:fuzzy_music/models/lyrics.dart';
import 'package:fuzzy_music/models/playlist_detail.dart';
import 'package:fuzzy_music/models/song_url.dart';
import 'package:fuzzy_music/routers/views/playlist/playlist_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlayerState { playing, paused, stopped }

enum PlayerMode { shuffle, sequential, loop }

class AudioService extends GetxController {
  late final AudioPlayer _player;
  static AudioService get to => Get.find();

  AudioState audioState = AudioState(
      currentIndex: -1,
      currentPlayerState: PlayerState.stopped,
      currentMode: PlayerMode.sequential,
      currentVolume: 0.5);

  Future<AudioService> init() async {
    _player = AudioPlayer();

    _player.release();

    // 设置日志级别
    await AudioPlayer.global.changeLogLevel(LogLevel.info);
    // 设置默认音量
    final prefs = await SharedPreferences.getInstance();
    volume(prefs.getDouble('volume') ?? audioState.currentVolume);
    // 监听音乐播放完成后的动作
    _player.onPlayerComplete.listen((event) {
      switch (audioState.currentMode) {
        case PlayerMode.shuffle:
          playNext();
          break;
        case PlayerMode.sequential:
          playNext();
          break;
        case PlayerMode.loop:
          play(audioState.currentIndex);
          break;
      }
    });

    _player.onPositionChanged.listen((to) {
      seek(Duration(microseconds: audioState.currentSong!.dt), to);
    });

    return this;
  }

  playPrevious() async {
    play(audioState.currentIndex - 1);
  }

  playNext() async {
    play(audioState.currentIndex + 1);
  }

  play(int index) async {
    audioState.currentDetail = PlaylistController.to.playlistDetail!;

    // 防止超出范围
    if (index < 0) {
      index = audioState.currentDetail!.playlist.trackCount - 1;
    } else if (index > audioState.currentDetail!.playlist.trackCount - 1) {
      index = 0;
    }
    // 请求对应的歌曲
    PlaylistTrackAll trackAll = await PlaylistTrackAllApi.playlistTrackAll(
      audioState.currentDetail!.playlist.id,
      1,
      audioState.currentMode == PlayerMode.shuffle
          ? audioState.shuffledList![index]
          : index,
    );

    //如果是不同的歌曲就加载歌词并更新状态
    if (index != audioState.currentIndex) {
      // 更新歌曲状态
      audioState.currentSong = trackAll.songs[0];
      audioState.currentIndex = index;

      // 请求歌曲URL
      SongUrl su = await SongUrlApi.songUrlApi(audioState.currentSong!.id);
      await _player.play(UrlSource(su.data[0].url)).then((value) {
        audioState.currentPlayerState = PlayerState.playing;
        update();
      });
      // 加载歌词
      loadingLyrics();
    }
  }

  pause() async {
    await _player.pause().then((v) {
      // curPlayState = PlayerState.paused;
      audioState.currentPlayerState = PlayerState.paused;
      update();
    });
  }

  resume() async {
    await _player.resume().then((value) {
      // curPlayState = PlayerState.playing;
      audioState.currentPlayerState = PlayerState.playing;
      update();
    });
  }

  seek(Duration et, Duration to) async {
    if (const Duration().compareTo(to) <= 0 && et.compareTo(to) >= 0) {
      await _player.seek(to);
    } else {
      printError(info: 'Range Error!');
    }
  }

  volume(double v) async {
    // 默认的音量为1.0（最高）
    await _player.setVolume(v).then((value) async {
      // _curVolume = v;
      audioState.currentVolume = v;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('volume', v);
      update();
    });
  }

  // 播放模式切换
  changeMode(PlayerMode mode) {
    if (audioState.currentMode != mode) {
      audioState.currentMode = mode;
    } else {
      audioState.currentMode = PlayerMode.sequential;
    }
    if (mode == PlayerMode.shuffle) {
      audioState.shuffledList = List.generate(
          audioState.currentDetail!.playlist.trackCount, (v) => v);
      audioState.shuffledList?.shuffle();
    }
    update();
  }

  // 获取歌词
  loadingLyrics() async {
    Lyrics lyrics = await LyricsApi.lyrics(audioState.currentSong?.id ?? 0);
    audioState.lyrics = lyrics.lrc.lyric.split('\n');
    update();
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}

/// 用来存放当前播放的一些信息
class AudioState {
  // 当前播放的状态
  PlayerState currentPlayerState;
  // 当前播放的歌曲
  Song? currentSong;
  // 当前的下标
  int currentIndex;
  // 当前播放的模式
  PlayerMode currentMode;
  // 当前的音量
  double currentVolume;
  // 当前歌单的详细信息
  PlaylistDetail? currentDetail;
  // shuffle的列表
  List<int>? shuffledList;
  // 当前歌词
  List<String> lyrics = ["暂无歌词"];

  AudioState(
      {required this.currentIndex,
      required this.currentPlayerState,
      this.currentSong,
      this.currentDetail,
      required this.currentMode,
      required this.currentVolume});
}
