import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../pages/Upload_post_screen/upload_post_screen.dart';
import '../pages/go_live/go_live_screen.dart';
import '../pages/home_screen/home_screen.dart';
import '../pages/message_screen/message_view/message_view.dart';
import '../pages/music_post_screen/music_post_screen.dart';
import '../pages/search_screen.dart/search_screen.dart';
import '../pages/setting_screen/setting_screen.dart';
import '../pages/video_post_screen/video_post_screen.dart';

User currentUser;

class BottomNavigationTabBar extends StatefulWidget {
  @override
  _BottomNavigationTabBarState createState() => _BottomNavigationTabBarState();
}

class _BottomNavigationTabBarState extends State<BottomNavigationTabBar> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  File file;

  int currentTab = 0;
  File fileForSong;
  String fileSongName;
  String imgPath, songPath, imgURL, songURL;
  final PageStorageBucket bucket = PageStorageBucket();

  final List<Widget> screens = [
    HomeScreen(),
    SearchView(),
    MessageView(),
    SettingScreen(),
  ];
  Widget currentScreen = HomeScreen();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromRGBO(46, 12, 58, 1),
      resizeToAvoidBottomInset: false,
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          _tripEditModalBottomSheet(context);
        },
        child: Container(
          height: 60,
          width: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(134, 100, 244, 1),
                Color.fromRGBO(172, 89, 236, 1),
              ],
            ),
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 20,
        child: Container(
          height: (size.height / 100) * 8,
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: (size.width / 100) * 5,
                    onPressed: () {
                      setState(() {
                        currentScreen = HomeScreen();
                        currentTab = 0;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: (size.width / 100) * 0.8,
                        ),
                        currentTab == 0
                            ? Icon(
                                Icons.home_outlined,
                                size: (size.height / 100) * 4,
                                color: Color.fromRGBO(138, 99, 243, 1),
                              )
                            : Icon(Icons.home_filled,
                                size: (size.height / 100) * 4,
                                color: Color.fromRGBO(26, 26, 26, 0.2)),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: (size.width / 100) * 5,
                    onPressed: () {
                      setState(() {
                        currentScreen = SearchView();
                        currentTab = 1;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        currentTab == 1
                            ? Icon(
                                Icons.search,
                                size: (size.height / 100) * 4,
                                color: Color.fromRGBO(138, 99, 243, 1),
                              )
                            : Icon(
                                Icons.search,
                                size: (size.height / 100) * 4,
                                color: Color.fromRGBO(26, 26, 26, 0.2),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: (size.width / 100) * 28,
                  ),
                  MaterialButton(
                    minWidth: (size.width / 100) * 5,
                    onPressed: () {
                      setState(() {
                        currentScreen = MessageView();
                        currentTab = 2;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        currentTab == 2
                            ? Icon(
                                Icons.chat_bubble_outline,
                                size: (size.height / 100) * 3.7,
                                color: Color.fromRGBO(138, 99, 243, 1),
                              )
                            : Icon(Icons.chat_bubble,
                                size: (size.height / 100) * 3.7,
                                color: Color.fromRGBO(26, 26, 26, 0.2)),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: (size.width / 100) * 5,
                    onPressed: () {
                      setState(() {
                        currentScreen = SettingScreen();
                        currentTab = 3;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        currentTab == 3
                            ? Icon(
                                Icons.settings_outlined,
                                size: (size.height / 100) * 4,
                                color: Color.fromRGBO(138, 99, 243, 1),
                              )
                            : Icon(Icons.settings,
                                size: (size.height / 100) * 4,
                                color: Color.fromRGBO(26, 26, 26, 0.2)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  showOptionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () => () {},
            child: Row(
              children: const [
                Icon(Icons.image),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Gallery',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => () {},
            child: Row(
              children: const [
                Icon(Icons.camera_alt),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Camera',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              children: const [
                Icon(Icons.cancel),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _tripEditModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        builder: (BuildContext bc) {
          final size = MediaQuery.of(context).size;
          return Container(
            height: (size.height / 100) * 35,
            width: size.width / 100,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 25),
                  child: Row(
                    children: [
                      Text("create",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(46, 12, 58, 1))),
                      SizedBox(
                        width: (size.width / 100) * 63,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          'images/cancle.png',
                          height: (size.height / 100) * 3,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => GoLiveScreen());
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              CircleAvatar(
                                  backgroundColor:
                                      Color.fromRGBO(139, 98, 243, 0.1),
                                  radius: 17,
                                  child: Icon(Icons.stream,
                                      color: Color.fromRGBO(137, 99, 243, 1))),
                              SizedBox(
                                width: (size.width / 100) * 3,
                              ),
                              Text(
                                'Go Live',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(46, 12, 58, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: (size.height / 100) * 3,
                      ),
                      GestureDetector(
                        onTap: () => selectImage(context),
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Color.fromRGBO(139, 98, 243, 0.1),
                                radius: 17,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Color.fromRGBO(137, 99, 243, 1),
                                ),
                              ),
                              SizedBox(
                                width: (size.width / 100) * 3,
                              ),
                              Text(
                                'Upload Photos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(46, 12, 58, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: (size.height / 100) * 3,
                      ),
                      GestureDetector(
                        onTap: () => selectVideo(context),
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              CircleAvatar(
                                  backgroundColor:
                                      Color.fromRGBO(139, 98, 243, 0.1),
                                  radius: 17,
                                  child: Icon(Icons.image_outlined,
                                      color: Color.fromRGBO(137, 99, 243, 1))),
                              SizedBox(
                                width: (size.width / 100) * 3,
                              ),
                              Text('Upload Video',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(46, 12, 58, 1))),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: (size.height / 100) * 3,
                      ),
                      GestureDetector(
                        onTap: () => onSongSelected(),
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              CircleAvatar(
                                  backgroundColor:
                                      Color.fromRGBO(139, 98, 243, 0.1),
                                  radius: 17,
                                  child: Icon(Icons.music_video_outlined,
                                      color: Color.fromRGBO(137, 99, 243, 1))),
                              SizedBox(
                                width: (size.width / 100) * 3,
                              ),
                              Text('Upload Music',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(46, 12, 58, 1))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  getimahefrommon() async {
    try {
      final pickedFile =
          // ignore: invalid_use_of_visible_for_testing_member
          await ImagePicker.platform
              .pickImage(source: ImageSource.camera, imageQuality: 50);

      setState(() {
        if (pickedFile.path == null) {
          file = null;
        } else {
          file = File(pickedFile.path);
        }
      });

      if (file == null) {
        print("pathnull");
        Get.back();
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UploadPostScreen(
              imageFile: file,
            ),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getImageFromGallery() async {
    try {
      final pickedFile =
          // ignore: invalid_use_of_visible_for_testing_member
          await ImagePicker.platform
              .pickImage(source: ImageSource.gallery, imageQuality: 50);
      setState(() {
        file = File(pickedFile.path);
      });

      if (file == null) {
        print("pathnull");
        Get.back();
      } else {
        Get.back();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UploadPostScreen(
              imageFile: file,
            ),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: getimahefrommon),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: getImageFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  pickVideo(ImageSource src, BuildContext context) async {
    try {
      final video = await ImagePicker().pickVideo(source: src);

      if (video.path == null) {
        print("pathnull");
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideosPostScreen(
              videoFile: File(video.path),
              videoPath: video.path,
            ),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  selectVideo(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Video with Camera"),
                onPressed: () => pickVideo(ImageSource.camera, context)),
            SimpleDialogOption(
              child: Text("Video from Gallery"),
              onPressed: () => pickVideo(ImageSource.gallery, context),
            ),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Future onSongSelected() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null) return;

    final path = result.files.single.path;
    setState(() {
      fileForSong = File(path);
      songPath = path;
    });
    if (songPath == null) {
      print("sgg");
    } else {
      Get.to(
        () => MusicPostScreen(musicFile: fileForSong, musicPath: songPath),
      );
    }
  }
}
