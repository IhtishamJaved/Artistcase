// ignore_for_file: missing_return
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:readmore/readmore.dart';

import '../../../constant/constant.dart';
import '../../../controller/home_controller.dart';
import '../../../models/live_streaming_model.dart';
import '../../../services/firestoremethod.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/music_player_item.dart';
import '../../../widgets/video_player_item.dart';
import '../../Comment_Screen/comment_screen.dart';
import '../../board_cast_screen/board_cast_screen.dart';
import '../../edit_image_post_screen/edit_image_post_screen.dart';
import '../../edit_music_post_screen/edit_music_post_screen.dart';
import '../../edit_video_post_screen/edit_post_video_screen.dart';

// ignore: must_be_immutable
class AllComponent extends StatefulWidget {
  AllComponent({Key key}) : super(key: key);

  @override
  State<AllComponent> createState() => _AllComponentState();
}

class _AllComponentState extends State<AllComponent> {
  final homecontroller = Get.put(HomeController());

  bool showHeart = false;
  int viewCount;

  @override
  void initState() {
    getView();
    super.initState();
  }

  getView() async {
    QuerySnapshot snapshot = await followersRef
        .doc(firebaseAuth.currentUser.uid)
        .collection('userFollowers')
        .get();
    setState(() {
      viewCount = snapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sizee = 25;
    final size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
        stream: timelineRef
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection('timelinePosts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.hasData) {
            return ListView.builder(
              //   physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                bool isPostOwner = firebaseAuth.currentUser.uid ==
                    snapshot.data.docs[index]["ownerId"];
                if (index == 1) {
                  return Column(
                    children: [
                      Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Color.fromRGBO(46, 12, 58, 1),
                                    backgroundImage: CachedNetworkImageProvider(
                                      snapshot.data.docs[index]["userPhoto"],
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text(
                                      snapshot.data.docs[index]["username"],
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromRGBO(
                                              216, 213, 213, 1))),
                                  subtitle: Text(
                                    snapshot.data.docs[index]["location"],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                  ),
                                  trailing: isPostOwner
                                      ? IconButton(
                                          onPressed: () {
                                            selectOptionEditOrDelete(
                                              context,
                                              snapshot.data.docs[index]
                                                  ["ownerId"],
                                              snapshot.data.docs[index]
                                                  ["postId"],
                                              snapshot.data.docs[index]
                                                  ["mediaUrl"],
                                              snapshot.data.docs[index]
                                                  ["description"],
                                              snapshot.data.docs[index]
                                                  ["Urltype"],
                                            );
                                          },
                                          icon: Icon(
                                            Icons.more_horiz,
                                            color: Color.fromRGBO(
                                                195, 195, 196, 1),
                                          ),
                                        )
                                      : Text(''),
                                ),
                              ),
                              GestureDetector(
                                onDoubleTap: () {
                                  homecontroller.likePost(
                                    snapshot.data.docs[index]["postId"],
                                    firebaseAuth.currentUser.uid,
                                    snapshot.data.docs[index]["likes"],
                                    snapshot.data.docs[index]["ownerId"],
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    if (snapshot.data.docs[index]["Urltype"] ==
                                        "image") ...[
                                      cachedNetworkImage(
                                        snapshot.data.docs[index]["mediaUrl"],
                                      ),
                                    ] else if (snapshot.data.docs[index]
                                            ["Urltype"] ==
                                        "video") ...[
                                      VideoPlayerItems(
                                        videoUrl: snapshot.data.docs[index]
                                            ["mediaUrl"],
                                      ),
                                    ] else if (snapshot.data.docs[index]
                                            ["Urltype"] ==
                                        "music") ...[
                                      MusicPlayerItem(
                                        musicUrl: snapshot.data.docs[index]
                                            ["mediaUrl"],
                                      ),
                                    ],
                                    showHeart
                                        ? Icon(
                                            Icons.favorite,
                                            size: 88.0,
                                            color: Colors.red,
                                          )
                                        : Text(""),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(width: (size.width / 100) * 6),
                                  SizedBox(width: (size.width / 100) * 1),
                                  Icon(Icons.remove_red_eye_outlined,
                                      color: Color.fromRGBO(140, 98, 243, 1),
                                      size: (size.height / 100) * 2.5),
                                  SizedBox(width: (size.width / 100) * 3),
                                  Text(
                                    viewCount.toString() ?? '',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromRGBO(168, 168, 184, 1)),
                                  ),
                                  SizedBox(width: (size.width / 100) * 2),
                                  LikeButton(
                                    size: sizee,
                                    countPostion: CountPostion.right,
                                    likeCount: snapshot
                                        .data.docs[index]["likes"].length,
                                    onTap: (isliked) async {
                                      var success = await onLikeButtonTapped(
                                        isliked,
                                        snapshot.data.docs[index]["postId"],
                                        firebaseAuth.currentUser.uid,
                                        snapshot.data.docs[index]["likes"],
                                        snapshot.data.docs[index]["ownerId"],
                                      );

                                      return success;
                                      //   print(likelist.length);
                                      // ignore: unused_local_variable
                                      //  final var active = homecontroller.likePost(
                                      //         snapshot.data.docs[index]["ownerId"],
                                      //         snapshot.data.docs[index]["postId"]);
                                    },
                                    likeBuilder: (isLiked) {
                                      final color = snapshot
                                              .data.docs[index]["likes"]
                                              .contains(
                                                  firebaseAuth.currentUser.uid)
                                          ? Colors.pink
                                          : Color.fromRGBO(138, 99, 243, 1);
                                      return Icon(Icons.favorite_outline,
                                          color: color,
                                          size: (size.height / 100) * 2.5);
                                    },
                                    likeCountPadding: EdgeInsets.only(right: 5),
                                  ),
                                  SizedBox(width: (size.width / 100) * 2),
                                  InkWell(
                                      onTap: () {
                                        print(
                                          snapshot.data.docs[index]
                                              ["deviceToken"],
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Comments(
                                              notificationToken: snapshot.data
                                                  .docs[index]["deviceToken"],
                                              postId: snapshot.data.docs[index]
                                                  ["postId"],
                                              postOwnerId: snapshot
                                                  .data.docs[index]["ownerId"],
                                              postMediaUrl: snapshot
                                                  .data.docs[index]["mediaUrl"],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.chat_rounded,
                                          color:
                                              Color.fromRGBO(140, 98, 243, 1),
                                          size: (size.height / 100) * 2.5)),
                                  SizedBox(width: (size.width / 100) * 3),
                                  Text(
                                    snapshot.data.docs[index]["commentCount"]
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(168, 168, 184, 1),
                                    ),
                                  ),
                                  SizedBox(width: (size.width / 100) * 2),
                                ],
                              ),
                              SizedBox(height: (size.height / 100) * 2),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 26,
                                ),
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: ReadMoreText(
                                    " ${snapshot.data.docs[index]["description"]}",
                                    trimLines: 2,
                                    textAlign: TextAlign.justify,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'more',
                                    trimExpandedText: 'less',
                                    moreStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    lessStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                        color:
                                            Color.fromRGBO(168, 168, 184, 1)),
                                  ),
                                ),
                              ),
                              SizedBox(height: (size.height / 100) * 2),
                            ],
                          ),
                        ),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('livestream')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  LiveStreamModel post =
                                      LiveStreamModel.fromMap(
                                    snapshot.data.docs[index].data(),
                                  );

