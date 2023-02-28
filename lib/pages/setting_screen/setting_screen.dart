import 'package:artistcase/pages/term_condition_screen/term_condition_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../controller/auth_controller.dart';
import 'component/profile_setting.dart';

class SettingScreen extends StatefulWidget {
  // ProfileScreen({@required this.profileId});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final String currentUserId = firebaseAuth.currentUser.uid;

  final String profileId = firebaseAuth.currentUser.uid;

  bool isLoading = false;

  DocumentSnapshot snapshot;
  bool isSwitched = false;

  String username;
  String userId;
  String userPhoto;
  final authcontroller = Get.put(AuthController());

  @override
  void initState() {
    super.initState();

    getprofiledata();
  }

  Future getprofiledata() async {
    try {
      snapshot = await firestore.collection("users").doc(profileId).get();
      print(snapshot);
      setState(() {
        userPhoto = (snapshot.data() as Map<String, dynamic>)["photoUrl"];
        username = (snapshot.data() as Map<String, dynamic>)["username"];
        print(userPhoto);
      });
      print((snapshot.data() as Map<String, dynamic>)["photoUrl"]);
    } catch (e) {
      print(e.toString());
    }
  }

  buildProfileHeader() {
    final size = MediaQuery.of(context).size;

    return Container(
      height: (size.height / 100) * 35,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/profile1_1.png'), fit: BoxFit.cover),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 35.0, top: 20),
                child: Container(
                    // child: InkWell(
                    //   onTap: () {
                    //     //  Navigator.of(context).pop();
                    //   },
                    //   child: Image.asset("images/pop.png"),
                    // ),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30.0, top: 40.0),
                child: Container(
                  height: (size.height / 100) * 8,
                  width: (size.width / 100) * 11,
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //     image: AssetImage(
                  //       "images/Glow.png",
                  //     ),
                  //   ),
                  // ),
                  // child: Icon(
                  //   Icons.more_vert,
                  //   color: Color.fromRGBO(255, 255, 255, 1),
                  // ),
                ),
              )
            ],
          ),

          StreamBuilder(
              stream: firestore.collection("users").doc(profileId).snapshots(),
              // ignore: missing_return
              builder: (context, snapshot) {
                print(snapshot);
                if (snapshot.hasData) {
                  final datass = snapshot.data.data() as Map<String, dynamic>;

                  return Column(
                    children: [
                      Container(
                        child: CircleAvatar(
                            backgroundColor: Color.fromRGBO(178, 179, 187, 0.2),
                            radius: 36,
                            child: CircleAvatar(
                              backgroundImage: datass["photoUrl"] == null
                                  ? AssetImage("assets/images/nophoto.jpg")
                                  : NetworkImage(datass["photoUrl"]),
                              radius: 32,
                            )),
                      ),
                      SizedBox(
                        height: (size.height / 100) * 1,
                      ),
                      Text(
                        "${datass["username"]}",
                        style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.87),
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            fontFamily: 'Sora'),
                      ),
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
          // Container(
          //   child: CircleAvatar(
          //       backgroundColor: Color.fromRGBO(178, 179, 187, 0.2),
          //       radius: 36,
          //       child: CircleAvatar(
          //         backgroundImage: userPhoto == null
          //             ? AssetImage("assets/images/nophoto.jpg")
          //             : NetworkImage(userPhoto),
          //         radius: 32,
          //       )),
          // ),
          // SizedBox(
          //   height: (size.height / 100) * 1,
          // ),
          // Text(
          //   "$username",
          //   style: TextStyle(
          //       color: Color.fromRGBO(255, 255, 255, 0.87),
          //       fontWeight: FontWeight.w600,
          //       fontSize: 17,
          //       fontFamily: 'Sora'),
          // ),
          // Text(
          //   "Dj / Producer / Artist",
          //   style: TextStyle(
          //       color: Color.fromRGBO(101, 103, 120, 1),
          //       fontWeight: FontWeight.w400,
          //       fontSize: 12.0,
          //       fontFamily: 'Sora'),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(46, 12, 58, 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildProfileHeader(),
            SizedBox(
              height: size.height * 0.03,
            ),
            Card(
              elevation: 0,
              color: Color.fromRGBO(46, 12, 58, 1),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingProfileScreen(),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: Color.fromRGBO(139, 98, 243, 1),
                      ),
                      title: Text('Profile setting',
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(255, 255, 255, 1))),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.notifications_none,
                      color: Color.fromRGBO(139, 98, 243, 1),
                    ),
                    title: Text('Notification',
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(255, 255, 255, 1))),
                    trailing: Switch(
                      activeColor: Color.fromRGBO(142, 97, 242, 1),
                      inactiveTrackColor: Color.fromRGBO(142, 97, 242, 1),
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.to(() => TermConditionScreen());
                    },
                    leading: Icon(
                      Icons.person_pin_outlined,
                      color: Color.fromRGBO(139, 98, 243, 1),
                    ),
                    title: Text('Terms and Conditions',
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(255, 255, 255, 1))),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Color.fromRGBO(139, 98, 243, 1),
                    ),
                    title: InkWell(
                        onTap: () {
                          authcontroller.signout();
                        },
                        child: Text('Logout',
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(255, 255, 255, 1)))),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
