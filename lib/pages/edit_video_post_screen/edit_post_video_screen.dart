// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../constant/constant.dart';
import '../../controller/variable_controller.dart';
import '../../roots/bottom_navigation_bar.dart';
import '../../widgets/progress.dart';

class EditVideosPostScreen extends StatefulWidget {
  final String videoPath;
  final String postIDss;
  final String caption;
  EditVideosPostScreen({
    Key key,
    @required this.videoPath,
    @required this.postIDss,
    @required this.caption,
  }) : super(key: key);
  @override
  _EditVideosPostScreenState createState() => _EditVideosPostScreenState();
}

class _EditVideosPostScreenState extends State<EditVideosPostScreen>
    with AutomaticKeepAliveClientMixin<EditVideosPostScreen> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  final variableCOntroller = Get.put(VariableController());

  DocumentSnapshot snapshot;

  String userPhoto;
  VideoPlayerController controller;
  File videofile;
  String newVIdeoPath;
  String mediaUrl;
  bool backButtonOn = false;

  @override
  void initState() {
    getuserdata();
    getUserLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    // ignore: unnecessary_statements
    videofile == null ? null : controller.dispose();
  }

  getuserdata() async {
    String uid = firebaseAuth.currentUser.uid;
    snapshot = await firestore.collection("users").doc(uid).get();
    setState(() {
      userPhoto = (snapshot.data() as Map<String, dynamic>)["photoUrl"];
      captionController.text = widget.caption;
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
        firebaseStorage.ref().child("post").child(widget.postIDss);

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
        .doc(widget.postIDss)
        .update({
      "postId": widget.postIDss,
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
      variableCOntroller.editpostVideoUploading.value = true;
      backButtonOn = true;
    });

    videofile == null
        // ignore: unnecessary_statements
        ? null
        : mediaUrl = await _uploadvideotofirebase(newVIdeoPath);
    createPostInFirestore(
      mediaUrl: videofile == null ? widget.videoPath : mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      variableCOntroller.editpostVideoUploading.value = false;
    });
    Get.offAll(() => BottomNavigationTabBar());
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // ignore: unnecessary_statements
              backButtonOn ? null : Get.offAll(() => BottomNavigationTabBar());
            }),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            onPressed: variableCOntroller.editpostVideoUploading.value
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
      body: ListView(
        children: <Widget>[
          Obx(
            () => variableCOntroller.editpostVideoUploading.value
                ? linearProgress()
                : Text(""),
          ),
          videofile == null
              ? SvgPicture.asset('assets/images/upload.svg', height: 260.0)
              : Container(
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
          GestureDetector(
            onTap: () {
              showOptionsDialogssss(context);
            },
            child: Container(
              width: 200.0,
              height: 100.0,
              alignment: Alignment.center,
              child: RaisedButton.icon(
                label: Text(
                  "Select Video",
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.blue,
                onPressed: () {
                  showOptionsDialogssss(context);
                },
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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

  pickVideo(ImageSource src, BuildContext context) async {
    try {
      final video = await ImagePicker().pickVideo(source: src);

      if (video.path == null) {
        print("pathnull");
      } else {
        setState(() {
          videofile = File(video.path);
          newVIdeoPath = video.path;

          setState(() {
            controller = VideoPlayerController.file(videofile);
          });
          controller.initialize();
          controller.play();
          controller.setVolume(1);
          controller.setLooping(true);
        });
      }
      Get.back();
    } catch (e) {
      print(e.toString());
    }
  }

  showOptionsDialogssss(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () => pickVideo(ImageSource.gallery, context),
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
            onPressed: () => pickVideo(ImageSource.camera, context),
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
}
