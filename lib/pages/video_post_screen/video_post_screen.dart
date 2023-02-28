// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../constant/constant.dart';
import '../../controller/variable_controller.dart';
import '../../roots/bottom_navigation_bar.dart';
import '../../widgets/progress.dart';

class VideosPostScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  VideosPostScreen({
    Key key,
    @required this.videoFile,
    @required this.videoPath,
  }) : super(key: key);
  @override
  _VideosPostScreenState createState() => _VideosPostScreenState();
}

class _VideosPostScreenState extends State<VideosPostScreen>
    with AutomaticKeepAliveClientMixin<VideosPostScreen> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  final variableCOntroller = Get.put(VariableController());
  String postId = Uuid().v4();
  DocumentSnapshot snapshot;
  bool backButtonOn = false;

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
    Reference reference = firebaseStorage.ref().child("post").child(postId);

    UploadTask uploadTask = reference.putFile(await _compressvideo(videoPath));

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .doc(firebaseAuth.currentUser.uid)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": firebaseAuth.currentUser.uid,
      "username": (snapshot.data() as Map<String, dynamic>)["username"],
      "mediaUrl": mediaUrl,
      "deviceToken": (snapshot.data() as Map<String, dynamic>)["token"],
      "description": description,
      "location": locationController.text,
      "timestamp": DateTime.now(),
      "userPhoto": (snapshot.data() as Map<String, dynamic>)["photoUrl"],
      "likes": [],
      "commentCount": 0,
      "Urltype": "video",
    });
  }

  handleSubmit() async {
    setState(() {
      variableCOntroller.postVideoUploading.value = true;
      backButtonOn = true;
    });

    String mediaUrl = await _uploadvideotofirebase(widget.videoPath);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      variableCOntroller.postVideoUploading.value = false;
      postId = Uuid().v4();
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
            "Caption Post",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            FlatButton(
              onPressed: variableCOntroller.postVideoUploading.value
                  ? null
                  : () => handleSubmit(),
              child: Text(
                "Post",
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
            Obx(
              () => variableCOntroller.postVideoUploading.value
                  ? linearProgress()
                  : Text(""),
            ),
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
