// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../constant/sizeconfig.dart';

class VideoPlayerItems extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItems({Key key, @required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerItems> createState() => _VideoPlayerItemsState();
}

class _VideoPlayerItemsState extends State<VideoPlayerItems> {
  VideoPlayerController videoPlayerController;

  bool iconsss = false;
  Future<void> futureController;

  @override
  void initState() {
    super.initState();

    videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    futureController = videoPlayerController.initialize();
    videoPlayerController.setLooping(true);
    videoPlayerController.setVolume(25);
    // ..initialize().then((value) {
    //   videoPlayerController.setVolume(1);
    // });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        FutureBuilder(
          future: futureController,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (videoPlayerController.value.isPlaying) {
                      videoPlayerController.pause();
                    } else {
                      videoPlayerController.play();
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 4 * SizeConfig.widthMultiplier),
                  height: size.height * 0.27,
                  width: size.width * 0.90,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: VideoPlayer(videoPlayerController),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Container(
                height: size.height * 0.27,
                width: size.width * 0.90,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 10 * SizeConfig.heightMultiplier),
          child: Center(
            child: RaisedButton(
              onPressed: () {
                setState(() {
                  if (videoPlayerController.value.isPlaying) {
                    videoPlayerController.pause();
                  } else {
                    videoPlayerController.play();
                  }
                });
              },
              child: Icon(
                videoPlayerController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
          ),
        )
      ],
    );
  }
}
