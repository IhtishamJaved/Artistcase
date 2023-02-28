import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../constant/constant.dart';
import '../../constant/utilities.dart';

import '../../controller/auth_controller.dart';
import '../../services/firestoremethod.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_screen.dart';
import '../board_cast_screen/board_cast_screen.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  Uint8List image;
  DocumentSnapshot userDoc;
  final authcontroller = Get.put(AuthController());

  @override
  void initState() {
    getuserdat();
    super.initState();
  }

  getuserdat() async {
    userDoc = await firestore
        .collection("users")
        .doc(firebaseAuth.currentUser.uid)
        .get();
    print(userDoc);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  goLiveStream() async {
    setState(() {
      authcontroller.liveloader.value = true;
    });
    String channelId = await FirestoreMethods()
        .startLiveStream(context, _titleController.text, image);

    print(channelId);

    if (channelId.isNotEmpty) {
      showSnackBar(context, 'Livestream has started successfully!');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BroadcastScreen(
            isBroadcaster: true,
            channelId: channelId,
            uid: '${(userDoc.data() as dynamic)["id"]}',
            username: '${(userDoc.data() as dynamic)["username"]}',
          ),
        ),
      );
    }

    print(
      '${(userDoc.data() as dynamic)["id"]}',
    );
    print('${(userDoc.data() as dynamic)["username"]}');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => authcontroller.liveloader.value
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color.fromRGBO(46, 12, 58, 1),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Uint8List pickedImage = await pickImagess();
                              if (pickedImage != null) {
                                setState(() {
                                  image = pickedImage;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22.0,
                                vertical: 20.0,
                              ),
                              child: image != null
                                  ? DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(10),
                                      dashPattern: const [10, 4],
                                      strokeCap: StrokeCap.round,
                                      color: Colors.white,
                                      child: Container(
                                        width: double.infinity,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(.05),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Image.memory(
                                          image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(10),
                                      dashPattern: const [10, 4],
                                      strokeCap: StrokeCap.round,
                                      color: Colors.blue,
                                      child: Container(
                                        width: double.infinity,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(.05),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.folder_open,
                                              color: Colors.blue,
                                              size: 40,
                                            ),
                                            const SizedBox(height: 15),
                                            Text(
                                              'Select your thumbnail',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Title',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: CustomTextField(
                                  controller: _titleController,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: CustomButton(
                          text: 'Go Live!',
                          onTap: goLiveStream,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ));
  }
}
