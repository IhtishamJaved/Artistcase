import 'dart:async';
import 'dart:io';

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_keyhash/flutter_facebook_keyhash.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constant/constant.dart';
import '../../constant/sizeconfig.dart';
import '../../controller/auth_controller.dart';
import '../../controller/home_controller.dart';
import '../../models/story_model.dart';

import '../Profile_screen/profile_screen.dart';
import '../story_screen/story_page_view.dart';
import '../story_screen/story_screen.dart';
import '../story_video_screen/story_video_screen.dart';
import 'component/all_component.dart';
import 'component/music_component.dart';
import 'component/video_compoent.dart';

class HomeScreen extends StatefulWidget {
  // const home({ Key? key }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLiked;
  int likecount = 128;
  DocumentSnapshot snapshot;

  Map likes;
  File file;
  int likeCount;
  String username;
  String userId;
  String userPhoto;

  final authcontroller = Get.put(AuthController());
  final homecontroller = Get.put(HomeController());

  @override
  void initState() {
    getuserdata();
    printKeyHash();
    super.initState();
  }

  void printKeyHash() async {
    String key = await FlutterFacebookKeyhash.getFaceBookKeyHash ??
        'Unknown platform version';
    print(key ?? "");
  }

  Future getuserdata() async {
    try {
      String uid = firebaseAuth.currentUser.uid;
      snapshot = await firestore.collection("users").doc(uid).get();
      print(snapshot);
      setState(() {
        userPhoto = (snapshot.data() as Map<String, dynamic>)["photoUrl"];
        username = (snapshot.data() as Map<String, dynamic>)["username"];
        print(userPhoto);
      });
      print((snapshot.data() as Map<String, dynamic>)["usertoken"]);
      print((snapshot.data() as Map<String, dynamic>)["photoUrl"]);
    } catch (e) {
      print(e.toString());
    }
  }

  DateTime yesterdayDate = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  DateTime tomorrow = DateTime.utc(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, DateTime.now().hour + 1);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(46, 12, 58, 1),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: (size.height / 100) * 5.4),
            Row(
              children: [
                Container(
                  width: (size.width / 100) * 70,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 4 * SizeConfig.widthMultiplier,
                      ),
                      Text(
                        'Hey ',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(216, 213, 213, 1),
                        ),
                      ),
                      Text(
                        username ?? "",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(216, 213, 213, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: (size.width / 100) * 10),
                InkWell(
                  onTap: () {
                    Get.to(
                      () => ProfileScreen(
                          profileId: firebaseAuth.currentUser.uid),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Color.fromRGBO(166, 91, 238, 1),
                    radius: 26,
                    child: CircleAvatar(
                      radius: 23,
                      backgroundImage: userPhoto == null
                          ? AssetImage("assets/images/nophoto.jpg")
                          : NetworkImage(userPhoto),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: (size.height / 100) * 3,
            ),
            Container(
              height: 15 * SizeConfig.heightMultiplier,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => selectImage(context),
                      child: Column(
                        children: [
                          Container(
                            height: 12 * SizeConfig.heightMultiplier,
                            width: 25 * SizeConfig.widthMultiplier,
                            margin: EdgeInsets.only(
                                left: 2 * SizeConfig.widthMultiplier),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border:
                                    Border.all(color: Colors.grey, width: 3),
                                image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/nophoto.jpg"),
                                  fit: BoxFit.cover,
                                ),
                                color: Colors.black),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 10 * SizeConfig.widthMultiplier,
                                  top: 8 * SizeConfig.heightMultiplier),
                              child: Icon(
                                Icons.add_box,
                                color: Color.fromRGBO(46, 12, 58, 1),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 5, left: 2.5 * SizeConfig.widthMultiplier),
                            child: Text(
                              "Your Story",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(255, 255, 255, 0.6),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 16 * SizeConfig.heightMultiplier,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection("Storytimeline")
                            .doc(firebaseAuth.currentUser.uid)
                            .collection("timelineStory")
                            .where('timeStamp',
                                isGreaterThanOrEqualTo: yesterdayDate)
                            .where('timeStamp', isLessThanOrEqualTo: tomorrow)
                            //S  .orderBy('timeStamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          print(yesterdayDate);
                          print(tomorrow);
                          print(snapshot);
                          print("dgfhgf");
                          if (snapshot.hasData) {
                            var lenght = snapshot.data.docs.length;

                            print(lenght);
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                QuerySnapshot snap = snapshot.data;
                                List<StoryModel> storyPosts = snap.docs
                                    .map((doc) => StoryModel.fromDocument(doc))
                                    .toList();
                                print(storyPosts);

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        GestureDetector(
                                          child: Container(
                                            height: 12 *
                                                SizeConfig.heightMultiplier,
                                            width:
                                                25 * SizeConfig.widthMultiplier,
                                            margin: EdgeInsets.only(
                                                left: 2 *
                                                    SizeConfig.widthMultiplier),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(28),
                                                border: Border.all(
                                                    color: Color.fromRGBO(
                                                        166, 91, 238, 1),
                                                    width: 3),
                                                image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                    snapshot.data.docs[index]
                                                        ["avatarUrl"],
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                                color: Colors.grey),
                                          ),
                                          onTap: () {
                                            Get.to(
                                              () => StoryPage(
                                                storyModel: storyPosts[index],
                                                lenghts: lenght,
                                              ),
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              left: 2 *
                                                  SizeConfig.widthMultiplier),
                                          child: Text(
                                            snapshot.data.docs[index]
                                                ["displayName"],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w400,
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.6),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: (size.height / 100) * 4),

            //tab bar

            SizedBox(height: (size.height / 100) * 2),

            Padding(
              padding: EdgeInsets.only(left: 4 * SizeConfig.widthMultiplier),
              child: ButtonsTabBar(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromRGBO(169, 90, 237, 1),
                      Color.fromRGBO(134, 100, 244, 1),
                    ],
                  ),
                ),
                unselectedBackgroundColor: Color.fromRGBO(77, 12, 103, 1),
                labelStyle: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                radius: 15,
                tabs: [
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      width: (size.width / 100) * 26,
                      height: (size.height / 100) * 4,
                      child: Text(
                        "All",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      width: (size.width / 100) * 26,
                      height: (size.height / 100) * 4.4,
                      child: Text(
                        "Videos",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      width: (size.width / 100) * 26,
                      height: (size.height / 100) * 4.4,
                      child: Text(
                        "Music",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AllComponent(),
                  VideoComponent(),
                  MusicComponent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
            builder: (context) => StoryScreen(
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
            builder: (context) => StoryScreen(
              imageFile: file,
            ),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  pickVideo(ImageSource src, BuildContext context) async {
    try {
      final video = await ImagePicker().pickVideo(source: src);

      if (video.path == null) {
        print("pathnull");
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StoryVideosScreen(
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

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Story"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: getimahefrommon),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: getImageFromGallery),
            SimpleDialogOption(
              child: Text("Video with Camera"),
              onPressed: () => pickVideo(ImageSource.camera, context),
            ),
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
}