                                  return InkWell(
                                    onTap: () async {
                                      await FirestoreMethods().updateViewCount(
                                          post.channelId, true);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => BroadcastScreen(
                                            isBroadcaster:
                                                firebaseAuth.currentUser.uid ==
                                                        post.uid
                                                    ? true
                                                    : false,
                                            channelId: post.channelId,
                                            uid: post.uid,
                                            username: post.username,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                  width:
                                                      (size.width / 100) * 6.5),
                                              Text(
                                                'Live',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w700,
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                ),
                                              ),
                                              Image.asset(
                                                'images/live_bt1.png',
                                                height:
                                                    (size.height / 100) * 13,
                                                width: (size.width / 100) * 13,
                                              )
                                            ],
                                          ),
                                          Container(
                                            width: size.width,
                                            height: (size.height / 100) * 32,
                                            child: GridView.builder(
                                              scrollDirection: Axis.horizontal,
                                              gridDelegate:
                                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                                maxCrossAxisExtent: 500,
                                                childAspectRatio: 1.6,
                                              ),
                                              itemCount:
                                                  snapshot.data.docs.length,
                                              itemBuilder: (context, i) =>
                                                  Column(
                                                children: [
                                                  Stack(children: [
                                                    cachedNetworkImage(
                                                        post.image),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 135,
                                                              left: 50),
                                                      child: Text(
                                                        post.username,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color.fromRGBO(
                                                              255, 255, 255, 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          }),
                    ],
                  );
                } else
                  return Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color.fromRGBO(46, 12, 58, 1),
                                backgroundImage: CachedNetworkImageProvider(
                                  snapshot.data.docs[index]["userPhoto"],
                                ),
                              ),
                              contentPadding: EdgeInsets.all(0),
                              title: Text(snapshot.data.docs[index]["username"],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(216, 213, 213, 1))),
                              subtitle: Text(
                                snapshot.data.docs[index]["location"],
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              ),
                              trailing: isPostOwner
                                  ? IconButton(
                                      onPressed: () {
                                        selectOptionEditOrDelete(
                                          context,
                                          snapshot.data.docs[index]["ownerId"],
                                          snapshot.data.docs[index]["postId"],
                                          snapshot.data.docs[index]["mediaUrl"],
                                          snapshot.data.docs[index]
                                              ["description"],
                                          snapshot.data.docs[index]["Urltype"],
                                        );
                                      },
                                      icon: Icon(
                                        Icons.more_horiz,
                                        color: Color.fromRGBO(195, 195, 196, 1),
                                      ),
                                    )
                                  : Text(''),
                            ),
                          ),
                          GestureDetector(
                            onDoubleTap: () {
                              homecontroller.likePost(
                                snapshot.data.docs[index]["postId"],
                                firebaseAuth.currentUser.uid,
                                snapshot.data.docs[index]["likes"],
                                snapshot.data.docs[index]["ownerId"],
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                if (snapshot.data.docs[index]["Urltype"] ==
                                    "image") ...[
                                  cachedNetworkImage(
                                    snapshot.data.docs[index]["mediaUrl"],
                                  ),
                                ] else if (snapshot.data.docs[index]
                                        ["Urltype"] ==
                                    "video") ...[
                                  VideoPlayerItems(
                                    videoUrl: snapshot.data.docs[index]
                                        ["mediaUrl"],
                                  ),
                                ] else if (snapshot.data.docs[index]
                                        ["Urltype"] ==
                                    "music") ...[
                                  MusicPlayerItem(
                                    musicUrl: snapshot.data.docs[index]
                                        ["mediaUrl"],
                                  ),
                                ],
                                showHeart
                                    ? Icon(
                                        Icons.favorite,
                                        size: 88.0,
                                        color: Colors.red,
                                      )
                                    : Text(""),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(width: (size.width / 100) * 6),
                              SizedBox(width: (size.width / 100) * 1),
                              Icon(Icons.remove_red_eye_outlined,
                                  color: Color.fromRGBO(140, 98, 243, 1),
                                  size: (size.height / 100) * 2.5),
                              SizedBox(width: (size.width / 100) * 3),
                              Text(
                                viewCount.toString() ?? '',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(168, 168, 184, 1)),
                              ),
                              SizedBox(width: (size.width / 100) * 2),
                              LikeButton(
                                size: sizee,
                                countPostion: CountPostion.right,
                                isLiked: snapshot.data.docs[index]["likes"]
                                        .contains(firebaseAuth.currentUser.uid)
                                    ? true
                                    : false,
                                likeCount:
                                    snapshot.data.docs[index]["likes"].length,
                                onTap: (isliked) async {
                                  var success = await onLikeButtonTapped(
                                    isliked,
                                    snapshot.data.docs[index]["postId"],
                                    firebaseAuth.currentUser.uid,
                                    snapshot.data.docs[index]["likes"],
                                    snapshot.data.docs[index]["ownerId"],
                                  );

                                  return success;
                                },
                                likeBuilder: (isLiked) {
                                  final color = snapshot
                                          .data.docs[index]["likes"]
                                          .contains(
                                              firebaseAuth.currentUser.uid)
                                      ? Colors.pink
                                      : Color.fromRGBO(138, 99, 243, 1);
                                  return Icon(Icons.favorite_outline,
                                      color: color,
                                      size: (size.height / 100) * 2.5);
                                },
                                likeCountPadding: EdgeInsets.only(right: 5),
                              ),
                              SizedBox(width: (size.width / 100) * 2),
                              InkWell(
                                  onTap: () {
                                    print(snapshot.data.docs[index]
                                        ["deviceToken"]);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Comments(
                                          notificationToken: snapshot
                                              .data.docs[index]["deviceToken"],
                                          postId: snapshot.data.docs[index]
                                              ["postId"],
                                          postOwnerId: snapshot.data.docs[index]
                                              ["ownerId"],
                                          postMediaUrl: snapshot
                                              .data.docs[index]["mediaUrl"],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(Icons.chat_rounded,
                                      color: Color.fromRGBO(140, 98, 243, 1),
                                      size: (size.height / 100) * 2.5)),
                              SizedBox(width: (size.width / 100) * 3),
                              Text(
                                snapshot.data.docs[index]["commentCount"]
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(168, 168, 184, 1),
                                ),
                              ),
                              SizedBox(width: (size.width / 100) * 2),
                            ],
                          ),
                          SizedBox(height: (size.height / 100) * 2),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 26,
                            ),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: ReadMoreText(
                                " ${snapshot.data.docs[index]["description"]}",
                                trimLines: 2,
                                textAlign: TextAlign.justify,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'more',
                                trimExpandedText: 'less',
                                moreStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                lessStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(168, 168, 184, 1),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: (size.height / 100) * 2),
                        ],
                      ),
                    ),
                  );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<bool> onLikeButtonTapped(
    bool isLiked,
    String postId,
    String currenduid,
    List likes,
    String ownerId,
  ) async {
    final active = await homecontroller.likePost(
      postId,
      currenduid,
      likes,
      ownerId,
    );

    return active ? !isLiked : !isLiked;
  }

  selectOptionEditOrDelete(BuildContext parentContext, String ownerId,
      String postId, String mediaUrl, String cap, String medtype) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Select Option"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                if (medtype == "image") {
                  Get.to(
                    () => EditPostScreen(
                      imageUrl: mediaUrl,
                      postIDs: postId,
                      caption: cap,
                      mediatype: medtype,
                    ),
                  );
                  print("image");
                } else if (medtype == "video") {
                  Get.to(
                    () => EditVideosPostScreen(
                      caption: cap,
                      videoPath: mediaUrl,
                      postIDss: postId,
                    ),
                  );
                  print("video");
                } else if (medtype == "music") {
                  Get.to(
                    () => EditMusicPostScreen(
                      caption: cap,
                      musicPath: mediaUrl,
                      postIDSss: postId,
                    ),
                  );
                  print("music");
                }
              },
              child: Text(
                'Edit',
                style: TextStyle(color: Colors.red),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                handleDeletePost(parentContext, ownerId, postId);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext, String ownerId, String postId) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Remove this post?"),
          children: <Widget>[
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  homecontroller.deletePost(ownerId, postId);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                )),
            SimpleDialogOption(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ],
        );
      },
    );
  }
}
