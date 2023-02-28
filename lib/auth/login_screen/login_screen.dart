import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/sizeconfig.dart';
import '../../controller/auth_controller.dart';
import '../../widgets/loading_screen.dart';
import '../forget_password_screen/forget_password_screen.dart';
import '../signup_screen/sign_up_screen.dart';

class LogInScreen extends StatefulWidget {
  // const login({ Key? key }) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  var globalkey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final authcontroller = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(
      () => authcontroller.signinshow.value
          ? Loading()
          : Scaffold(
              body: SingleChildScrollView(
                child: Container(
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
                        height: (size.height / 100) * 15,
                        width: (size.width / 100) * 15,
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
                      SizedBox(height: (size.height / 100) * 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome",
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                          Text(
                            "Back !",
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                        ],
                      ),
                      SizedBox(height: (size.height / 100) * 10),
                      Form(
                        key: globalkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Enter your email',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: (size.height / 100) * 1.4),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              child: TextFormField(
                                controller: email,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'please enter email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      26.0,
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 1.3),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      26.0,
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 1.3),
                                  ),

                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      26.0,
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 1.3),
                                  ),

                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      26.0,
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 1.3),
                                  ),
                                  // floatingLabelBehavior: FloatingLabelBehavior.always,
                                  hintText: 'Email',
                                  contentPadding: EdgeInsets.only(left: 22.0),
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
                            Obx(
                              () => authcontroller.showincorrectEmail.value
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left:
                                              18 * SizeConfig.widthMultiplier),
                                      child: Text(
                                        "Incorrect Email",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ),
                            SizedBox(height: (size.height / 100) * 1),
                            Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: (size.height / 100) * 1.4),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              child: TextFormField(
                                controller: password,
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
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      26.0,
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 1.3),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      26.0,
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 1.3),
                                  ),

                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      26.0,
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 1.3),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      26.0,
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        width: 1.3),
                                  ),
                                  // floatingLabelBehavior: FloatingLabelBehavior.always,
                                  hintText: 'Password',
                                  contentPadding: EdgeInsets.only(left: 22.0),
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
                            Obx(
                              () => authcontroller.showincorrectpassword.value
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left:
                                              18 * SizeConfig.widthMultiplier),
                                      child: Text(
                                        "Incorrect Password",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: (size.height / 100) * 2.4),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => ResetPassword());
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Forgot password",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(255, 255, 255, 1)),
                              )),
                        ),
                      ),
                      SizedBox(height: (size.height / 100) * 4.4),
                      InkWell(
                        onTap: () {
                          if (globalkey.currentState.validate()) {
                            setState(() {
                              authcontroller.signinshow.value = true;
                              authcontroller.showincorrectEmail.value = false;
                              authcontroller.showincorrectpassword.value =
                                  false;
                            });
                            authcontroller.loginUser(
                                email.text.trim(), password.text.trim());
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: (size.width / 100) * 75,
                          height: (size.height / 100) * 6.4,
                          child: Text(
                            "Sign in",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(97, 59, 219, 1),
                            ),
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
                                        builder: (context) => Signup()));
                              },
                              child: Text('Have an account? Sign up',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Color.fromRGBO(255, 255, 255, 1))))),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
