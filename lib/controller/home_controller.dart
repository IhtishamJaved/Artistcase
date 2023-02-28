import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';
import '../roots/bottom_navigation_bar.dart';

class HomeController extends GetxController {
  deletePost(String ownerId, String postId) async {
    // delete post itself
    postsRef.doc(ownerId).collection('userPosts').doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for thep ost
    storageRef.child("post").child(postId).delete();
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postId).collection('comments').get();
    commentsSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    Get.offAll(() => BottomNavigationTabBar());
  }

  Future<bool> likePost(
      String postId, String uid, List likes, String ownerId) async {
    bool res = false;

    try {
      print("helloo");
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
        res = false;
      } else {
        // else we need to add uid to the likes array
        postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
        res = true;
      }
    } catch (err) {
      print(err.toString());
    }
    return res;
  }

  // Future<bool> likePost(String ownerId, String postId) async {
  //   var showlike = false.obs;
  //   try {
  //     DocumentSnapshot doc =
  //         await postsRef.doc(ownerId).collection('userPosts').doc(postId).get();

  //     if ((doc.data() as dynamic)['likes'].contains(currentUserId)) {
  //       await postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
  //         'likes': FieldValue.arrayRemove([currentUserId])
  //       });

  //       showlike.value = false;
  //     } else {
  //       await postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
  //         'likes': FieldValue.arrayUnion([currentUserId])
  //       });
  //       showlike.value = true;
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  //   return showlike.value;
  // }
}
