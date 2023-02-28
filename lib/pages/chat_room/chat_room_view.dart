// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:artistcase/pages/chat_room/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../constant/constant.dart';
import '../../controller/notification_controller.dart';
import 'package:http/http.dart' as http;

class ChatRoomView extends StatefulWidget {
  final String chatId;
  final String friendEmail;

  ChatRoomView({
    Key key,
    @required this.chatId,
    @required this.friendEmail,
  }) : super(key: key);

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  //final authC = Get.find<AuthController>();
  final controller = Get.put(ChatRoomController());

  AndroidNotificationChannel channel;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final notificationController = Get.put(NotificationController());

  String tokens;
  String userName;
  DocumentSnapshot snapshot;

  @override
  void initState() {
    loadFCM();
    listenFCM();
    requestPermission();
    getUserData();
    getuserProfileData();
    super.initState();
  }

  getUserData() async {
    snapshot = await firestore
        .collection("users")
        .doc(firebaseAuth.currentUser.uid)
        .get();
    setState(() {
      userName = (snapshot.data() as Map<String, dynamic>)["username"];
    });
  }

  getuserProfileData() async {
    snapshot =
        await firestore.collection("users").doc(widget.friendEmail).get();
    setState(() {
      tokens = (snapshot.data() as Map<String, dynamic>)["token"];
    });

    print(tokens);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(46, 12, 58, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(46, 12, 58, 1),
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 5),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                child: StreamBuilder<DocumentSnapshot<Object>>(
                  stream: controller.streamFriendData(widget.friendEmail),
                  builder: (context, snapFriendUser) {
                    if (snapFriendUser.connectionState ==
                        ConnectionState.active) {
                      var dataFriend =
                          snapFriendUser.data.data() as Map<String, dynamic>;
                      print(dataFriend["token"]);
                      dataFriend["token"] = tokens;

                      controller.userTokens.value = dataFriend["token"];

                      print(controller.userTokens.value);

                      if (dataFriend["photoUrl"] == null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/nophoto.jpg",
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            dataFriend["photoUrl"],
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/images/nophoto.jpg",
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        title: StreamBuilder<DocumentSnapshot<Object>>(
          stream: controller.streamFriendData(widget.friendEmail),
          builder: (context, snapFriendUser) {
            if (snapFriendUser.connectionState == ConnectionState.active) {
              var dataFriend =
                  snapFriendUser.data.data() as Map<String, dynamic>;
              // dataFriend["token"] = userTokn;
              print(dataFriend["token"]);
              dataFriend["token"] = tokens;

              controller.userTokens.value = dataFriend["token"];

              print(controller.userTokens.value);

              print("hello");
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataFriend["username"],
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    dataFriend["status"],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
      ),
      body: WillPopScope(
        onWillPop: () {
          if (controller.isShowEmoji.isTrue) {
            controller.isShowEmoji.value = false;
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.streamChats(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      var alldata = snapshot.data.docs;
                      Timer(
                        Duration.zero,
                        () => controller.scrollC.jumpTo(
                            controller.scrollC.position.maxScrollExtent),
                      );
                      return ListView.builder(
                        controller: controller.scrollC,
                        itemCount: alldata.length,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  "${alldata[index]["groupTime"]}",
                                  style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.6),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                ItemChat(
                                  msg: "${alldata[index]["msg"]}",
                                  isSender: alldata[index]["pengirim"] ==
                                          firebaseAuth.currentUser.uid
                                      ? true
                                      : false,
                                  time: "${alldata[index]["time"]}",
                                ),
                              ],
                            );
                          } else {
                            print(alldata[index]["pengirim"]);
                            print(firebaseAuth.currentUser.uid);
                            if (alldata[index]["groupTime"] ==
                                alldata[index - 1]["groupTime"]) {
                              return ItemChat(
                                msg: "${alldata[index]["msg"]}",
                                isSender: alldata[index]["pengirim"] ==
                                        firebaseAuth.currentUser.uid
                                    ? true
                                    : false,
                                time: "${alldata[index]["time"]}",
                              );
                            } else {
                              print(alldata[index]["pengirim"]);
                              print(firebaseAuth.currentUser.uid);
                              return Column(
                                children: [
                                  Text(
                                    "${alldata[index]["groupTime"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ItemChat(
                                    msg: "${alldata[index]["msg"]}",
                                    isSender: alldata[index]["pengirim"] ==
                                            firebaseAuth.currentUser.uid
                                        ? true
                                        : false,
                                    time: "${alldata[index]["time"]}",
                                  ),
                                ],
                              );
                            }
                          }
                        },
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                //  height: (size.height/100)*10, width: (size.width/100)*70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Color.fromRGBO(77, 12, 103, 1)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: [
                      Expanded(
                        //  height: (size.height/100)*10, width: (size.width/100)*70,
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 5,
                          autocorrect: false,
                          controller: controller.chatC,
                          focusNode: controller.focusNode,
                          onEditingComplete: () {
                            sendPushMessage(
                              tokens,
                              userName,
                              controller.chatC.text,
                            );

                            controller.newChat(
                              widget.friendEmail,
                              widget.chatId,
                              controller.chatC.text,
                              firebaseAuth.currentUser.uid,
                            );
                          },
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              onPressed: () {
                                controller.focusNode.unfocus();
                                controller.isShowEmoji.toggle();
                              },
                              icon: Icon(
                                Icons.emoji_emotions_outlined,
                                color: Color.fromRGBO(150, 95, 240, 1),
                                size: (size.height / 100) * 4.5,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(25),
                            filled: true,
                            fillColor: Color.fromRGBO(77, 12, 103, 1),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                26.0,
                              ),
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(77, 12, 103, 1),
                                  width: 1.3),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                26.0,
                              ),
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(77, 12, 103, 1),
                                  width: 1.3),
                            ),
                            hintText: 'Type a message here',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(
                                255,
                                255,
                                255,
                                0.6,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            color: Color.fromRGBO(
                              255,
                              255,
                              255,
                              1,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          sendPushMessage(
                            tokens,
                            userName,
                            controller.chatC.text,
                          );
                          controller.newChat(
                            widget.friendEmail,
                            widget.chatId,
                            controller.chatC.text,
                            firebaseAuth.currentUser.uid,
                          );
                        },
                        child: CircleAvatar(
                            backgroundColor: Color.fromRGBO(143, 97, 242, 1),
                            child: Icon(Icons.send)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(14),
            //       color: Color.fromRGBO(77, 12, 103, 1)),

            //   //  EdgeInsets.only(
            //   //   bottom: controller.isShowEmoji.isTrue
            //   //       ? 5
            //   //       : context.mediaQueryPadding.bottom,
            //   // ),
            //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //   width: 600,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Expanded(
            //         child: TextField(
            //           autocorrect: false,
            //           controller: controller.chatC,
            //           focusNode: controller.focusNode,
            //           onEditingComplete: () {
            //             controller.newChat(
            //               friendEmail,
            //               chatId,
            //               controller.chatC.text,
            //               firebaseAuth.currentUser.uid,
            //             );

            //             print(friendEmail);
            //             print(firebaseAuth.currentUser.uid);
            //             print(chatId);
            //           },
            //           decoration: InputDecoration(
            //             prefixIcon: IconButton(
            //               onPressed: () {
            //                 controller.focusNode.unfocus();
            //                 controller.isShowEmoji.toggle();
            //               },
            //               icon: Icon(Icons.emoji_emotions_outlined),
            //             ),
            //             border: InputBorder.none,
            //             // border: OutlineInputBorder(
            //             //   borderRadius: BorderRadius.circular(100),
            //             // ),
            //           ),
            //         ),
            //       ),
            //       // s
            //       Material(
            //         borderRadius: BorderRadius.circular(100),
            //         color: Colors.red[900],
            //         child: InkWell(
            //           borderRadius: BorderRadius.circular(100),
            //           onTap: () {
            //             controller.newChat(
            //               friendEmail,
            //               chatId,
            //               controller.chatC.text,
            //               firebaseAuth.currentUser.uid,
            //             );
            //           },
            //           child: Padding(
            //             padding: const EdgeInsets.all(16),
            //             child: Icon(
            //               Icons.send,
            //               color: Colors.white,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Obx(
              () => (controller.isShowEmoji.isTrue)
                  ? Container(
                      height: 325,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          controller.addEmojiToChat(emoji);
                        },
                        onBackspacePressed: () {
                          controller.deleteEmoji();
                        },
                        config: Config(
                          backspaceColor: Color(0xFFB71C1C),
                          columns: 7,
                          emojiSizeMax: 32.0,
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          //    initCategory: Category.RECENT,
                          bgColor: Color(0xFFF2F2F2),
                          indicatorColor: Color(0xFFB71C1C),
                          iconColor: Colors.grey,
                          iconColorSelected: Color(0xFFB71C1C),
                          progressIndicatorColor: Color(0xFFB71C1C),
                          showRecentsTab: true,
                          recentsLimit: 28,
                          noRecentsText: "No Recents",
                          noRecentsStyle: const TextStyle(
                              fontSize: 20, color: Colors.black26),
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL,
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  // void getToken() async {
  void sendPushMessage(
      String userTokenssss, String username, String chat) async {
    try {
      print("gfghgf");
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAGzaCORA:APA91bH7NEGnNIk_DJk3bRwoXuG58LF9dbMVRJwdG5rf8XcpMv32IWk4bZxwLGoaAw912i9EabGzEMgovGbd1hM4Z0mHSIp0bTeEqNqCIoXh1QY5KUQ5fLVPg0XNVt5VAO5rd1LImqhp',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "$chat",
              'title': '$username'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": "$userTokenssss",
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // final List _items = [
  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
}

class ItemChat extends StatelessWidget {
  const ItemChat({
    Key key,
    @required this.isSender,
    @required this.msg,
    @required this.time,
  }) : super(key: key);

  final bool isSender;
  final String msg;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.jm().format(DateTime.parse(time)),
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.6),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: isSender ? Colors.white : Color.fromRGBO(101, 18, 135, 1),
              borderRadius: isSender
                  ? BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
            ),
            padding: EdgeInsets.all(15),
            child: Text(
              "$msg",
              style: TextStyle(
                color:
                    isSender ? Colors.black : Color.fromRGBO(255, 255, 255, 1),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
    );
  }
}
