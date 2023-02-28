import 'package:artistcase/pages/Profile_screen/component/following_show.dart';
import 'package:artistcase/pages/Profile_screen/component/show_follwers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../constant/sizeconfig.dart';
import '../../controller/auth_controller.dart';
import '../../widgets/loading_screen.dart';
import '../../widgets/post.dart';
import '../../widgets/profile_music_player.dart';
import '../../widgets/profile_video_player.dart';
import '../../widgets/progress.dart';

import '../show_profile_post_screen/show_profile_post_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;

  ProfileScreen({@required this.profileId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String currentUserId = firebaseAuth.currentUser.uid;
  String postOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;

  List<Post> posts = [];
  DocumentSnapshot snapshot;
  DocumentSnapshot currentuserDate;

  String username;
  String userId;
  String userPhoto;
  int postCount;
  int followerCount;
  String userTOkens;
  final authcontroller = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    getProfilePosts();

    checkIfFollowing();
    getCurrentUserData();
    getprofiledata();
  }

  Future getprofiledata() async {
    try {
      snapshot =
          await firestore.collection("users").doc(widget.profileId).get();
      print(snapshot);
      setState(() {
        userPhoto = (snapshot.data() as Map<String, dynamic>)["photoUrl"];
        username = (snapshot.data() as Map<String, dynamic>)["username"];
        userTOkens = (snapshot.data() as Map<String, dynamic>)["token"];
        print(userPhoto);
      });
      print(userTOkens);
      print((snapshot.data() as Map<String, dynamic>)["photoUrl"]);
    } catch (e) {
      print(e.toString());
    }
  }

  Future getCurrentUserData() async {
    try {
      currentuserDate = await firestore
          .collection("users")
          .doc(firebaseAuth.currentUser.uid)
          .get();
      print(currentuserDate);
    } catch (e) {
      print(e.toString());
    }
  }

  checkIfFollowing() async {
    try {
      DocumentSnapshot doc = await followersRef
          .doc(widget.profileId)
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

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await postsRef
          .doc(widget.profileId)
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        isLoading = false;
        postCount = snapshot.docs.length;
        print("Getting profile post");
        print(posts);
        print(postCount);
        posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
      });
    } catch (e) {
      print(e.toString());
      print("Getting profile post");
    }
  }

  Column buildFolllowerColumns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
            stream: followersRef
                .doc(widget.profileId)
                .collection('userFollowers')
                .snapshots(),
            builder: (context, snapshot) {
              print(snapshot);
              if (snapshot.hasData) {
                followerCount = snapshot.data.docs.length - 1;

                return Column(
                  children: [
                    Text(
                      followerCount.toString(),
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Sora'),
                    ),
                    Container(
                      //  color: Colors.blue,
                      margin: EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Followers",
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
              return SizedBox();
            }),
      ],
    );
  }

  Column buildFollowingCount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
            stream: followingRef
                .doc(widget.profileId)
                .collection('userFollowing')
                .snapshots(),
            builder: (context, snapshot) {
              print(snapshot);
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(
                      snapshot.data.docs.length.toString(),
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Sora'),
                    ),
                    Container(
                      //  color: Colors.blue,
                      margin: EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Following",
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
              return SizedBox();
            }),
      ],
    );
  }

  Column buildPostCount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
            stream: postsRef
                .doc(widget.profileId)
                .collection('userPosts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              print(snapshot);
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(
                      snapshot.data.docs.length.toString(),
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Sora'),
                    ),
                    Container(
                      //  color: Colors.blue,
                      margin: EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Posts",
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
              return SizedBox();
            }),
      ],
    );
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      // ignore: deprecated_member_use
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 37.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Color(0xff8664F4) : Colors.blue,
            border: Border.all(
              color: isFollowing ? Color(0xff8664F4) : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  Container messagebuildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      // ignore: deprecated_member_use
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 37.0,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return SizedBox();
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  messageButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return SizedBox();
    } else {
      return messagebuildButton(
        text: "Message",
        function: () {
          print((snapshot.data() as Map<String, dynamic>)["email"]);
          print((snapshot.data() as Map<String, dynamic>)["id"]);
          authcontroller.addNewConnection(
              (snapshot.data() as Map<String, dynamic>)["email"],
              (snapshot.data() as Map<String, dynamic>)["id"]);
          setState(() {
            authcontroller.showMessage.value = true;
          });
        },
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(widget.profileId)
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
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    activityFeedRef
        .doc(widget.profileId)
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
    print(
      (currentuserDate.data() as Map<String, dynamic>)["username"],
    );
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({
      "username": (currentuserDate.data() as Map<String, dynamic>)["username"],
      "id": currentUserId,
      "photoUrl": (currentuserDate.data() as Map<String, dynamic>)["photoUrl"],
      "timeStamp": timestamp,
    });
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({
      "username": (snapshot.data() as Map<String, dynamic>)["username"],
      "id": (snapshot.data() as Map<String, dynamic>)["id"],
      "photoUrl": (snapshot.data() as Map<String, dynamic>)["photoUrl"],
      "timeStamp": timestamp,
    });
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": (snapshot.data() as Map<String, dynamic>)["username"],
      "userId": currentUserId,
      "userProfileImg": (snapshot.data() as Map<String, dynamic>)["photoUrl"],
      "timestamp": timestamp,
    });
  }

  buildProfileHeader() {
    final size = MediaQuery.of(context).size;

    return Container(
      height: (size.height / 100) * 42,
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
                ),
              )
            ],
          ),
          StreamBuilder(
              stream: firestore
                  .collection("users")
                  .doc(widget.profileId)
                  .snapshots(),
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
          SizedBox(
            height: (size.height / 100) * 1,
          ),
          buildProfileButton(),
          messageButton(),
        ],
      ),
    );
  }

  buildProfilePosts() {
    final size = MediaQuery.of(context).size;

    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      // List<GridTile> gridTiles = [];
      // posts.forEach((post) {
      //   gridTiles.add(GridTile(child: PostTile(post)));
      // });
      return StreamBuilder<QuerySnapshot>(
          stream: postsRef
              .doc(widget.profileId)
              .collection('userPosts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          // ignore: missing_return
          builder: (context, snapshot) {
            print(snapshot);
            if (snapshot.hasData) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  width: size.width,
                  //  height: (size.height / 100) * 40,
                  margin: EdgeInsets.all(12),
                  child: StaggeredGridView.countBuilder(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                      itemCount: snapshot.data.docs.length,
                      // ignore: missing_return
                      itemBuilder: (context, index) {
                        if (snapshot.data.docs[index]["Urltype"] == "image") {
                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                () => ShowProfilePostScreen(
                                  profileID: widget.profileId,
                                  postID: snapshot.data.docs[index]["postId"],
                                ),
                              );
                              print(snapshot.data.docs[index]["postId"]);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                // color: Colors.blue,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                child: Image.network(
                                  snapshot.data.docs[index]["mediaUrl"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        } else if (snapshot.data.docs[index]["Urltype"] ==
                            "video") {
                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                () => ShowProfilePostScreen(
                                    profileID: widget.profileId,
                                    postID: snapshot.data.docs[index]
                                        ["postId"]),
                              );
                              print(snapshot.data.docs[index]["postId"]);
                            },
                            child: Container(
                              child: ProfileVideoPlayerItems(
                                videoUrl: snapshot.data.docs[index]["mediaUrl"],
                              ),
                            ),
                          );
                        } else if (snapshot.data.docs[index]["Urltype"] ==
                            "music") {
                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                () => ShowProfilePostScreen(
                                    profileID: widget.profileId,
                                    postID: snapshot.data.docs[index]
                                        ["postId"]),
                              );
                              print(snapshot.data.docs[index]["postId"]);
                            },
                            child: Container(
                              child: ProfileMusicPlayerItem(
                                musicUrl: snapshot.data.docs[index]["mediaUrl"],
                              ),
                            ),
                          );
                        }
                        // return
                      },
                      staggeredTileBuilder: (index) {
                        return StaggeredTile.count(1, index.isEven ? 1.3 : 1);
                      }),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          });

      //  Builder(
      //   builder: (context) {
      //     return Container(
      //       width: size.width,
      //       height: (size.height / 100) * 40,
      //       margin: EdgeInsets.all(12),
      //       child: StaggeredGridView.countBuilder(
      //           crossAxisCount: 3,
      //           crossAxisSpacing: 8,
      //           mainAxisSpacing: 12,
      //           itemCount: 2,
      //           itemBuilder: (context, index) {
      //             return Container(
      //               decoration: BoxDecoration(
      //                   // color: Colors.blue,
      //                   borderRadius: BorderRadius.all(Radius.circular(15))),
      //               child: ClipRRect(
      //                 borderRadius: BorderRadius.all(Radius.circular(15)),
      //                 child: Image.network(
      //                 ,
      //                   fit: BoxFit.cover,
      //                 ),
      //               ),
      //             );
      //           },
      //           staggeredTileBuilder: (index) {
      //             return StaggeredTile.count(1, index.isEven ? 1.3 : 1);
      //           }),
      //     );
      //   }
      // );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(
      () => authcontroller.showMessage.value
          ? Loading()
          : DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: Color.fromRGBO(46, 12, 58, 1),
                body: Column(
                  children: [
                    buildProfileHeader(),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 4 * SizeConfig.widthMultiplier),
                      child: TabBar(
                        labelStyle: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                        tabs: [
                          Tab(
                            child: buildPostCount(),
                          ),
                          Tab(
                            child: buildFolllowerColumns(),
                          ),
                          Tab(
                            child: buildFollowingCount(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      //     height: 20 * SizeConfig.heightMultiplier,
                      child: TabBarView(
                        children: [
                          buildProfilePosts(),
                          ShowFollower(profileID: widget.profileId),
                          FollowingShow(profileID: widget.profileId),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: (size.height / 100) * 0.5,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
