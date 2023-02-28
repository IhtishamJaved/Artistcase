import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../controller/auth_controller.dart';
import '../../controller/search_controller.dart';
import '../Profile_screen/profile_screen.dart';

class SearchView extends StatefulWidget {
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final authC = Get.put(AuthController());

  final controller = Get.put(SearchController());

  @override
  void dispose() {
    controller.tempSearch.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromRGBO(46, 12, 58, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(46, 12, 58, 1),
          title: TextFormField(
            style: TextStyle(
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              filled: false,
              hintText: 'Search',
              hintStyle: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) => controller.searchFriend(
              value,
              firebaseAuth.currentUser.email,
            ),
            onFieldSubmitted: (value) => controller.searchFriend(
              value,
              firebaseAuth.currentUser.email,
            ),
          ),
        ),
        body: Obx(
          () => controller.tempSearch.length == 0
              ? const Center(
                  child: Text(
                    'Search for users!',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: controller.tempSearch.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                profileId: controller.tempSearch[index]["id"]),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              controller.tempSearch[index]["photoUrl"] == null
                                  ? AssetImage("assets/images/nophoto.jpg")
                                  : CachedNetworkImageProvider(
                                      controller.tempSearch[index]["photoUrl"],
                                    ),
                        ),
                        title: Text(
                          controller.tempSearch[index]["username"],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ));
  }
}
