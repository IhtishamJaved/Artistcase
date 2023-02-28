import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String displayName;
  final String avatarUrl;
  final String ownerId;
  final List<StoryFile> file;

  StoryModel({this.displayName, this.avatarUrl, this.ownerId, this.file});

  factory StoryModel.fromDocument(DocumentSnapshot doc) {
    ///make list of files before returning [StoryModel] instance
    List<StoryFile> list =
        (doc['file'] as List).map((e) => StoryFile.fromMap(e)).toList();

    return StoryModel(
      displayName: doc['displayName'] ?? '',
      ownerId: doc['ownerId'] ?? '',
      avatarUrl: doc['avatarUrl'] ?? '',
      file: list,
    );
  }
}

class StoryFile {
  final String filetype;
  final String mediaUrl;
  
  final String postId;
  final String caption;

  StoryFile({this.mediaUrl, this.postId, this.filetype,this.caption});

  factory StoryFile.fromMap(Map doc) {
    return StoryFile(
        filetype: doc['filetype'],
        mediaUrl: doc['mediaUrl'],
        postId: doc['postId'],
        caption: doc['caption']
        );
  }
}




// class VideoModel {
//   String username;
//   String uid;
//   String id;
//   List likes;
//   int commentCount;
//   int shareCount;
//   String songName;
//   String caption;
//   String videoUrl;
//   String thumbnail;
//   String profilePhoto;

//   VideoModel({
//     required this.username,
//     required this.uid,
//     required this.id,
//     required this.likes,
//     required this.commentCount,
//     required this.shareCount,
//     required this.songName,
//     required this.caption,
//     required this.videoUrl,
//     required this.profilePhoto,
//     required this.thumbnail,
//   });

//   Map<String, dynamic> toJson() => {
//         "username": username,
//         "uid": uid,
//         "profilePhoto": profilePhoto,
//         "id": id,
//         "likes": likes,
//         "commentCount": commentCount,
//         "shareCount": shareCount,
//         "songName": songName,
//         "caption": caption,
//         "videoUrl": videoUrl,
//         "thumbnail": thumbnail,
//       };

//   static VideoModel fromSnap(DocumentSnapshot snap) {
//     var snapshot = snap.data() as Map<String, dynamic>;

//     return VideoModel(
//       username: snapshot['username'],
//       uid: snapshot['uid'],
//       id: snapshot['id'],
//       likes: snapshot['likes'],
//       commentCount: snapshot['commentCount'],
//       shareCount: snapshot['shareCount'],
//       songName: snapshot['songName'],
//       caption: snapshot['caption'],
//       videoUrl: snapshot['videoUrl'],
//       profilePhoto: snapshot['profilePhoto'],
//       thumbnail: snapshot['thumbnail'],
//     );
//   }
// }