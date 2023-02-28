// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

import '../../constant/constant.dart';
import '../../constant/sizeconfig.dart';
import '../../controller/comment_controller.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  final String notificationToken;

  Comments({
    @required this.postId,
    @required this.postOwnerId,
    @required this.postMediaUrl,
    @required this.notificationToken,
  });

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  DocumentSnapshot snapshot;

  var globalkey = GlobalKey<FormState>();
  final commentcontroller = Get.put(CommentController());
  final double sizee = 25;
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  var userName;
  List lll;
  AndroidNotificationChannel channel;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  void initState() {
    getuserdata();
    loadFCM();
    listenFCM();
    requestPermission();
    super.initState();
  }

  getuserdata() async {
    String uid = firebaseAuth.currentUser.uid;
    snapshot = await firestore.collection("users").doc(uid).get();
    print(snapshot);
    print((snapshot.data() as Map<String, dynamic>)["photoUrl"]);
    setState(() {
      commentcontroller.postIDDss = widget.postId;
    });
    print(commentcontroller.postIDDss);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(46, 12, 58, 1),
      body: Form(
        key: globalkey,
        child: Column(
          children: <Widget>[
            SizedBox(height: (size.height / 100) * 5.4),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Comments',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(216, 213, 213, 1),
                ),
              ),
            ),
            SizedBox(height: (size.height / 100) * 1),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: InkWell(
                  onTap: () {
                    Get.back();

                    setState(() {
                      commentcontroller.showreply.value = false;
                    });
                  },
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset('images/pop.png'))),
            ),
            //    SizedBox(height: (size.height / 100) * ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("comments")
                    .doc(widget.postId)
                    .collection("comments")
                    .snapshots(),
                builder: (context, snapshot) {
                  print(snapshot);

                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = snapshot.data.docs[index];

                      var datasss = data["relpyCommentlist"] as List;

                      print(datasss);
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundImage: CachedNetworkImageProvider(
                                    data["avatarUrl"]),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    data["username"],
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                        color:
                                            Color.fromRGBO(255, 255, 255, 1)),
                                  ),
                                  SizedBox(
                                    width: (size.width / 100) * 5,
                                  ),
                                  Text(
                                    timeago.format(data["timestamp"].toDate()),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                        color:
                                            Color.fromRGBO(255, 255, 255, 1)),
                                  ),
                                  SizedBox(
                                    height: (size.height / 100) * 5,
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                data["comment"],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(255, 255, 255, 0.84),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: (size.width / 100) * 24,
                              ),
                              LikeButton(
                                  size: sizee,
                                  countPostion: CountPostion.right,
                                  likeCount: data["likes"].length,
                                  //  isLiked: isLiked,

                                  onTap: (isliked) async {
                                    print(data["likes"].length);
                                    // ignore: unused_local_variable
                                    var active = commentcontroller.likeComment(
                                        widget.postId, data["CommentLenght"]);
                                    return !isliked;
                                  },
                                  likeBuilder: (isLiked) {
                                    final color = data["likes"].contains(
                                            firebaseAuth.currentUser.uid)
                                        ? Colors.pink
                                        : Color.fromRGBO(138, 99, 243, 1);
                                    return Icon(Icons.favorite_outline,
                                        color: color,
                                        size: (size.height / 100) * 2.5);
                                  },
                                  likeCountPadding: EdgeInsets.only(right: 5),
                                  countBuilder: (count, islike, text) {
                                    // ignore: unused_local_variable
                                    final color =
                                        Color.fromRGBO(168, 168, 184, 1);
                                    return Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromRGBO(168, 168, 184, 1),
                                      ),
                                    );
                                  }),
                              SizedBox(
                                width: (size.width / 100) * 3,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    commentcontroller.showreply.value = true;
                                    commentcontroller.username.value =
                                        data["username"];
                                    commentcontroller.commentId =
                                        data["CommentLenght"];
                                    print(commentcontroller.commentId);
                                    // print(widget.commentLenght);
                                  });
                                  print(commentcontroller.username);
                                },
                                child: Image.asset('images/replay_icon.png',
                                    height: (size.height / 100) * 2),
                              ),
                              SizedBox(
                                width: (size.width / 100) * 1,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    commentcontroller.showreply.value = true;
                                    commentcontroller.username.value =
                                        data["username"];
                                    commentcontroller.commentId =
                                        data["CommentLenght"];
                                    print(commentcontroller.commentId);
                                    // print(widget.commentLenght);
                                  });
                                  print(commentcontroller.username.value);
                                },
                                child: Text(
                                  'Reply',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (datasss.length == 0) ...[
                            SizedBox(),
                          ] else ...[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 17 * SizeConfig.widthMultiplier),
                              child: ExpansionTileCard(
                                trailing: Text(""),
                                elevation: 0,
                                baseColor: Colors.transparent,
                                expandedColor: Color.fromRGBO(46, 12, 58, 1),
                                leading: Icon(
                                  Icons.arrow_drop_down,
                                  size: (size.height / 100) * 5,
                                  color: Color.fromRGBO(224, 210, 255, 1),
                                ),
                                title: Text(
                                  "View Replies",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                children: <Widget>[
                                  ListView(
                                    shrinkWrap: true,
                                    children: List.generate(
                                      datasss.length,
                                      (i) {
                                        return Column(children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                            ),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                radius: 24,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                        datasss[i]
                                                            ["userPhotos"]),
                                              ),
                                              title: Row(
                                                children: [
                                                  Text(
                                                    datasss[i]["userName"],
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromRGBO(
                                                            255, 255, 255, 1)),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        (size.width / 100) * 3,
                                                  ),
                                                  Text(
                                                    timeago.format(datasss[i]
                                                            ["timeStamp"]
                                                        .toDate()),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromRGBO(
                                                            255, 255, 255, 1)),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        (size.height / 100) * 5,
                                                  ),
                                                ],
                                              ),
                                              subtitle: Text(
                                                datasss[i]["replyComment"],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w400,
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 0.84),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Divider(
              thickness: 3,
              color: Color.fromRGBO(77, 12, 103, 1),
            ),
            Obx(
              () => commentcontroller.showreply.value
                  ? Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 8 * SizeConfig.widthMultiplier,
                            ),
                            Text(
                              'Replying to ',
                              style: TextStyle(
                                fontSize: 2 * SizeConfig.textMultiplier,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${commentcontroller.username}',
                              style: TextStyle(
                                fontSize: 2 * SizeConfig.textMultiplier,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  commentcontroller.showreply.value = false;
                                });
                              },
                              child: Text(
                                '  .Cancel',
                                style: TextStyle(
                                  fontSize: 2 * SizeConfig.textMultiplier,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromRGBO(216, 213, 213, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ListTile(
                          title: TextFormField(
                            style: TextStyle(
                              color: Color.fromRGBO(
                                255,
                                255,
                                255,
                                1,
                              ),
                            ),
                            controller: commentcontroller.replyComment,
                            decoration: InputDecoration(
                              hintText: commentcontroller.username.value,
                              labelText: "Write comment Reply ",
                              labelStyle: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  1,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'please enter comment';
                              }
                              return null;
                            },
                          ),
                          trailing: OutlineButton(
                            onPressed: () {
                              if (globalkey.currentState.validate()) {
                                commentcontroller.relyComment(
                                  postId,
                                  widget.postOwnerId,
                                  commentcontroller.replyComment.text.trim(),
                                  (snapshot.data() as dynamic)["username"],
                                  (snapshot.data() as dynamic)["photoUrl"],
                                  (snapshot.data() as dynamic)["id"],
                                  postMediaUrl,
                                  commentcontroller.commentId,
                                );
                                sendPushMessage(
                                  widget.notificationToken,
                                  (snapshot.data() as dynamic)["username"],
                                  commentcontroller.replyComment.text,
                                );
                              }
                            },
                            borderSide: BorderSide.none,
                            child: Text(
                              "Post",
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                color: Color.fromRGBO(255, 255, 255, 0.84),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListTile(
                      title: TextFormField(
                        style: TextStyle(
                          color: Color.fromRGBO(
                            255,
                            255,
                            255,
                            1,
                          ),
                        ),
                        controller: commentcontroller.textcommentController,
                        decoration: InputDecoration(
                          labelText: "Write a comment...",
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(
                              255,
                              255,
                              255,
                              1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter comment';
                          }
                          return null;
                        },
                      ),
                      trailing: OutlineButton(
                        onPressed: () {
                          if (globalkey.currentState.validate()) {
                            print("hello");
                            commentcontroller.addComment(
                              postId,
                              widget.postOwnerId,
                              commentcontroller.textcommentController.text
                                  .trim(),
                              (snapshot.data() as dynamic)["username"],
                              (snapshot.data() as dynamic)["photoUrl"],
                              (snapshot.data() as dynamic)["id"],
                              postMediaUrl,
                            );

                            sendPushMessage(
                              widget.notificationToken,
                              (snapshot.data() as dynamic)["username"],
                              commentcontroller.textcommentController.text
                                  .trim(),
                            );
                          }
                        },
                        borderSide: BorderSide.none,
                        child: Text(
                          "Post",
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            color: Color.fromRGBO(255, 255, 255, 0.84),
                          ),
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  // void getToken() async {
  void sendPushMessage(
      String userTokenssss, String username, String comment) async {
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
              'body': "$comment",
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

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

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

  @override
  void dispose() {
    commentcontroller.showreply.value = false;

    super.dispose();
  }
}
