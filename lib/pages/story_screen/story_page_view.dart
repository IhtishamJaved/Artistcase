import 'package:flutter/material.dart';

import '../../models/story_model.dart';
import '../../widgets/story_widget.dart';

class StoryPage extends StatefulWidget {
  final int lenghts;
  final StoryModel storyModel;

  const StoryPage({
    @required this.storyModel,
    @required this.lenghts,
    Key key,
  }) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  PageController controller;

  @override
  void initState() {
    super.initState();

    final initialPage = widget.lenghts;
    controller = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      PageView(controller: controller, children: [
        StoryWidget(
          storyModel: widget.storyModel,
          controller: controller,
          leg: widget.lenghts,
        )
      ]);
}
