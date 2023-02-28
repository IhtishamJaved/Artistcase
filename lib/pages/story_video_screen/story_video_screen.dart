// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../constant/constant.dart';
import '../../controller/variable_controller.dart';
import '../../roots/bottom_navigation_bar.dart';
import '../../widgets/progress.dart';

class StoryVideosScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  StoryVideosScreen({
    Key key,
    @required this.videoFile,
    @required this.videoPath,
  }) : super(key: key);
  @override
  _StoryVideosScreenState createState() => _StoryVideosScreenState();
}

class _StoryVideosScreenState extends State<StoryVideosScreen>
    with AutomaticKeepAliveClientMixin<StoryVideosScreen> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  final String postId = firebaseAuth.currentUser.uid + "iht";
  DocumentSnapshot snapshot;
  bool backButtonOn = false;
  final variableCOntroller = Get.put(VariableController());

  String userPhoto;
  VideoPlayerController controller;

  @override
  void initState() {
    getuserdata();
    getUserLocation();
    super.initState();
    setState(() {
      controller = VideoPlayerController.file(widget.videoFile);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);
    controller.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  getuserdata() async {
    String uid = firebaseAuth.currentUser.uid;
    snapshot = await firestore.collection("users").doc(uid).get();
    setState(() {
      userPhoto = (snapshot.data() as Map<String, dynamic>)["photoUrl"];
    });
  }

  _compressvideo(String videoPAth) async {
    final compressvideo = await VideoCompress.compressVideo(
      videoPAth,
      quality: VideoQuality.MediumQuality,
    );
    return compressvideo.file;
  }

  Future<String> _uploadvideotofirebase(String videoPath) async {
    Reference reference =
        firebaseStorage.ref().child("Videostory").child(postId);

    UploadTask uploadTask = reference.putFile(await _compressvideo(videoPath));

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  createStoryInFirestore(
      {String mediaUrl, String location, String description}) async {
    print(firebaseAuth.currentUser.uid);
    var a = await firestore
        .collection('story')
        .doc(firebaseAuth.currentUser.uid)
        .collection("userstory")
        .doc(postId)
        .get();

    print(a);

    try {
      if (a.exists) {
        firestore
            .collection("story")
            .doc(firebaseAuth.currentUser.uid)
            .collection("userstory")
            .doc(postId)
            .update(
          {
            "displayName":
                (snapshot.data() as Map<String, dynamic>)["username"],
            "avatarUrl": (snapshot.data() as Map<String, dynamic>)["photoUrl"],
            "ownerId": firebaseAuth.currentUser.uid,
            "timeStamp": DateTime.now(),
            "file": FieldValue.arrayUnion([
              {
                "caption": description,
                "mediaUrl": "$mediaUrl",
                "postId": "$postId",
                "filetype": "video",
              },
            ]),
          },
        );
        return a;
      } else if (!a.exists) {
        firestore
            .collection("story")
            .doc(firebaseAuth.currentUser.uid)
            .collection("userstory")
            .doc(postId)
            .set(
          {
            "displayName":
                (snapshot.data() as Map<String, dynamic>)["username"],
            "avatarUrl": (snapshot.data() as Map<String, dynamic>)["photoUrl"],
            "ownerId": firebaseAuth.currentUser.uid,
            "timeStamp": DateTime.now(),
            "file": [
              {
                "caption": description,
                "mediaUrl": "$mediaUrl",
                "postId": "$postId",
                "filetype": "video",
              },
            ]
          },
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  handleSubmit() async {
    setState(() {
      variableCOntroller.isUpload.value = true;
      backButtonOn = true;
    });

    String mediaUrl = await _uploadvideotofirebase(widget.videoPath);
    createStoryInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      variableCOntroller.isUpload.value = false;
    });
    Get.offAll(() => BottomNavigationTabBar());
  }

  buildUploadForm() {
    return WillPopScope(
      onWillPop: () {
        var activw = backButtonOn ? false : true;
        print("hgfgh");
        return Future.value(activw);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white70,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                // ignore: unnecessary_statements
                backButtonOn
                    // ignore: unnecessary_statements
                    ? null
                    : Get.offAll(() => BottomNavigationTabBar());
              }),
          title: Text(
            "Create Story",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            FlatButton(
              onPressed: variableCOntroller.isUpload.value
                  ? null
                  : () => handleSubmit(),
              child: Text(
                "Share",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Obx(() => variableCOntroller.isUpload.value
                ? linearProgress()
                : Text("")),
            Container(
              height: 220.0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: userPhoto == null
                    ? AssetImage("assets/images/nophoto.jpg")
                    : CachedNetworkImageProvider(userPhoto),
              ),
              title: Container(
                width: 250.0,
                child: TextFormField(
                  controller: captionController,
                  decoration: InputDecoration(
                    hintText: "Write a caption...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    setState(() {
      locationController.text = formattedAddress;
    });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildUploadForm();
  }
}
