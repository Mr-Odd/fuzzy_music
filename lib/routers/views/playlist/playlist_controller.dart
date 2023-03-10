/*
 * @Creator: Odd
 * @Date: 2023-01-15 22:42:13
 * @LastEditTime: 2023-01-24 04:59:35
 * @FilePath: \fuzzy_music\lib\routers\views\playlist\playlist_controller.dart
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:fuzzy_music/api/playlist_detail.dart';
import 'package:fuzzy_music/api/playlist_track_all.dart';
import 'package:fuzzy_music/models/index.dart';
import 'package:fuzzy_music/models/playlist_detail.dart';
import 'package:fuzzy_music/models/top_album.dart';
import 'package:fuzzy_music/routers/views/recommendation/recommend_controller.dart';
import 'package:get/get.dart';

class PlaylistController extends GetxController {
  final int currentPlaylistId;

  PlaylistController({required this.currentPlaylistId});
  static PlaylistController get to => Get.find();

  ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;
  set scrollController(s) => _scrollController = s;

  PlaylistDetail? _playlistDetail;
  PlaylistDetail? get playlistDetail => _playlistDetail;
  set playlistDetail(p) => _playlistDetail = p;

  PlaylistTrackAll _playlistTracks =
      PlaylistTrackAll(songs: <Song>[], privileges: [], code: 0);

  PlaylistTrackAll get playlistTracks => _playlistTracks;
  set playlistTracks(p) => _playlistTracks = p;

  @override
  void onInit() {
    _initPlaylistData();
    super.onInit();
  }

  // 初始化歌单歌曲数据
  _initPlaylistData() async {
    final PlaylistDetail pd =
        await PlaylistDetailaApi.playlistDetail(currentPlaylistId);
    playlistDetail = pd;
    final p = await PlaylistTrackAllApi.playlistTrackAll(currentPlaylistId);
    playlistTracks = p;
    update();
  }

  // 歌曲分页数据
  retrieveTracksData({int limit = 10, required int offset}) async {
    final PlaylistTrackAll p = await PlaylistTrackAllApi.playlistTrackAll(
        currentPlaylistId, limit, offset);
    playlistTracks.songs.addAll(p.songs);
    update();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
