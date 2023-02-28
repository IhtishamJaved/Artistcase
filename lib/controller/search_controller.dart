// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';

// import '../constant/constant.dart';
// import '../models/user_model.dart';

// class SearchController extends GetxController {
//   final Rx<List<UserModel>> _searchedUsers = Rx<List<UserModel>>([]);

//   List<UserModel> get searchedUsers => _searchedUsers.value;

//   searchUser(String typedUser) async {
//     print("fdhdh");
//     print(typedUser);
//     _searchedUsers.bindStream(firestore
//         .collection('users')
//         .where('username', isGreaterThanOrEqualTo: typedUser)
//         .snapshots()
//         .map((QuerySnapshot query) {
//       List<UserModel> retVal = [];
//       for (var elem in query.docs) {
//         retVal.add(UserModel.fromSnap(elem));
//       }
//       print(retVal);
//       return retVal;
//     }));
//   }

//   @override
//   void dispose() {
//     searchedUsers.clear();
//     _searchedUsers.value.clear();
//     super.dispose();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  TextEditingController searchC;

  // var queryAwal = [].obs;
  // var tempSearch = [].obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void searchFriend(String data, String email) async {
    print("SEARCH : $data");
    print(email);

    if (data.length == 0) {
      queryAwal.value = [];
      tempSearch.value = [];
    } else {
      var capitalized2 = data.substring(0, 1).toLowerCase() + data.substring(1);
      print("helo");
      print(capitalized2);
      // print(cacapitalized2);

      if (queryAwal.length == 0 && data.length == 1) {
        // fungsi yang akan dijalankan pada 1 huruf ketikan pertama
        CollectionReference users = firestore.collection("users");
        final keyNameResult = await users
            .where("keyName", isEqualTo: data.substring(0, 1).toUpperCase())
            .where("email", isNotEqualTo: email)
            .get();

        print("TOTAL DATA : ${keyNameResult.docs.length}");
        if (keyNameResult.docs.length > 0) {
          for (int i = 0; i < keyNameResult.docs.length; i++) {
            queryAwal.add(keyNameResult.docs[i].data() as Map<String, dynamic>);
          }
          print("QUERY RESULT : ");
          print(queryAwal);
        } else {
          print("TIDAK ADA DATA");
        }
      }

      if (queryAwal.length != 0) {
        tempSearch.value = [];
        queryAwal.forEach((element) {
          if (element["username"].startsWith(capitalized2)) {
            tempSearch.add(element);
          }
        });
        print(tempSearch);
      }
    }

    queryAwal.refresh();
    tempSearch.refresh();
  }

  @override
  void onInit() {
    searchC = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    searchC.dispose();
    tempSearch.close();

    super.onClose();
  }

  @override
  void dispose() {
    tempSearch.close();
    super.dispose();
  }
}
