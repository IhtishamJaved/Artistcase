import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:readmore/readmore.dart';

import '../../constant/constant.dart';
import '../../constant/sizeconfig.dart';
import '../../controller/auth_controller.dart';
import '../../controller/home_controller.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/music_player_item.dart';
import '../../widgets/video_player_item.dart';
import '../Comment_Screen/comment_screen.dart';
import '../edit_image_post_screen/edit_image_post_screen.dart';
import '../edit_music_post_screen/edit_music_post_screen.dart';
import '../edit_video_post_screen/edit_post_video_screen.dart';

// ignore: must_be_immutable
class ShowProfilePostScreen extends StatefulWidget {
  final String profileID;
  final String postID;
  ShowProfilePostScreen(
      {Key key, @required this.postID, @required this.profileID})
      : super(key: key);

  @override
  State<ShowProfilePostScreen> createState() => _ShowProfilePostScreenState();
}

class _ShowProfilePostScreenState extends State<ShowProfilePostScreen> {
  bool isLiked;

  int viewCount;

  DocumentSnapshot snapshot;

  Map likes;

  File file;

  int likeCount;

  String username;

  String userId;

  String userPhoto;

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

  final authcontroller = Get.put(AuthController());

  final homecontroller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final double sizee = 25;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromRGBO(46, 12, 58, 1),
      body: StreamBuilder<DocumentSnapshot>(
        stream: timelineRef
            .doc(widget.profileID)
            .collection('timelinePosts')
            .doc(widget.postID)
            .snapshots(),
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.hasData) {
            final datass = snapshot.data.data() as Map<String, dynamic>;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (BuildContext context, int ind) {
                bool isPostOwner =
                    firebaseAuth.currentUser.uid == datass["ownerId"];

                return Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 2 * SizeConfig.heightMultiplier,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color.fromRGBO(46, 12, 58, 1),
                            backgroundImage: CachedNetworkImageProvider(
                              datass["userPhoto"],
                            ),
                          ),
                          contentPadding: EdgeInsets.all(0),
                          title: Text(datass["username"],
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(216, 213, 213, 1))),
                          subtitle: Text(
                            datass["location"],
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
                                      datass["ownerId"],
                                      datass["postId"],
                                      datass["mediaUrl"],
                                      datass["description"],
                                      datass["Urltype"],
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
                            datass["postId"],
                            firebaseAuth.currentUser.uid,
                            datass["likes"],
                            datass["ownerId"],
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            if (datass["Urltype"] == "image") ...[
                              cachedNetworkImage(
                                datass["mediaUrl"],
                              ),
                            ] else if (datass["Urltype"] == "video") ...[
                              VideoPlayerItems(
                                videoUrl: datass["mediaUrl"],
                              ),
                            ] else if (datass["Urltype"] == "music") ...[
                              MusicPlayerItem(
                                musicUrl: datass["mediaUrl"],
                              ),
                            ],
                            // showHeart
                            //     ? Icon(
                            //         Icons.favorite,
                            //         size: 88.0,
                            //         color: Colors.red,
                            //       )
                            //     : Text(""),
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
                            isLiked: datass["likes"]
                                    .contains(firebaseAuth.currentUser.uid)
                                ? true
                                : false,
                            likeCount: datass["likes"].length,
                            onTap: (isliked) async {
                              var success = await onLikeButtonTapped(
                                isliked,
                                datass["postId"],
                                firebaseAuth.currentUser.uid,
                                datass["likes"],
                                datass["ownerId"],
                              );

                              return success;
                            },
                            likeBuilder: (isLiked) {
                              final color = datass["likes"]
                                      .contains(firebaseAuth.currentUser.uid)
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Comments(
                                      notificationToken: datass["deviceToken"],
                                      postId: datass["postId"],
                                      postOwnerId: datass["ownerId"],
                                      postMediaUrl: datass["mediaUrl"],
                                    ),
                                  ),
                                );
                              },
                              child: Icon(Icons.chat_rounded,
                                  color: Color.fromRGBO(140, 98, 243, 1),
                                  size: (size.height / 100) * 2.5)),
                          SizedBox(width: (size.width / 100) * 3),
                          Text(
                            datass["commentCount"].toString(),
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
                            " ${datass["description"]}",
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
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
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
        });
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
