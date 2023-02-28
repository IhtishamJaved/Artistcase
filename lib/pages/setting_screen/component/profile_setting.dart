// ignore_for_file: missing_return

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/constant.dart';
import '../../../constant/sizeconfig.dart';
import '../../../controller/auth_controller.dart';
import '../../../widgets/loading_screen.dart';

class SettingProfileScreen extends StatefulWidget {
  // ProfileScreen({@required this.profileId});

  @override
  _SettingProfileScreenState createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  final String profileId = firebaseAuth.currentUser.uid;
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  DocumentSnapshot snapshot;

  bool isPasswordVisible = false;
  bool isPasswordVisible1 = false;

  String username;
  String userId;
  String userPhoto;
  final authcontroller = Get.put(AuthController());
  var globalkey = GlobalKey<FormState>();
  String logInType;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phonenuber = TextEditingController();

  @override
  void initState() {
    super.initState();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    getprofiledata();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await postsRef
          .doc(profileId)
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        isLoading = false;
        postCount = snapshot.docs.length;
        print("Getting profile post");
      });
    } catch (e) {
      print(e.toString());
      print("Getting profile post");
    }
  }

  Future getprofiledata() async {
    try {
      snapshot = await firestore.collection("users").doc(profileId).get();
      print(snapshot);
      setState(() {
        email.text = (snapshot.data() as Map<String, dynamic>)["email"];
        logInType = (snapshot.data() as Map<String, dynamic>)["type"];
        name.text = (snapshot.data() as Map<String, dynamic>)["username"];
        password.text = (snapshot.data() as Map<String, dynamic>)["password"];
        confirmpassword.text =
            (snapshot.data() as Map<String, dynamic>)["password"];
        print(name);
        userPhoto = (snapshot.data() as Map<String, dynamic>)["photoUrl"];
        username = (snapshot.data() as Map<String, dynamic>)["username"];

        if (logInType == "email") {
          return phonenuber.text =
              (snapshot.data() as Map<String, dynamic>)["phonenumber"];
        }

        print(logInType);

        print(userPhoto);
      });
      print((snapshot.data() as Map<String, dynamic>)["photoUrl"]);
    } catch (e) {
      print(e.toString());
    }
  }

  checkIfFollowing() async {
    try {
      DocumentSnapshot doc = await followersRef
          .doc(profileId)
          .collection('userFollowers')
          .doc(currentUserId)
          .get();
      setState(() {
        isFollowing = doc.exists;

        print(isFollowing);
        print("Checkfollowing");
      });
    } catch (e) {
      print(e.toString());
      print("Checkfollowing");
    }
  }

  getFollowers() async {
    try {
      QuerySnapshot snapshot =
          await followersRef.doc(profileId).collection('userFollowers').get();
      setState(() {
        followerCount = snapshot.docs.length - 1;
        print(followerCount);
        print("checkfolllower");
      });
    } catch (e) {
      print(e.toString());
    }
  }

  getFollowing() async {
    try {
      QuerySnapshot snapshot =
          await followingRef.doc(profileId).collection('userFollowing').get();
      setState(() {
        followingCount = snapshot.docs.length;
        print(followerCount);
      });
    } catch (e) {
      print(e.toString());
      print("folllwoecount");
    }
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: 'Sora'),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.6),
                fontWeight: FontWeight.w400,
                fontSize: 12,
                fontFamily: 'Sora'),
          ),
        ),
      ],
    );
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .doc(profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .doc(profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(profileId)
        .set({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .doc(profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": profileId,
      "username": (snapshot.data() as Map<String, dynamic>)["username"],
      "userId": currentUserId,
      "userProfileImg": (snapshot.data() as Map<String, dynamic>)["photoUrl"],
      "timestamp": timestamp,
    });
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
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset("images/pop.png"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30.0, top: 40.0),
                child: Container(
                  height: (size.height / 100) * 8,
                  width: (size.width / 100) * 11,
                  decoration: BoxDecoration(),
                ),
              )
            ],
          ),
          Container(
            child: CircleAvatar(
                backgroundColor: Color.fromRGBO(178, 179, 187, 0.2),
                radius: 36,
                child: CircleAvatar(
                  backgroundImage: userPhoto == null
                      ? AssetImage("assets/images/nophoto.jpg")
                      : NetworkImage(userPhoto),
                  radius: 32,
                )),
          ),
          SizedBox(
            height: (size.height / 100) * 1,
          ),
          Text(
            "$username",
            style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.87),
                fontWeight: FontWeight.w600,
                fontSize: 17,
                fontFamily: 'Sora'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(
      () => authcontroller.profileupdate.value
          ? Loading()
          : Scaffold(
              backgroundColor: Color.fromRGBO(46, 12, 58, 1),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    buildProfileHeader(),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildCountColumn("posts", postCount),
                        buildCountColumn("followers", followerCount),
                        buildCountColumn("following", followingCount),
                      ],
                    ),
                    SizedBox(
                      height: (size.height / 100) * 4,
                    ),
                    Form(
                      key: globalkey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Name',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              height: (size.height / 100) * 7,
                              child: TextFormField(
                                controller: name,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'please enter name';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 0.5),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 0.5),
                                  ),
                                  suffixIcon: Icon(Icons.edit_outlined,
                                      color: Color.fromRGBO(255, 255, 255, 1)),
                                  hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[300]),
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
                          ),

                          SizedBox(height: (size.height / 100) * 3),

                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              height: (size.height / 100) * 7,
                              child: TextFormField(
                                controller: email,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'please enter email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 0.5),
                                  ),
                                  hintText: "test@gmail.com",
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 0.5),
                                  ),
                                  //  hintText: 'afnan.rauf80@gmail.com',
                                  hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[300]),
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
                          ),
                          SizedBox(height: (size.height / 100) * 3),
                          //password

                          if (logInType == "email") ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Container(
                                height: (size.height / 100) * 7,
                                child: TextFormField(
                                  controller: password,
                                  obscureText: !isPasswordVisible,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'please enter password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        top: 2 * SizeConfig.heightMultiplier),
                                    suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isPasswordVisible =
                                                !isPasswordVisible;
                                          });
                                        },
                                        child: Icon(
                                            isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.white)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                          width: 0.5),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                          width: 0.5),
                                    ),
                                    hintText: '**********',
                                    hintStyle: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[300]),
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
                            ),
                            SizedBox(height: (size.height / 100) * 3),
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'confirm password',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Container(
                                height: (size.height / 100) * 7,
                                child: TextFormField(
                                  controller: confirmpassword,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Please Enter ConfirmPassword";
                                    }

                                    if (password.text != confirmpassword.text) {
                                      return "Password does not match";
                                    }
                                  },
                                  obscureText: !isPasswordVisible1,
                                  decoration: InputDecoration(
                                    suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isPasswordVisible1 =
                                                !isPasswordVisible1;
                                          });
                                        },
                                        child: Icon(
                                            isPasswordVisible1
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.white)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                          width: 0.5),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                          width: 0.5),
                                    ),
                                    hintText: '**********',
                                    hintStyle: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[300]),
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
                            ),
                          ],
                          SizedBox(height: (size.height / 100) * 3),
                          //phone number

                          if (logInType == "email") ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'phone number',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Container(
                                height: (size.height / 100) * 4,
                                child: TextFormField(
                                  controller: phonenuber,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'please enter phone number';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                          width: 0.5),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                          width: 0.5),
                                    ),
                                    hintText: '+120344567787',
                                    hintStyle: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[300]),
                                  ),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'phone number',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Container(
                                height: (size.height / 100) * 7,
                                child: TextFormField(
                                  controller: phonenuber,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'please enter phone number';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                          width: 0.5),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                          width: 0.5),
                                    ),
                                    hintText: '+120344567787',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                          //save btn
                          SizedBox(height: (size.height / 100) * 6),

                          GestureDetector(
                            onTap: () {
                              if (globalkey.currentState.validate()) {
                                setState(() {
                                  authcontroller.profileupdate.value = true;
                                });
                                authcontroller.updateUserData(
                                  name.text.trim(),
                                  email.text.trim(),
                                  password.text.trim(),
                                  phonenuber.text.trim(),
                                );
                              }
                            },
                            child: Container(
                              height: (size.height / 100) * 5,
                              width: (size.width / 100) * 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color.fromRGBO(134, 100, 244, 1),
                                        Color.fromRGBO(169, 90, 237, 1),
                                      ])),
                              child: Center(
                                  child: Text(
                                "Save",
                                style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    fontFamily: 'poppins'),
                              )),
                            ),
                          ),
                          SizedBox(height: (size.height / 100) * 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
