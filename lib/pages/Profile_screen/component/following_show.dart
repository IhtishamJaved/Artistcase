import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constant/constant.dart';
import '../profile_screen.dart';

class FollowingShow extends StatelessWidget {
  final String profileID;
  const FollowingShow({Key key, @required this.profileID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
            stream: followingRef
                .doc(profileID)
                .collection('userFollowing')
                .where("id", isNotEqualTo: profileID)
                .snapshots(),
            builder: (context, snapshot) {
              print(snapshot);
              print("hello");
              print(profileID);
              if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                profileId: snapshot.data.docs[index]["id"]),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              snapshot.data.docs[index]["photoUrl"] == null
                                  ? AssetImage("assets/images/nophoto.jpg")
                                  : CachedNetworkImageProvider(
                                      snapshot.data.docs[index]["photoUrl"],
                                    ),
                        ),
                        title: Text(
                          snapshot.data.docs[index]["username"],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return SizedBox();
            }),
      ],
    );
  }
}
