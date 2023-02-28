import 'dart:typed_data';
import 'package:artistcase/services/Image_storeg_Method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';
import '../constant/utilities.dart';
import '../controller/auth_controller.dart';
import '../models/live_streaming_model.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageStorageMethods _storageMethods = ImageStorageMethods();

  final authcontroller = Get.put(AuthController());

  Future<String> startLiveStream(
      BuildContext context, String title, Uint8List image) async {
    String channelId = '';
    try {
      if (title.isNotEmpty && image != null) {
        DocumentSnapshot userDoc = await firestore
            .collection("users")
            .doc(firebaseAuth.currentUser.uid)
            .get();
        if (!((await _firestore
                .collection('livestream')
                .doc(
                    '${(userDoc.data() as dynamic)["id"]}${(userDoc.data() as dynamic)["username"]}')
                .get())
            .exists)) {
          String thumbnailUrl = await _storageMethods.uploadImageToStorage(
            'livestream-thumbnails',
            image,
            (userDoc.data() as dynamic)["id"],
          );
          channelId =
              '${(userDoc.data() as dynamic)["id"]}${(userDoc.data() as dynamic)["username"]}';

          LiveStreamModel liveStream = LiveStreamModel(
            title: title,
            image: thumbnailUrl,
            uid: (userDoc.data() as dynamic)["id"],
            username: (userDoc.data() as dynamic)["username"],
            viewers: 0,
            channelId: channelId,
            startedAt: DateTime.now(),
          );

          _firestore
              .collection('livestream')
              .doc(channelId)
              .set(liveStream.toMap());
        } else {
          showSnackBar(
              context, 'Two Livestreams cannot start at the same time.');
        }
      } else {
        showSnackBar(context, 'Please enter all the fields');
      }
      authcontroller.liveloader.value = false;
    } on FirebaseException catch (e) {
      authcontroller.liveloader.value = false;

      showSnackBar(context, e.message);
    }
    return channelId;
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    try {
      await _firestore.collection('livestream').doc(id).update({
        'viewers': FieldValue.increment(isIncrease ? 1 : -1),
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> endLiveStream(String channelId) async {
    try {
      await _firestore.collection('livestream').doc(channelId).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
