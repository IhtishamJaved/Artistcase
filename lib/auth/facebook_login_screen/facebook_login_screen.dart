import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../models/users_second_model.dart';
import '../../widgets/loading_screen.dart';
import '../login_screen/login_screen.dart';

class FaceBookLogInScreen extends StatefulWidget {
  // const start({ Key? key }) : super(key: key);

  @override
  _FaceBookLogInScreenState createState() => _FaceBookLogInScreenState();
}

class _FaceBookLogInScreenState extends State<FaceBookLogInScreen> {
  var user = UsersModel().obs;
  final authcontroller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(
      () => authcontroller.facebookBool.value
          ? Loading()
          : Scaffold(
              body: Container(
                height: size.height,
                width: size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromRGBO(187, 85, 234, 1),
                      Color.fromRGBO(134, 100, 244, 1),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: (size.height / 100) * 17,
                      width: (size.width / 100) * 17,
                      child: Image.asset('images/Icon_1.png'),
                    ),
                    Text(
                      "Artistcase",
                      style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(255, 255, 255, 1)),
                    ),
                    SizedBox(height: (size.height / 100) * 2),
                    Text(
                      "Let’s Create your Account",
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(255, 255, 255, 1)),
                    ),
                    SizedBox(height: (size.height / 100) * 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogInScreen(),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: (size.width / 100) * 70,
                        height: (size.height / 100) * 6.4,
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(255, 255, 255, 1)),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                              color: Color.fromRGBO(255, 255, 255, 1)),
                        ),
                      ),
                    ),
                    SizedBox(height: (size.height / 100) * 5),
                    InkWell(
                      onTap: () {
                        setState(() {
                          authcontroller.facebookBool.value = true;
                        });
                        authcontroller.signInWithFacebook();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: (size.width / 100) * 70,
                        height: (size.height / 100) * 6.4,
                        child: Text(
                          "LOGIN WITH FACEBOOK",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
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
                  ],
                ),
              ),
            ),
    );
  }
}
