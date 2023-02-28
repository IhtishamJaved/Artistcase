// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:uuid/uuid.dart';

import '../../constant/constant.dart';
import '../../controller/variable_controller.dart';
import '../../roots/bottom_navigation_bar.dart';
import '../../widgets/progress.dart';

// ignore: must_be_immutable
class MusicPostScreen extends StatefulWidget {
  File musicFile;
  String musicPath;
  MusicPostScreen({
    Key key,
    @required this.musicFile,
    @required this.musicPath,
  }) : super(key: key);
  @override
  _MusicPostScreenState createState() => _MusicPostScreenState();
}

class _MusicPostScreenState extends State<MusicPostScreen>
    with AutomaticKeepAliveClientMixin<MusicPostScreen> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  final variableCOntroller = Get.put(VariableController());
  String postId = Uuid().v4();
  DocumentSnapshot snapshot;

  String userPhoto;
  bool playing = false;
  IconData btnIcon = Icons.play_arrow;
  String currentSong = "";

  AudioPlayer _audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  bool isPlaying = false;
  Duration musicDuration = Duration();
  Duration musicPosition = Duration();
  bool backButtonOn = false;

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
  void dispose() {
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  void initState() {
    getuserdata();
    getUserLocation();

    super.initState();
  }

  getuserdata() async {
    String uid = firebaseAuth.currentUser.uid;
    snapshot = await firestore.collection("users").doc(uid).get();
    setState(() {
      userPhoto = (snapshot.data() as Map<String, dynamic>)["photoUrl"];
    });
  }

  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    _audioPlayer.seek(newPos);
  }

  Future<String> _uploadvideotofirebase(File videoPath) async {
    Reference reference = firebaseStorage.ref().child("post").child(postId);
    var bytes = await videoPath.readAsBytes();
    final UploadTask uploadTask = reference.putData(bytes);

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
      "description": description,
      "deviceToken": (snapshot.data() as Map<String, dynamic>)["token"],
      "location": locationController.text,
      "timestamp": DateTime.now(),
      "userPhoto": (snapshot.data() as Map<String, dynamic>)["photoUrl"],
      "likes": [],
      "commentCount": 0,
      "Urltype": "music",
    });
  }

  handleSubmit() async {
    setState(() {
      variableCOntroller.postMusicUploading.value = true;
      backButtonOn = true;
    });

    String mediaUrl = await _uploadvideotofirebase(widget.musicFile);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      variableCOntroller.postMusicUploading.value = false;
      postId = Uuid().v4();
    });
    // ignore: unnecessary_statements
    widget.musicFile == null;
    widget.musicPath = null;

    Get.offAll(() => BottomNavigationTabBar());
  }

  buildUploadForm() {
    return WillPopScope(
      onWillPop: () {
        var activw = backButtonOn ? false : true;

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
              onPressed: variableCOntroller.postMusicUploading.value
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
              () => variableCOntroller.postMusicUploading.value
                  ? linearProgress()
                  : Text(""),
            ),
            Container(
              width: 500.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${musicPosition.inMinutes}:${musicPosition.inSeconds.remainder(60)}",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Slider.adaptive(
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    value: musicPosition.inSeconds.toDouble(),
                    max: musicDuration.inSeconds.toDouble(),
                    onChanged: (value) {
                      seekToSec(value.toInt());
                    },
                  ),
                  Text(
                    "${musicDuration.inMinutes}:${musicDuration.inSeconds.remainder(60)}",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w200,
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 45.0,
                  color: Colors.blue,
                  onPressed: () {},
                  icon: Icon(
                    Icons.skip_previous,
                  ),
                ),
                IconButton(
                  iconSize: 62.0,
                  color: Colors.blue[800],
                  onPressed: () {
                    playMusic(widget.musicPath);
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
                  icon: Icon(
                    btnIcon,
                  ),
                ),
                IconButton(
                  iconSize: 45.0,
                  color: Colors.blue,
                  onPressed: () {},
                  icon: Icon(
                    Icons.skip_next,
                  ),
                ),
              ],
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
