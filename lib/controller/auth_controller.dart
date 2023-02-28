// ignore_for_file: unnecessary_cast, non_constant_identifier_names

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import '../auth/facebook_login_screen/facebook_login_screen.dart';
import '../constant/constant.dart';
import '../models/users_second_model.dart';
import '../pages/chat_room/chat_room_view.dart';
import '../roots/bottom_navigation_bar.dart';

class AuthController extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  var currentUserUid;
  var user = UsersModel().obs;
  var showincorrectEmail = false.obs;
  var showincorrectpassword = false.obs;
  var liveloader = false.obs;

  ///Sign Up error Variable
  var weekpassword = false.obs;
  var alreadyemail = false.obs;

  //
  var showsigUp = false.obs;
  var signinshow = false.obs;
  var updateData = false.obs;
  var showMessage = false.obs;
  var usertoken = "";

  ///facebook Login /////
  var facebookBool = false.obs;
  var profileupdate = false.obs;

  ////Passworde Rset variable///
  ///

  TextEditingController resetcontroller = TextEditingController();
  var resetshow = false.obs;

  Future<String> uploadImageToStorage(
      String childName, var file, String uid) async {
    Reference ref = _storage.ref().child(childName).child(uid);
    var bytes = await file.readAsBytes();
    UploadTask uploadTask = ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpg',
      ),
    );

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // register user
  void registeruser(String username, String email, String password,
      String phone, var image) async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await firebaseAuth
          // ignore: missing_return
          .createUserWithEmailAndPassword(email: email, password: password)
          // ignore: missing_return
          .then((value) async {
        String thumbnailUrl = await uploadImageToStorage(
          'profilePhoto',
          image,
          value.user.uid,
        );
        currentUserUid = value.user.uid;

        usertoken = await FirebaseMessaging.instance.getToken();

        await usersRef.doc(value.user.uid).set({
          "id": value.user.uid,
          "token": usertoken,
          "username": username.toLowerCase(),
          "keyName": username.substring(0, 1).toUpperCase(),
          "email": email,
          "photoUrl": thumbnailUrl,
          "status": "",
          "phonenumber": phone,
          "password": password,
          "timeStamp": timestamp,
          "type": "email",
          "updatedTime": DateTime.now().toIso8601String(),
        });

        await followersRef
            .doc(value.user.uid)
            .collection('userFollowers')
            .doc(value.user.uid)
            .set({
          "id": value.user.uid,
          "token": usertoken,
          "username": username.toLowerCase(),
          "photoUrl": thumbnailUrl,
        });

        final currUser = await usersRef.doc(value.user.uid).get();
        final currUserData = currUser.data() as Map<String, dynamic>;
        user(UsersModel.fromJson(currUserData));

        user.refresh();

        final listChats =
            await usersRef.doc(value.user.uid).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
              chatId: dataDocChatId,
              connection: dataDocChat["connection"],
              lastTime: dataDocChat["lastTime"],
              total_unread: dataDocChat["total_unread"],
            ));
          });

          user.update((user) {
            user.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user.chats = [];
          });
        }

        user.refresh();
      });

      Get.offAll(() => BottomNavigationTabBar());
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        weekpassword.value = false;

        //  Get.snackbar("Weak Password", "too short");
      } else if (e.code == "email-already-in-use") {
        alreadyemail.value = true;
        //   Get.snackbar("Email is already ", "use by other user");
      } else if (e.code == "email-address-badly-formatted") {
        print("badly forma");
        print(e.toString());
      }
      showsigUp.value = false;
    } catch (e) {
      showsigUp.value = false;

      print(e.toString());
    }
  }

  updateUserData(
      String name, String email, String password, String phonenumber) async {
    try {
      await firestore
          .collection("users")
          .doc(firebaseAuth.currentUser.uid)
          .update({
        "email": email,
        "phonenumber": phonenumber,
        "username": name,
        "password": password,
      });
      changePassword(password);

      // changeEmail(email);
      profileupdate.value = false;

      Get.snackbar("User Data  Updated", "Login Again");
    } catch (e) {
      profileupdate.value = false;
      print(e.toString());
    }
  }

  changePassword(String password) async {
    try {
      await firebaseAuth.currentUser.updatePassword(password);
    } catch (e) {
      print(e.toString());
    }
  }

  void loginUser(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      Get.offAll(() => BottomNavigationTabBar());
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        showincorrectEmail.value = true;
      } else if (e.code == "wrong-password") {
        showincorrectpassword.value = true;
      }
      signinshow.value = false;
    } catch (e) {
      print(e.toString());
    }
  }

  void addNewConnection(
    String friendEmail,
    String id,
  ) async {
    try {
      print(id);
      bool flagNewConnection = false;
      var chat_id;
      String date = DateTime.now().toIso8601String();
      CollectionReference chats = firestore.collection("chats");
      CollectionReference users = firestore.collection("users");

      final docChats = await users
          .doc(firebaseAuth.currentUser.uid)
          .collection("chats")
          .get();

      if (docChats.docs.length != 0) {
        final checkConnection = await users
            .doc(firebaseAuth.currentUser.uid)
            .collection("chats")
            .where("connection", isEqualTo: id)
            .get();

        if (checkConnection.docs.length != 0) {
          flagNewConnection = false;

          chat_id = checkConnection.docs[0].id;
        } else {
          flagNewConnection = true;
        }
      } else {
        flagNewConnection = true;
      }

      if (flagNewConnection) {
        final chatsDocs = await chats.where(
          "connections",
          whereIn: [
            [
              firebaseAuth.currentUser.email,
              friendEmail,
            ],
            [
              friendEmail,
              firebaseAuth.currentUser.email,
            ],
          ],
        ).get();

        if (chatsDocs.docs.length != 0) {
          final chatDataId = chatsDocs.docs[0].id;
          final chatsData = chatsDocs.docs[0].data() as Map<String, dynamic>;

          await users
              .doc(firebaseAuth.currentUser.uid)
              .collection("chats")
              .doc(chatDataId)
              .set({
            "connection": id,
            "lastTime": chatsData["lastTime"],
            "total_unread": 0,
            "lastmsg": "no message",
          });

          final listChats = await users
              .doc(firebaseAuth.currentUser.uid)
              .collection("chats")
              .get();

          if (listChats.docs.length != 0) {
            List<ChatUser> dataListChats = List<ChatUser>.empty();
            listChats.docs.forEach((element) {
              var dataDocChat = element.data();
              var dataDocChatId = element.id;
              dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat["total_unread"],
              ));
            });
            user.update((user) {
              user.chats = dataListChats;
            });
          } else {
            user.update((user) {
              user.chats = [];
            });
          }

          chat_id = chatDataId;

          user.refresh();
        } else {
          final newChatDoc = await chats.add({
            "connections": [
              firebaseAuth.currentUser.email,
              friendEmail,
            ],
          });

          // ignore: await_only_futures
          await chats.doc(newChatDoc.id).collection("chat");

          await users
              .doc(firebaseAuth.currentUser.uid)
              .collection("chats")
              .doc(newChatDoc.id)
              .set({
            "connection": id,
            "lastTime": date,
            "total_unread": 0,
            "lastmsg": "no message",
          });

          final listChats = await users
              .doc(firebaseAuth.currentUser.uid)
              .collection("chats")
              .get();

          if (listChats.docs.length != 0) {
            List<ChatUser> dataListChats = List<ChatUser>.empty();
            listChats.docs.forEach((element) {
              var dataDocChat = element.data();
              var dataDocChatId = element.id;
              dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat["total_unread"],
              ));
            });
            user.update((user) {
              user.chats = dataListChats;
            });
          } else {
            user.update((user) {
              user.chats = [];
            });
          }

          chat_id = newChatDoc.id;

          user.refresh();
        }
      }

      print(chat_id);

      final updateStatusChat = await chats
          .doc(chat_id)
          .collection("chat")
          .where("isRead", isEqualTo: false)
          .where("penerima", isEqualTo: firebaseAuth.currentUser.uid)
          .get();

      updateStatusChat.docs.forEach((element) async {
        await chats
            .doc(chat_id)
            .collection("chat")
            .doc(element.id)
            .update({"isRead": true});
      });

      await users
          .doc(firebaseAuth.currentUser.uid)
          .collection("chats")
          .doc(chat_id)
          .update({"total_unread": 0});

      print(chat_id);
      print(id);

      Get.to(() => ChatRoomView(chatId: chat_id, friendEmail: id));
      showMessage.value = false;
    } catch (e) {
      showMessage.value = false;
      print(e.toString());
    }
  }

  void signout() async {
    showincorrectEmail.value = false;
    showincorrectpassword.value = false;

    ///Sign Up error Variable
    weekpassword.value = false;
    alreadyemail.value = false;
    facebookBool.value = false;

    showsigUp.value = false;
    signinshow.value = false;
    await firebaseAuth.signOut();
    Get.offAll(() => FaceBookLogInScreen());
  }

