

import 'dart:convert';

UsersModel usersModelFromJson(String str) =>
    UsersModel.fromJson(json.decode(str));

String usersModelToJson(UsersModel data) => json.encode(data.toJson());

class UsersModel {
  UsersModel({
    this.uid,
    this.name,
    
    this.email,

    this.photoUrl,
    this.status,
    this.updatedTime,
    this.chats,
  });

  String uid;
  String name;

  String email;
 
  String photoUrl;
  String status;
  String updatedTime;
  List<ChatUser> chats;

  factory UsersModel.fromJson(Map<String, dynamic> json) => UsersModel(
        uid: json["id"],
        name: json["username"],
        
        email: json["email"],
        
        photoUrl: json["photoUrl"],
        status: json["status"],
        updatedTime: json["updatedTime"],
      );

  Map<String, dynamic> toJson() => {
        "id": uid,
        "name": name,
   
        "email": email,
     
        "photoUrl": photoUrl,
        "status": status,
        "updatedTime": updatedTime,
      };
}

class ChatUser {
  ChatUser({
    this.connection,
    this.chatId,
    this.lastTime,
    // ignore: non_constant_identifier_names
    this.total_unread,
  });

  String connection;
  String chatId;
  String lastTime;
  // ignore: non_constant_identifier_names
  int total_unread;

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        connection: json["connection"],
        chatId: json["chat_id"],
        lastTime: json["lastTime"],
        total_unread: json["total_unread"],
      );

  Map<String, dynamic> toJson() => {
        "connection": connection,
        "chat_id": chatId,
        "lastTime": lastTime,
        "total_unread": total_unread,
      };
}
