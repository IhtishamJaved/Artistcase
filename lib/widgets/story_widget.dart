import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:story_view/story_view.dart';

import '../models/story_model.dart';

class StoryWidget extends StatefulWidget {
  final StoryModel storyModel;
  final PageController controller;
  final int leg;

  const StoryWidget({
    @required this.storyModel,
    @required this.leg,
    @required this.controller,
  });

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  final storyItems = <StoryItem>[];
  StoryController controller;
  String date = '';

  void addStoryItems() {
    for (final story in widget.storyModel.file) {
      switch (story.filetype) {
        case "image":
          storyItems.add(
            StoryItem.pageImage(
              url: story.mediaUrl,
              controller: controller,
              caption: story.caption,
              duration: Duration(
                milliseconds: (6000).toInt(),
              ),
            ),
          );
          break;
        case "text":
          storyItems.add(
            StoryItem.text(
              title: story.caption,
              backgroundColor: Colors.green,
              duration: Duration(
                milliseconds: (1000).toInt(),
              ),
            ),
          );

          break;
        case "video":
          storyItems.add(
            StoryItem.pageVideo(
              story.mediaUrl,
              controller: controller,
              caption: story.caption,
              duration: Duration(
                milliseconds: (6000).toInt(),
              ),
            ),
          );
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    controller = StoryController();
    addStoryItems();
    // date = widget.storyModel.file[0];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleCompleted() {
    widget.controller.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );

    final currentIndex = 0;
    final isLastPage = widget.storyModel.file.length - 1 == currentIndex;

    if (isLastPage) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Material(
            type: MaterialType.transparency,
            child: StoryView(
              storyItems: storyItems,
              controller: controller,
              onComplete: handleCompleted,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              onStoryShow: (storyItem) {
                final index = storyItems.indexOf(storyItem);

                if (index > 0) {
                  setState(() {
                    //  date = widget.storyModel.file[index].date;
                  });
                }
              },
            ),
          ),
          // ProfileWidget(
          //   user: widget.user,
          //   date: date,
          // ),
        ],
      );
}
