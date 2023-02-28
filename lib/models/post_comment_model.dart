import 'package:cloud_firestore/cloud_firestore.dart';

class PostCommentModel {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  final String postId;
  final String commentLenght;
  final List likelist;

  PostCommentModel({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
    this.postId,
    this.commentLenght,
    this.likelist,
  });

  factory PostCommentModel.fromDocument(DocumentSnapshot doc) {
    return PostCommentModel(
        username: doc['username'],
        userId: doc['userId'],
        comment: doc['comment'],
        timestamp: doc['timestamp'],
        avatarUrl: doc['avatarUrl'],
        commentLenght: doc["CommentLenght"],
        postId: doc["postId"],
        likelist: doc["likes"]);
  }
}
