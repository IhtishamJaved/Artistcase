import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserModel {
  String username;
  String email;
  String phonenumber;
  String uid;
  String imageUrl;

  UserModel({
    @required this.uid,
    @required this.username,
    @required this.email,
    @required this.phonenumber,
    @required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "id": uid,
        "phonenumber": phonenumber,
        "photoUrl": imageUrl,
      };

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
        email: snapshot['email'],
        phonenumber: snapshot['phonenumber'],
        uid: snapshot['id'],
        username: snapshot['username'],
        imageUrl: snapshot["photoUrl"]);
  }
}
