/*
 * @Creator: Odd
 * @Date: 2023-01-07 00:10:43
 * @LastEditTime: 2023-01-18 02:20:00
 * @FilePath: \fuzzy_music\lib\routers\views\bottom_player_bar.dart
 * @Description: 
 */
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluent_ui/fluent_ui.dart' as fui;
import 'package:fuzzy_music/services/audio_service.dart';
import 'package:get/get.dart';

class BottomPlayerBar extends StatelessWidget {
  const BottomPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;

    return BottomAppBar(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: (mediaQuerySize.width - 240 * 5) / 2 + 20),
        height: 88,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            AlbumStateWidget(),
            PlayerStateWidget(),
            PlayerControllerWidget()
          ],
        ),
      ),
    );
  }
}

class AlbumStateWidget extends StatelessWidget {
  const AlbumStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioService>(builder: (_) {
      return Container(
        width: 300,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  height: 66,
                  width: 66,
                  color: Colors.blue,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_.curSong?.name ?? '你还没播放歌曲',
                    style: Theme.of(context).textTheme.subtitle1),
                SizedBox(
                  height: 8,
                ),
                Text(
                    _.curSong?.ar
                            .map((e) => e.name.removeAllWhitespace)
                            .join('/') ??
                        '未知艺术家',
                    style: Theme.of(context).textTheme.subtitle2),
              ],
            )
          ],
        ),
      );
    });
  }
}

class PlayerStateWidget extends StatelessWidget {
  const PlayerStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioService>(
      builder: (_) {
        return Container(
          child: Row(
            children: [
              fui.IconButton(
                icon: Icon(
                  // CupertinoIcons.backward_end_fill,
                  Icons.skip_previous_rounded,
                  size: 32,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: null,
              ),
              fui.IconButton(
                icon: _.curPlayState == PlayState.playing
                    ? Icon(
                        // CupertinoIcons.play_arrow_solid,
                        Icons.pause_rounded,
                        size: 50,
                        color: Theme.of(context).iconTheme.color,
                      )
                    : Icon(
                        // CupertinoIcons.play_arrow_solid,
                        Icons.play_arrow_rounded,
                        size: 50,
                        color: Theme.of(context).iconTheme.color,
                      ),
                onPressed: _.curPlayState == PlayState.stopped
                    ? null
                    : () {
                        if (_.curPlayState == PlayState.playing) {
                          _.pause();
                        } else if (_.curPlayState == PlayState.paused) {
                          _.resume();
                        }
                      },
              ),
              fui.IconButton(
                icon: Icon(
                  Icons.skip_next_rounded,
                  size: 32,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class PlayerControllerWidget extends StatelessWidget {
  const PlayerControllerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioService>(builder: (_) {
      buildVolumeBtn() {
        if (_.curVolume > 0.75 && _.curVolume <= 1.0) {
          return CupertinoIcons.volume_up;
        } else if (_.curVolume < 0.75 && _.curVolume > 0) {
          return CupertinoIcons.volume_down;
        } else {
          return CupertinoIcons.volume_off;
        }
      }

      return Container(
        child: Row(
          children: [
            fui.IconButton(
              // icon: Icon(CupertinoIcons.pause_fill),
              icon: Icon(
                CupertinoIcons.music_note_list,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => {},
            ),
            SizedBox(
              width: 10,
            ),
            fui.IconButton(
              // icon: Icon(CupertinoIcons.pause_fill),
              icon: Icon(
                CupertinoIcons.repeat_1,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => {},
            ),
            SizedBox(
              width: 10,
            ),
            fui.IconButton(
              // icon: Icon(CupertinoIcons.pause_fill),
              icon: Icon(
                CupertinoIcons.shuffle,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => {},
            ),
            SizedBox(
              width: 10,
            ),
            fui.IconButton(
              // icon: Icon(CupertinoIcons.pause_fill),
              icon: Icon(
                buildVolumeBtn(),
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                if (_.curVolume != 0) {
                  _.volume(0);
                }else {
                  _.volume(0.5);
                }
              },
            ),
            SizedBox(
              width: 10,
            ),
            fui.Slider(
              max: 1,
              value: _.curVolume,
              onChanged: (value) => _.volume(value),
            ),
            SizedBox(
              width: 10,
            ),
            fui.IconButton(
              // icon: Icon(CupertinoIcons.pause_fill),
              icon: Icon(
                CupertinoIcons.chevron_up,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => {},
            ),
          ],
        ),
      );
    });
  }
}
