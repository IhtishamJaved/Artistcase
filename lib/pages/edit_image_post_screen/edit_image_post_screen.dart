// ignore_for_file: deprecated_member_use, must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:image/image.dart' as Im;
import 'package:flutter/services.dart' show rootBundle;

import '../../constant/constant.dart';
import '../../controller/variable_controller.dart';
import '../../roots/bottom_navigation_bar.dart';
import '../../widgets/progress.dart';

class EditPostScreen extends StatefulWidget {
  String imageUrl;

  final String postIDs;
  final String mediatype;
  final String caption;

  EditPostScreen({
    Key key,
    @required this.imageUrl,
    @required this.postIDs,
    @required this.caption,
    @required this.mediatype,
  }) : super(key: key);
  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen>
    with AutomaticKeepAliveClientMixin<EditPostScreen> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final variableCOntroller = Get.put(VariableController());
  File imagefile;
  String mediaUrl;
  bool backButtonOn = false;

  DocumentSnapshot snapshot;

  @override
  void initState() {
    getuserdata();
    print(widget.imageUrl);
    getUserLocation();
    print("gdjhshjhgh");
    super.initState();
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  getuserdata() async {
    String uid = firebaseAuth.currentUser.uid;
    snapshot = await firestore.collection("users").doc(uid).get();

    setState(() {
      captionController.text = widget.caption;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(imagefile.readAsBytesSync());
    final compressedImageFile = File('$path/img_${widget.postIDs}.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      imagefile = compressedImageFile;
    });
  }

  uploadCnic(File cnic) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child("post").child(widget.postIDs);
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
        .doc(widget.postIDs)
        .update({
      "postId": widget.postIDs,
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
      variableCOntroller.editpostPisUploading.value = true;
      backButtonOn = true;
    });
    // ignore: unnecessary_statements
    imagefile == null ? null : await compressImage();
    // ignore: unnecessary_statements
    imagefile == null ? null : mediaUrl = await uploadCnic(imagefile);
    createPostInFirestore(
      mediaUrl: imagefile == null ? widget.imageUrl : mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    Get.offAll(() => BottomNavigationTabBar());
    setState(() {
      variableCOntroller.editpostPisUploading.value = false;
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
              onPressed: variableCOntroller.editpostPisUploading.value
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
              () => variableCOntroller.editpostPisUploading.value
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
                        image: imagefile == null
                            ? CachedNetworkImageProvider(widget.imageUrl)
                            : FileImage(imagefile),
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
                  backgroundImage: AssetImage("assets/images/nophoto.jpg")),
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
            Container(
              width: 200.0,
              height: 100.0,
              alignment: Alignment.center,
              child: RaisedButton.icon(
                label: Text(
                  "Select Image",
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.blue,
                onPressed: () {
                  selectImage(context);
                },
                icon: Icon(
                  Icons.camera,
                  color: Colors.white,
                ),
              ),
            ),
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

  getimahefrommon() async {
    try {
      final pickedFile =
          // ignore: invalid_use_of_visible_for_testing_member
          await ImagePicker.platform
              .pickImage(source: ImageSource.camera, imageQuality: 50);

      setState(() {
        if (pickedFile.path == null) {
          imagefile = null;
        } else {
          imagefile = File(pickedFile.path);
        }
      });
      Get.back();
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
        imagefile = File(pickedFile.path);
      });
      Get.back();
    } catch (e) {
      print(e.toString());
    }
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Edit Post"),
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
}
