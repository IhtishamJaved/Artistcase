import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:readmore/readmore.dart';

import '../../../constant/constant.dart';

import '../../../controller/home_controller.dart';
import '../../../widgets/music_player_item.dart';

import '../../Comment_Screen/comment_screen.dart';

// ignore: must_be_immutable
class MusicComponent extends StatefulWidget {
  MusicComponent({Key key}) : super(key: key);

  @override
  State<MusicComponent> createState() => _MusicComponentState();
}

class _MusicComponentState extends State<MusicComponent> {
  final homecontroller = Get.put(HomeController());

  int viewCount;

  @override
  void initState() {
    getView();
    super.initState();
  }

  bool showHeart = false;
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
            .where("Urltype", isEqualTo: "music")
            .snapshots(),
        // ignore: missing_return
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                bool isPostOwner = firebaseAuth.currentUser.uid ==
                    snapshot.data.docs[index]["ownerId"];

                return Container(
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
                          trailing: isPostOwner
                              ? IconButton(
                                  onPressed: () => handleDeletePost(
                                      context,
                                      snapshot.data.docs[index]["ownerId"],
                                      snapshot.data.docs[index]["postId"]),
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
                            MusicPlayerItem(
                              musicUrl: snapshot.data.docs[index]["mediaUrl"],
                            ),
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
                          SizedBox(width: (size.width / 100) * 4),
                          LikeButton(
                            size: sizee,
                            countPostion: CountPostion.right,
                            isLiked: snapshot.data.docs[index]["likes"]
                                    .contains(firebaseAuth.currentUser.uid)
                                ? true
                                : false,
                            likeCount:
                                snapshot.data.docs[index]["likes"].length,
                            //  isLiked: isLiked,

                            onTap: (isliked) async {
                              var success = onLikeButtonTapped(
                                isliked,
                                snapshot.data.docs[index]["postId"],
                                firebaseAuth.currentUser.uid,
                                snapshot.data.docs[index]["likes"],
                                snapshot.data.docs[index]["ownerId"],
                              );

                              return success;
                            },
                            likeBuilder: (isLiked) {
                              final color = snapshot.data.docs[index]["likes"]
                                      .contains(firebaseAuth.currentUser.uid)
                                  ? Colors.pink
                                  : Color.fromRGBO(138, 99, 243, 1);
                              return Icon(Icons.favorite_outline,
                                  color: color,
                                  size: (size.height / 100) * 2.5);
                            },
                            likeCountPadding: EdgeInsets.only(right: 5),
                            countBuilder: (count, islike, text) {
                              // ignore: unused_local_variable
                              final color = Color.fromRGBO(168, 168, 184, 1);
                              return Text(
                                text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(168, 168, 184, 1),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: (size.width / 100) * 3),
                          SizedBox(width: (size.width / 100) * 2),
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Comments(
                                          notificationToken:  snapshot.data
                                                  .docs[index]["deviceToken"],
                                              postId: snapshot.data.docs[index]
                                                  ["postId"],
                                              postOwnerId: snapshot
                                                  .data.docs[index]["ownerId"],
                                              postMediaUrl: snapshot
                                                  .data.docs[index]["mediaUrl"],
                                            )));
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
                                color: Color.fromRGBO(168, 168, 184, 1)),
                          ),
                        ),
                      ),
                      SizedBox(height: (size.height / 100) * 2),
                    ],
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
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }
}
