import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  void saveNotificationTofirebase(String capacity, String usertoken,
      String requestfor, BuildContext context) async {
    FirebaseFirestore.instance.collection("collector_notification").add({
      "capacity": capacity,
      "usertoken": usertoken,
      "requestfor": requestfor,
    });
  }
}
