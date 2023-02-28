import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProfileVideoPlayerItems extends StatefulWidget {
  final String videoUrl;
  const ProfileVideoPlayerItems({Key key, @required this.videoUrl})
      : super(key: key);

  @override
  State<ProfileVideoPlayerItems> createState() =>
      _ProfileVideoPlayerItemsState();
}

class _ProfileVideoPlayerItemsState extends State<ProfileVideoPlayerItems> {
  VideoPlayerController videoPlayerController;

  bool iconsss = false;

  @override
  void initState() {
    super.initState();

    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        videoPlayerController.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.3,
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
    );
  }
}
