import 'dart:async';

import 'package:artistcase/constant/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatRoomController extends GetxController {
  var isShowEmoji = false.obs;
  // ignore: non_constant_identifier_names
  int total_unread = 0;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FocusNode focusNode;
  TextEditingController chatC;
  ScrollController scrollC;
  var userTokens = "".obs;

  // ignore: non_constant_identifier_names
  Stream<QuerySnapshot<Map<String, dynamic>>> streamChats(String chat_id) {
    CollectionReference chats = firestore.collection("chats");

    return chats.doc(chat_id).collection("chat").orderBy("time").snapshots();
  }

  Stream<DocumentSnapshot<Object>> streamFriendData(String friendEmail) {
    CollectionReference users = firestore.collection("users");
//mistake

    return users.doc(friendEmail).snapshots();
  }

  void addEmojiToChat(Emoji emoji) {
    chatC.text = chatC.text + emoji.emoji;
  }

  void deleteEmoji() {
    chatC.text = chatC.text.substring(0, chatC.text.length - 2);
  }

  void newChat(String friendid, String chatiDss, String chat, String id) async {
    if (chat != "") {
      CollectionReference chats = firestore.collection("chats");
      CollectionReference users = firestore.collection("users");

      String date = DateTime.now().toIso8601String();

      // ignore: unnecessary_brace_in_string_interps
      print("rES ${friendid}");
      print(id);

      await chats.doc(chatiDss).collection("chat").add({
        "pengirim": id,
        "penerima": friendid,
        "msg": chat,
        "time": date,
        "isRead": false,
        "groupTime": DateFormat.yMMMMd('en_US').format(DateTime.parse(date)),
      });

      Timer(
        Duration.zero,
        () => scrollC.jumpTo(scrollC.position.maxScrollExtent),
      );

      chatC.clear();

      await users.doc(id).collection("chats").doc(chatiDss).update({
        "lastTime": date,
      });

      final checkChatsFriend =
          await users.doc(friendid).collection("chats").doc(chatiDss).get();

      if (checkChatsFriend.exists) {
        // exist on friend DB
        // first check total unread
        final checkTotalUnread = await chats
            .doc(chatiDss)
            .collection("chat")
            .where("isRead", isEqualTo: false)
            .where("pengirim", isEqualTo: id)
            .get();

        // total unread for friend
        total_unread = checkTotalUnread.docs.length;

        print(total_unread);

        await users.doc(friendid).collection("chats").doc(chatiDss).update({
          "lastTime": date,
          "total_unread": total_unread,
          "lastmsg": chat,
        });
        await users
            .doc(firebaseAuth.currentUser.uid)
            .collection("chats")
            .doc(chatiDss)
            .update({
          "lastTime": date,
          "lastmsg": chat,
          "hello": "Gg",
        });
      } else {
        // not exist on friend DB
        await users.doc(friendid).collection("chats").doc(chatiDss).set({
          "connection": id,
          "lastTime": date,
          "total_unread": 1,
          "lastmsg": chat,
        });
      }
    }
  }

  @override
  void onInit() {
    chatC = TextEditingController();
    scrollC = ScrollController();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isShowEmoji.value = false;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    chatC.dispose();
    scrollC.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
