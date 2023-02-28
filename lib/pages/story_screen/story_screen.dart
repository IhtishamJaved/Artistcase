// ignore_for_file: deprecated_member_use, must_be_immutable, unnecessary_statements

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:image/image.dart' as Im;

import '../../constant/constant.dart';
import '../../controller/variable_controller.dart';
import '../../roots/bottom_navigation_bar.dart';

class StoryScreen extends StatefulWidget {
  File imageFile;

  StoryScreen({
    Key key,
    @required this.imageFile,
  }) : super(key: key);
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with AutomaticKeepAliveClientMixin<StoryScreen> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final variableCOntroller = Get.put(VariableController());
  final String postId = firebaseAuth.currentUser.uid + "iht";

  DocumentSnapshot snapshot;
  bool backButtonOn = false;

  @override
  void initState() {
    getuserdata();
    getUserLocation();
    super.initState();
  }

  getuserdata() async {
    String uid = firebaseAuth.currentUser.uid;
    snapshot = await firestore.collection("users").doc(uid).get();
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(widget.imageFile.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      widget.imageFile = compressedImageFile;
    });
  }

  uploadCnic(File cnic) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child("picstory").child(postId);
    var bytes = await cnic.readAsBytes();
    final UploadTask uploadTask = storageReference.putData(bytes);
    final TaskSnapshot downloadUrl = await uploadTask;
    final String uri = await downloadUrl.ref.getDownloadURL();
    print(uri);
    return uri;
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
                "filetype": "image",
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
                "filetype": "image",
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
    print("hello");
    print(variableCOntroller.picIsUploading.value);
    setState(() {
      variableCOntroller.picIsUploading.value = true;
      backButtonOn = true;
    });
    print(variableCOntroller.picIsUploading.value);
    await compressImage();
    String mediaUrl = await uploadCnic(widget.imageFile);
    createStoryInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    Get.offAll(() => BottomNavigationTabBar());
    setState(() {
      variableCOntroller.picIsUploading.value = false;
    });
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
                backButtonOn
                    ? null
                    : Get.offAll(() => BottomNavigationTabBar());
              }),
          title: Text(
            "Create Story",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            FlatButton(
              onPressed: variableCOntroller.picIsUploading.value
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
            Obx(
              () => variableCOntroller.picIsUploading.value
                  ? linearProgressBar()
                  : Text(""),
            ),
            Container(
              height: 220.0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(widget.imageFile),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/images/nophoto.jpg"),
              ),
              title: Container(
                width: 250.0,
                child: TextField(
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
    try {
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
    } catch (e) {
      print(e.toString());
    }
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildUploadForm();
  }

  Container linearProgressBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.blue[700]),
      ),
    );
  }
}
