import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../constant/sizeconfig.dart';

class MusicPlayerItem extends StatefulWidget {
  final String musicUrl;
  MusicPlayerItem({Key key, @required this.musicUrl}) : super(key: key);

  @override
  State<MusicPlayerItem> createState() => _MusicPlayerItemState();
}

class _MusicPlayerItemState extends State<MusicPlayerItem> {
  bool playing = false;
  IconData btnIcon = Icons.play_arrow;

  String currentSong = "";

  AudioPlayer _audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

  bool isPlaying = false;

  Duration musicDuration = Duration();

  Duration musicPosition = Duration();

  playMusic(String url) async {
    if (isPlaying && currentSong != url) {
      _audioPlayer.pause();
      int result = await _audioPlayer.play(url);
      if (result == 1) {
        setState(() {
          currentSong = url;
        });
      }
    } else if (!isPlaying) {
      int result = await _audioPlayer.play(url);
      if (result == 1) {
        setState(() {
          isPlaying = true;
          btnIcon = Icons.pause;
        });
      }
    }

    _audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        musicDuration = event;
      });
    });

    _audioPlayer.onAudioPositionChanged.listen((event) {
      setState(() {
        musicPosition = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
        width: (size.width / 100) * 90,
        height: (size.height / 100) * 14,
        margin: EdgeInsets.only(
            top: 1 * SizeConfig.heightMultiplier,
            bottom: 1 * SizeConfig.heightMultiplier),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.5)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 18),
              child: Row(
                children: [
                  SizedBox(width: (size.width / 100) * 2),
                  Image.asset("images/album_cover1.png"),
                  SizedBox(width: (size.width / 100) * 2),
                  Column(
                    children: [
                      Text(
                        'Awake',
                        style: TextStyle(
                            fontFamily: 'Proxima Nova',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                      SizedBox(height: (size.height / 100) * 0.5),
                      Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Text(
                          'Tycho',
                          style: TextStyle(
                              fontFamily: 'Proxima Nova',
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(255, 255, 255, 1)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: (size.width / 100) * 26),
                  GestureDetector(
                    onTap: () {
                      playMusic(widget.musicUrl);
                      if (isPlaying) {
                        _audioPlayer.pause();
                        setState(() {
                          btnIcon = Icons.play_arrow;
                          isPlaying = false;
                        });
                      } else {
                        _audioPlayer.resume();

                        setState(() {
                          btnIcon = Icons.pause;
                          isPlaying = true;
                        });
                      }
                    },
                    child: Icon(
                      btnIcon,
                      color: Color.fromRGBO(
                        150,
                        95,
                        241,
                        1,
                      ),
                      size: (size.height / 100) * 7,
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
