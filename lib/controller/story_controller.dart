// ignore_for_file: missing_return

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../constant/constant.dart';

class StoryControllers extends GetxController {
  RxList<Object> images = [].obs;
  File imageFile;

  @override
  void onInit() {
    super.onInit();
    images.add("Add image");
  }

  Future onAddImageClick(int index) async {
    final pickedFile =
        // ignore: invalid_use_of_visible_for_testing_member
        await ImagePicker.platform
            .pickImage(source: ImageSource.gallery, imageQuality: 50);
    imageFile = File(pickedFile.path);
    getFileImage(index);
  }

  void getFileImage(int index) async {
    images.add('Add Image');
    ImageUploadModel imageUpload = new ImageUploadModel();
    imageUpload.imageFile = imageFile;
    imageUpload.imageUrl = '';
    images.replaceRange(index, index + 1, [imageUpload]);
  }

  Future<List> uploadPic(List imageList) async {
    if (imageList != null) {
      List imageUrls = [];
      for (var file in imageList) {
        if (file != null) {
          String imageName = UniqueKey().toString();

          Reference storageReference =
              FirebaseStorage.instance.ref().child("$imageName");
          var bytes = await file.readAsBytes();
          final UploadTask uploadTask = storageReference.putData(bytes);
          final TaskSnapshot downloadUrl = (await uploadTask);
          final String uri = await downloadUrl.ref.getDownloadURL();
          imageUrls.add(uri);
        }
      }
      return imageUrls;
    }
  }

  Future<void> hostelregister() async {
    List pickedImages = [];
    for (int i = 0; i < images.length - 1; i++) {
      ImageUploadModel image = images[i];
      pickedImages.add(image.imageFile);
    }
    await uploadPic(pickedImages).then((value) {
      print(value);

      firestore.collection("ins").doc(currentUserId).collection("story").add({
        "image": value,
      });
    });
  }
}

class ImageUploadModel {
  File imageFile;
  String imageUrl;

  ImageUploadModel({
    this.imageFile,
    this.imageUrl,
  });
}