////////////////////////////////////////////////// FAcebook LogIn////////////////
  void signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance
          .login(permissions: (['email', 'public_profile']));
      final token = result.accessToken.token;
      print('Facebook token userID : ${result.accessToken.grantedPermissions}');
      final graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/'
          // ignore: unnecessary_brace_in_string_interps
          'v2.12/me?fields=name,first_name,last_name,email&access_token=${token}'));

      final profile = jsonDecode(graphResponse.body);
      print("Profile is equal to $profile");

      final AuthCredential facebookCredential =
          FacebookAuthProvider.credential(result.accessToken.token);

      final userData = await FacebookAuth.i.getUserData();
      print(userData);
      usertoken = await FirebaseMessaging.instance.getToken();

      // ignore: unused_local_variable
      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookCredential)
          .then((value) async {
        await usersRef.doc(value.user.uid).set({
          "id": value.user.uid,
          "username": userData["name"].toLowerCase(),
          "token": usertoken,
          "email": userData["email"],
          "keyName": userData["name"].substring(0, 1).toUpperCase(),
          "photoUrl": userData["picture"]["data"]["url"],
          "status": "",
          "phonenumber": "345678",
          "password": "hgfd",
          "timeStamp": timestamp,
          "type": "facebook",
          "updatedTime": DateTime.now().toIso8601String(),
        });

        await followersRef
            .doc(value.user.uid)
            .collection('userFollowers')
            .doc(value.user.uid)
            .set({
          "photoUrl": userData["picture"]["data"]["url"],
          "timeStamp": timestamp,
          "id": value.user.uid,
          "username": userData["name"].toLowerCase(),
        });

        final currUser = await usersRef.doc(value.user.uid).get();
        final currUserData = currUser.data() as Map<String, dynamic>;
        user(UsersModel.fromJson(currUserData));

        user.refresh();

        final listChats =
            await usersRef.doc(value.user.uid).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
              chatId: dataDocChatId,
              connection: dataDocChat["connection"],
              lastTime: dataDocChat["lastTime"],
              total_unread: dataDocChat["total_unread"],
            ));
          });

          user.update((user) {
            user.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user.chats = [];
          });
        }

        user.refresh();
      });

      Get.offAll(() => BottomNavigationTabBar());
    } catch (e) {
      print("error occurred");
      facebookBool.value = false;
      Get.snackbar("Error", e.toString());
      print(e.toString());
    }
  }

  Future resetpassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: resetcontroller.text.trim());
      Get.snackbar("FOGET PASSWORD LINK", "HAS SEND TO YOUR EMAIL");
      resetcontroller.clear();

      resetshow.value = false;
    } catch (e) {
      Get.snackbar("Inviald Email ", e.toString());
      resetshow.value = false;
    }
  }
}
