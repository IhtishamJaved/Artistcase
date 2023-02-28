// ignore_for_file: deprecated_member_use, must_be_immutable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

import '../../constant/constant.dart';
import '../../controller/variable_controller.dart';
import '../../roots/bottom_navigation_bar.dart';
import '../../widgets/progress.dart';

class UploadPostScreen extends StatefulWidget {
   File imageFile;

  UploadPostScreen({
    Key key,
    @required this.imageFile,
  }) : super(key: key);
  @override
  _UploadPostScreenState createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen>
    with AutomaticKeepAliveClientMixin<UploadPostScreen> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final variableCOntroller = Get.put(VariableController());
  String postId = Uuid().v4();
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
        FirebaseStorage.instance.ref().child("post").child(postId);
    var bytes = await cnic.readAsBytes();
    final UploadTask uploadTask = storageReference.putData(bytes);
    final TaskSnapshot downloadUrl = await uploadTask;
    final String uri = await downloadUrl.ref.getDownloadURL();
    print(uri);
    return uri;
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
      "Urltype": "image",
    });
  }

  handleSubmit() async {
    setState(() {
      variableCOntroller.postPisUploading.value = true;
      backButtonOn = true;
    });
    await compressImage();
    String mediaUrl = await uploadCnic(widget.imageFile);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    Get.offAll(() => BottomNavigationTabBar());
    setState(() {
      variableCOntroller.postPisUploading.value = false;
      postId = Uuid().v4();
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
              onPressed: variableCOntroller.postPisUploading.value
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
              () => variableCOntroller.postPisUploading.value
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
}
