import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../constant/constant.dart';
import '../../../roots/bottom_navigation_bar.dart';
import '../message_controller/message_controller.dart';

class MessageView extends StatefulWidget {
  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  // final authC = Get.find<AuthController>();
  final controller = Get.put(MessageController());
  DocumentSnapshot snapshot;

  String username;
  String userId;
  String userPhoto;

  @override
  void initState() {
    getuserdata();
    super.initState();
  }

  Future getuserdata() async {
    try {
      String uid = firebaseAuth.currentUser.uid;
      snapshot = await firestore.collection("users").doc(uid).get();
      print(snapshot);
      setState(() {
        userPhoto = (snapshot.data() as Map<String, dynamic>)["photoUrl"];
        print(userPhoto);
      });
      print((snapshot.data() as Map<String, dynamic>)["photoUrl"]);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(46, 12, 58, 1),
      body: Column(
        children: [
          Container(
            child: Column(
              children: [
                SizedBox(height: (size.height / 100) * 5.4),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text('Message',
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(216, 213, 213, 1))),
                    ),
                    SizedBox(width: (size.width / 100) * 48),
                    InkWell(
                        onTap: () {
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) => Main()));
                        },
                        child: CircleAvatar(
                          backgroundColor: Color.fromRGBO(166, 91, 238, 1),
                          radius: 26,
                          child: CircleAvatar(
                            radius: 23,
                            backgroundImage: userPhoto == null
                                ? AssetImage("assets/images/nophoto.jpg")
                                : NetworkImage(userPhoto),
                          ),
                        ))
                  ],
                ),
                SizedBox(height: (size.height / 100) * 3),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: InkWell(
                    onTap: () {
                      Get.offAll(() => BottomNavigationTabBar());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset('images/pop.png'),
                    ),
                  ),
                ),
                SizedBox(height: (size.height / 100) * 3),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: controller.chatsStream(firebaseAuth.currentUser.uid),
              builder: (context, snapshot1) {
                if (snapshot1.connectionState == ConnectionState.active) {
                  var listDocsChats = snapshot1.data.docs;
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: listDocsChats.length,
                    itemBuilder: (context, index) {
                      print(listDocsChats[index]["connection"]);
                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: controller
                            .friendStream(listDocsChats[index]["connection"]),
                        builder: (context, snapshot2) {
                          if (snapshot2.connectionState ==
                              ConnectionState.active) {
                            var data = snapshot2.data.data();
                            return data["status"] == ""
                                ? ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    onTap: () => controller.goToChatRoom(
                                      "${listDocsChats[index].id}",
                                      firebaseAuth.currentUser.email,
                                      listDocsChats[index]["connection"],
                                      firebaseAuth.currentUser.uid,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          data["photoUrl"] == "noimage"
                                              ? AssetImage(
                                                  "assets/logo/noimage.png",
                                                )
                                              : NetworkImage(
                                                  "${data["photoUrl"]}",
                                                ),
                                      backgroundColor: Colors.black26,
                                      // child: ClipRRect(
                                      //   borderRadius: BorderRadius.circular(20),
                                      //   child: data["photoUrl"] == "noimage"
                                      //       ? Image.asset(
                                      //           "assets/logo/noimage.png",
                                      //           fit: BoxFit.cover,
                                      //         )
                                      //       : Image.network(
                                      //           "${data["photoUrl"]}",
                                      //           fit: BoxFit.cover,
                                      //         ),
                                      // ),
                                    ),
                                    title: Text(
                                      "${data["username"]}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(216, 213, 213, 1),
                                      ),
                                    ),
                                    subtitle: Text(
                                      listDocsChats[index]["lastmsg"],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromRGBO(195, 195, 196, 1),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    trailing: listDocsChats[index]
                                                ["total_unread"] ==
                                            0
                                        ? SizedBox()
                                        : Chip(
                                            backgroundColor: Color.fromRGBO(
                                                194, 175, 255, 1),
                                            label: Text(
                                              "${listDocsChats[index]["total_unread"]}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                  )
                                : ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    onTap: () => controller.goToChatRoom(
                                      "${listDocsChats[index].id}",
                                      firebaseAuth.currentUser.email,
                                      listDocsChats[index]["connection"],
                                      firebaseAuth.currentUser.uid,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.black26,
                                      child: ClipRRect(
                                        // borderRadius: BorderRadius.circular(30),
                                        child: data["photoUrl"] == "noimage"
                                            ? Image.asset(
                                                "assets/logo/noimage.png",
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                "${data["photoUrl"]}",
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    title: Text(
                                      "${data["username"]}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${data["status"]}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: listDocsChats[index]
                                                ["total_unread"] ==
                                            0
                                        ? SizedBox()
                                        : Chip(
                                            backgroundColor: Colors.red[900],
                                            label: Text(
                                              "${listDocsChats[index]["total_unread"]}",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                  );
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
