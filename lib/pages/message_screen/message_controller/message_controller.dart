import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../chat_room/chat_room_view.dart';

class MessageController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> chatsStream(String email) {
    return firestore
        .collection('users')
        .doc(email)
        .collection("chats")
        .orderBy("lastTime", descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> friendStream(String email) {
    return firestore.collection('users').doc(email).snapshots();
  }

  void goToChatRoom(
      // ignore: non_constant_identifier_names
      String chat_id, String email, String friendEmail, String id) async {
    CollectionReference chats = firestore.collection('chats');
    CollectionReference users = firestore.collection('users');

    final updateStatusChat = await chats
        .doc(chat_id)
        .collection("chat")
        .where("isRead", isEqualTo: false)
        .where("penerima", isEqualTo: email)
        .get();

    updateStatusChat.docs.forEach((element) async {
      await chats
          .doc(chat_id)
          .collection("chat")
          .doc(element.id)
          .update({"isRead": true});
    });

    await users
        .doc(id)
        .collection("chats")
        .doc(chat_id)
        .update({"total_unread": 0});

    Get.to(
      () => ChatRoomView(chatId: chat_id, friendEmail: friendEmail),
    );

    // Get.toNamed(
    //   Routes.CHAT_ROOM,
    //   arguments: {
    //     "chat_id": chat_id,
    //     "friendEmail": friendEmail,
    //   },
    // );
  }
}
