import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


import '../../constant/sizeconfig.dart';
import '../../controller/auth_controller.dart';
import '../../widgets/loading_screen.dart';
import '../login_screen/login_screen.dart';

class Signup extends StatefulWidget {
//  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  var globalkey = GlobalKey<FormState>();
  String password = '';
  // bool isPasswaordVisible = false;
  bool isPasswordVisible = false;
  bool isPasswordVisible1 = false;

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController textpassword = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  final authcontroller = Get.put(AuthController());
  var file;
  bool showerror = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(
      () => authcontroller.showsigUp.value
          ? Loading()
          : Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: size.height,
                      width: size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                            Color.fromRGBO(187, 85, 234, 1),
                            Color.fromRGBO(134, 100, 244, 1),
                          ])),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              height: (size.height / 100) * 10,
                              width: (size.width / 100) * 15,
                              child: Image.asset('images/Icon_1.png'),
                            ),
                          ),
                          Text(
                            "Artistcase",
                            style: TextStyle(
                                fontSize: 28,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                          SizedBox(height: (size.height / 100) * 1),
                          Text(
                            "Create Your Account",
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                          SizedBox(height: (size.height / 100) * 0.3),
                          GestureDetector(
                            onTap: () {
                              selectImage(context);
                            },
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: file != null
                                      ? FileImage(file)
                                      : AssetImage("assets/images/nophoto.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Form(
                              key: globalkey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 40),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromRGBO(255, 255, 255, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    child: Container(
                                      height: (size.height / 100) * 7,
                                      child: TextFormField(
                                        controller: name,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'please enter name';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            // borderRadius: BorderRadius.circular(26.0,),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            // borderRadius: BorderRadius.circular(26.0,),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          hintText: 'Name',
                                          hintStyle: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[300]),
                                        ),
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: (size.height / 100) * 1),
                                  //email

                                  Padding(
                                    padding: const EdgeInsets.only(left: 40),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromRGBO(255, 255, 255, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    child: Container(
                                      height: (size.height / 100) * 7,
                                      child: TextFormField(
                                        controller: email,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'please enter email';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          hintText: 'Email',
                                          hintStyle: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[300]),
                                        ),
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => authcontroller.alreadyemail.value
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                left: 11 *
                                                    SizeConfig.widthMultiplier),
                                            child: Text(
                                              "Email is already in use",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.red),
                                            ),
                                          )
                                        : SizedBox(),
                                  ),
                                  SizedBox(height: (size.height / 100) * 1),
                                  //password

                                  Padding(
                                    padding: const EdgeInsets.only(left: 40),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Password',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1)))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    child: Container(
                                      height: (size.height / 100) * 7,
                                      child: TextFormField(
                                        controller: textpassword,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'please enter password';
                                          }
                                          return null;
                                        },
                                        obscureText: !isPasswordVisible,
                                        decoration: InputDecoration(
                                          suffixIcon: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isPasswordVisible =
                                                      !isPasswordVisible;
                                                });
                                              },
                                              child: Icon(
                                                  isPasswordVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.white)),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),

                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),

                                          errorBorder: UnderlineInputBorder(
                                            // borderRadius: BorderRadius.circular(26.0,),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),

                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            // borderRadius: BorderRadius.circular(26.0,),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          // floatingLabelBehavior: FloatingLabelBehavior.always,
                                          hintText: '**********',
                                          hintStyle: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[300]),
                                        ),
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Obx(() => authcontroller.weekpassword.value
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: 4 *
                                                  SizeConfig.widthMultiplier),
                                          child: Text(
                                            "Weak Password",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red),
                                          ),
                                        )
                                      : SizedBox()),
                                  SizedBox(height: (size.height / 100) * 1),
                                  //confirm password

                                  Padding(
                                    padding: const EdgeInsets.only(left: 40),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'confirm password',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromRGBO(255, 255, 255, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    child: Container(
                                      height: (size.height / 100) * 7,
                                      child: TextFormField(
                                        controller: confirmpassword,
                                        // ignore: missing_return
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return "Please Enter ConfirmPassword";
                                          }

                                          if (textpassword.text !=
                                              confirmpassword.text) {
                                            return "Password does not match";
                                          }
                                        },
                                        obscureText: !isPasswordVisible1,
                                        decoration: InputDecoration(
                                          suffixIcon: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isPasswordVisible1 =
                                                      !isPasswordVisible1;
                                                });
                                              },
                                              child: Icon(
                                                  isPasswordVisible1
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.white)),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),

                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),

                                          errorBorder: UnderlineInputBorder(
                                            // borderRadius: BorderRadius.circular(26.0,),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),

                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            // borderRadius: BorderRadius.circular(26.0,),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          // floatingLabelBehavior: FloatingLabelBehavior.always,

                                          hintText: '**********',
                                          hintStyle: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[300]),
                                        ),
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: (size.height / 100) * 1),
                                  //phone number

                                  Padding(
                                    padding: const EdgeInsets.only(left: 40),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('phone number',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1)))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    child: Container(
                                      height: (size.height / 100) * 7,
                                      child: TextFormField(
                                        controller: phonenumber,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'please enter phone number';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),

                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),

                                          errorBorder: UnderlineInputBorder(
                                            // borderRadius: BorderRadius.circular(26.0,),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),

                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            // borderRadius: BorderRadius.circular(26.0,),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                width: 1),
                                          ),
                                          // floatingLabelBehavior: FloatingLabelBehavior.always,
                                          hintText: '+120344567787',
                                          hintStyle: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[300]),
                                        ),
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  //save btn
                                  SizedBox(height: (size.height / 100) * 2),
                                ],
                              )),
                          InkWell(
                            onTap: () {
                              if (globalkey.currentState.validate()) {
                                if (file == null) {
                                  selectImage(context);

                                  print("error");
                                } else {
                                  setState(() {
                                    authcontroller.showsigUp.value = true;
                                    authcontroller.alreadyemail.value = false;
                                  });
                                  authcontroller.registeruser(
                                    name.text.trim(),
                                    email.text.trim(),
                                    textpassword.text.trim(),
                                    phonenumber.text.trim(),
                                    file,
                                  );
                                }
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: (size.width / 100) * 75,
                              height: (size.height / 100) * 6.4,
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromRGBO(97, 59, 219, 1)),
                              ),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                    color: Color.fromRGBO(255, 255, 255, 1)),
                              ),
                            ),
                          ),
                          SizedBox(height: (size.height / 100) * 3),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LogInScreen()));
                                  },
                                  child: Text('Already have an account?Log in',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromRGBO(
                                              255, 255, 255, 1))))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  getimageFromCamera() async {
    try {
      final pickedFile =
          // ignore: invalid_use_of_visible_for_testing_member
          await ImagePicker.platform
              .pickImage(source: ImageSource.camera, imageQuality: 50);

      setState(() {
        if (pickedFile.path == null) {
          file = null;
        } else {
          file = File(pickedFile.path);
        }
      });
      Get.back();
    } catch (e) {
      print(e.toString());
    }
  }

  getImageFromGallery() async {
    try {
      final pickedFile =
          // ignore: invalid_use_of_visible_for_testing_member
          await ImagePicker.platform
              .pickImage(source: ImageSource.gallery, imageQuality: 50);
      setState(() {
        file = File(pickedFile.path);
      });

      Get.back();
    } catch (e) {
      print(e.toString());
    }
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Select Image"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: getimageFromCamera),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: getImageFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }
}
