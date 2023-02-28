import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';

class CommentController extends GetxController {
  TextEditingController textcommentController = TextEditingController();
  TextEditingController replyComment = TextEditingController();
  var commentId;

  var showreply = false.obs;
  var username = "".obs;
  var postIDDss = "";
  var showreplyComment = true.obs;
  var namemmm = "".obs;

  addComment(String postId, String postOwnerId, String comment, String username,
      String userphoto, String userId, String medaurl) async {
    try {
      var documentSnapshot =
          await commentsRef.doc(postId).collection("comments").get();

      int len = documentSnapshot.docs.length;
      print(len);
      commentsRef.doc(postId).collection("comments").doc("Comments$len").set({
        "username": username,
        "comment": comment,
        "timestamp": timestamp,
        "avatarUrl": userphoto,
        "userId": userId,
        "likes": [],
        "CommentLenght": "Comments$len",
        "relpyCommentlist": [],
        "postId": postId,
      });

      DocumentSnapshot doc = await postsRef
          .doc(postOwnerId)
          .collection('userPosts')
          .doc(postId)
          .get();

      await postsRef
          .doc(postOwnerId)
          .collection('userPosts')
          .doc(postId)
          .update({
        "commentCount": (doc.data() as dynamic)["commentCount"] + 1,
      });

      bool isNotPostOwner = postOwnerId != currentUserId;
      if (isNotPostOwner) {
        activityFeedRef.doc(postOwnerId).collection('feedItems').add({
          "type": "comment",
          "commentData": comment,
          "timestamp": timestamp,
          "postId": postId,
          "userId": userId,
          "relpyComment": [],
          "username": username,
          "userProfileImg": userphoto,
          "mediaUrl": medaurl,
        });
      }
      textcommentController.clear();
    } catch (e) {
      print(e.toString());
    }
  }

  likeComment(String postId, String commentlenght) async {
    print(postId);
    print(commentlenght);
    DocumentSnapshot doc = await commentsRef
        .doc(postId)
        .collection('comments')
        .doc(commentlenght)
        .get();
    print(doc);
    try {
      if ((doc.data() as dynamic)['likes'].contains(currentUserId)) {
        await commentsRef
            .doc(postId)
            .collection("comments")
            .doc(commentlenght)
            .update({
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
        print("if");
      } else {
        await commentsRef
            .doc(postId)
            .collection("comments")
            .doc(commentlenght)
            .update({
          'likes': FieldValue.arrayUnion([currentUserId]),
        });
        print("esle if");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  ///////////////////

  relyComment(
      String postId,
      String postOwnerId,
      String comment,
      String username,
      String userphoto,
      String userId,
      String medaurl,
      String commentDoc) async {
    try {
      commentsRef.doc(postId).collection("comments").doc(commentDoc).update({
        "relpyCommentlist": FieldValue.arrayUnion([
          {
            "userPhotos": userphoto,
            "replyComment": comment,
            "userName": username,
            "timeStamp": timestamp,
          },
        ]),
      });

      // DocumentSnapshot doc = await postsRef
      //     .doc(postOwnerId)
      //     .collection('userPosts')
      //     .doc(postId)
      //     .get();

      // await postsRef
      //     .doc(postOwnerId)
      //     .collection('userPosts')
      //     .doc(postId)
      //     .update({
      //   "commentCount": (doc.data() as dynamic)["commentCount"] + 1,
      // });

      // bool isNotPostOwner = postOwnerId != currentUserId;
      // if (isNotPostOwner) {
      //   activityFeedRef.doc(postOwnerId).collection('feedItems').add({
      //     "type": "comment",
      //     "commentData": comment,
      //     "timestamp": timestamp,
      //     "postId": postId,
      //     "userId": userId,
      //     "username": username,
      //     "userProfileImg": userphoto,
      //     "mediaUrl": medaurl,
      //   });
      // }
      replyComment.clear();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    showreply.value = false;
    super.dispose();
  }
}
