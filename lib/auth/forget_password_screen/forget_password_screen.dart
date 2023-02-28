// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:socialappflutter/widgets/loading_screen.dart';

// import '../../constant/sizeconfig.dart';
// import '../../controller/auth_controller.dart';
// import '../signup_screen/sign_up_screen.dart';

// class ForgetPasswordScreen extends StatefulWidget {
//   // const login({ Key? key }) : super(key: key);

//   @override
//   _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
// }

// class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
//   var globalkey = GlobalKey<FormState>();
//   bool isPasswordVisible = false;

//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();

//   final authcontroller = Get.put(AuthController());
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Obx(
//       () => authcontroller.signinshow.value
//           ? Loading()
//           : Scaffold(
//               body: SingleChildScrollView(
//                 child: Container(
//                   height: size.height,
//                   width: size.width,
//                   decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                           colors: [
//                         Color.fromRGBO(187, 85, 234, 1),
//                         Color.fromRGBO(134, 100, 244, 1),
//                       ])),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         height: (size.height / 100) * 15,
//                         width: (size.width / 100) * 15,
//                         child: Image.asset('images/Icon_1.png'),
//                       ),
//                       Text(
//                         "Artistcase",
//                         style: TextStyle(
//                             fontSize: 28,
//                             fontFamily: 'Montserrat',
//                             fontWeight: FontWeight.w500,
//                             color: Color.fromRGBO(255, 255, 255, 1)),
//                       ),
//                       SizedBox(height: (size.height / 100) * 1),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Welcome",
//                             style: TextStyle(
//                                 fontSize: 22,
//                                 fontFamily: 'Montserrat',
//                                 fontWeight: FontWeight.w400,
//                                 color: Color.fromRGBO(255, 255, 255, 1)),
//                           ),
//                           Text(
//                             "Back !",
//                             style: TextStyle(
//                                 fontSize: 25,
//                                 fontFamily: 'Montserrat',
//                                 fontWeight: FontWeight.w600,
//                                 color: Color.fromRGBO(255, 255, 255, 1)),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: (size.height / 100) * 10),
//                       Form(
//                         key: globalkey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 50),
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   'Enter your email',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontFamily: 'Montserrat',
//                                     fontWeight: FontWeight.w500,
//                                     color: Color.fromRGBO(255, 255, 255, 1),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: (size.height / 100) * 1.4),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 50),
//                               child: TextFormField(
//                                 controller: email,
//                                 validator: (value) {
//                                   if (value.isEmpty) {
//                                     return 'please enter email';
//                                   }
//                                   return null;
//                                 },
//                                 decoration: InputDecoration(
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       26.0,
//                                     ),
//                                     borderSide: BorderSide(
//                                         color: Color.fromRGBO(
//                                           255,
//                                           255,
//                                           255,
//                                           1,
//                                         ),
//                                         width: 1.3),
//                                   ),

//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       26.0,
//                                     ),
//                                     borderSide: BorderSide(
//                                         color: Color.fromRGBO(
//                                           255,
//                                           255,
//                                           255,
//                                           1,
//                                         ),
//                                         width: 1.3),
//                                   ),

//                                   errorBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       26.0,
//                                     ),
//                                     borderSide: BorderSide(
//                                         color: Color.fromRGBO(
//                                           255,
//                                           255,
//                                           255,
//                                           1,
//                                         ),
//                                         width: 1.3),
//                                   ),

//                                   focusedErrorBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       26.0,
//                                     ),
//                                     borderSide: BorderSide(
//                                         color: Color.fromRGBO(
//                                           255,
//                                           255,
//                                           255,
//                                           1,
//                                         ),
//                                         width: 1.3),
//                                   ),
//                                   // floatingLabelBehavior: FloatingLabelBehavior.always,
//                                   hintText: 'Email',
//                                   contentPadding: EdgeInsets.only(left: 22.0),
//                                   hintStyle: TextStyle(
//                                     fontSize: 14,
//                                     fontFamily: 'Montserrat',
//                                     fontWeight: FontWeight.w500,
//                                     color: Color.fromRGBO(
//                                       255,
//                                       255,
//                                       255,
//                                       1,
//                                     ),
//                                   ),
//                                 ),
//                                 style: TextStyle(
//                                   color: Color.fromRGBO(
//                                     255,
//                                     255,
//                                     255,
//                                     1,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Obx(() => authcontroller.showincorrectEmail.value
//                                 ? Padding(
//                                     padding: EdgeInsets.only(
//                                         left: 18 * SizeConfig.widthMultiplier),
//                                     child: Text(
//                                       "Incorrect Email",
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontFamily: 'Montserrat',
//                                         fontWeight: FontWeight.w300,
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox()),
//                             SizedBox(height: (size.height / 100) * 4.4),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 50),
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   'Password',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontFamily: 'Montserrat',
//                                     fontWeight: FontWeight.w500,
//                                     color: Color.fromRGBO(255, 255, 255, 1),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: (size.height / 100) * 1.4),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 50),
//                               child: TextFormField(
//                                 controller: password,
//                                 validator: (value) {
//                                   if (value.isEmpty) {
//                                     return 'please enter password';
//                                   }
//                                   return null;
//                                 },
//                                 obscureText: !isPasswordVisible,
//                                 decoration: InputDecoration(
//                                   suffixIcon: InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           isPasswordVisible =
//                                               !isPasswordVisible;
//                                         });
//                                       },
//                                       child: Icon(
//                                           isPasswordVisible
//                                               ? Icons.visibility
//                                               : Icons.visibility_off,
//                                           color: Colors.white)),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       26.0,
//                                     ),
//                                     borderSide: BorderSide(
//                                         color: Color.fromRGBO(
//                                           255,
//                                           255,
//                                           255,
//                                           1,
//                                         ),
//                                         width: 1.3),
//                                   ),

//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       26.0,
//                                     ),
//                                     borderSide: BorderSide(
//                                         color: Color.fromRGBO(
//                                           255,
//                                           255,
//                                           255,
//                                           1,
//                                         ),
//                                         width: 1.3),
//                                   ),

//                                   errorBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       26.0,
//                                     ),
//                                     borderSide: BorderSide(
//                                         color: Color.fromRGBO(
//                                           255,
//                                           255,
//                                           255,
//                                           1,
//                                         ),
//                                         width: 1.3),
//                                   ),
//                                   focusedErrorBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       26.0,
//                                     ),
//                                     borderSide: BorderSide(
//                                         color: Color.fromRGBO(
//                                           255,
//                                           255,
//                                           255,
//                                           1,
//                                         ),
//                                         width: 1.3),
//                                   ),
//                                   // floatingLabelBehavior: FloatingLabelBehavior.always,
//                                   hintText: 'Password',
//                                   contentPadding: EdgeInsets.only(left: 22.0),
//                                   hintStyle: TextStyle(
//                                     fontSize: 14,
//                                     fontFamily: 'Montserrat',
//                                     fontWeight: FontWeight.w500,
//                                     color: Color.fromRGBO(
//                                       255,
//                                       255,
//                                       255,
//                                       1,
//                                     ),
//                                   ),
//                                 ),
//                                 style: TextStyle(
//                                   color: Color.fromRGBO(
//                                     255,
//                                     255,
//                                     255,
//                                     1,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Obx(
//                               () => authcontroller.showincorrectpassword.value
//                                   ? Padding(
//                                       padding: EdgeInsets.only(
//                                           left:
//                                               18 * SizeConfig.widthMultiplier),
//                                       child: Text(
//                                         "Incorrect Password",
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           fontFamily: 'Montserrat',
//                                           fontWeight: FontWeight.w300,
//                                           color: Colors.red,
//                                         ),
//                                       ),
//                                     )
//                                   : SizedBox(),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: (size.height / 100) * 2.4),
//                       Padding(
//                         padding: const EdgeInsets.only(right: 40),
//                         child: Align(
//                             alignment: Alignment.centerRight,
//                             child: Text(
//                               "Forgot password",
//                               style: TextStyle(
//                                   fontSize: 13,
//                                   fontFamily: 'Montserrat',
//                                   fontWeight: FontWeight.w600,
//                                   color: Color.fromRGBO(255, 255, 255, 1)),
//                             )),
//                       ),
//                       SizedBox(height: (size.height / 100) * 4.4),
//                       InkWell(
//                         onTap: () {
//                           if (globalkey.currentState.validate()) {
//                             setState(() {
//                               authcontroller.signinshow.value = true;
//                               authcontroller.showincorrectEmail.value = false;
//                               authcontroller.showincorrectpassword.value =
//                                   false;
//                             });
//                             authcontroller.loginUser(
//                                 email.text.trim(), password.text.trim());
//                           }
//                         },
//                         child: Container(
//                           alignment: Alignment.center,
//                           width: (size.width / 100) * 75,
//                           height: (size.height / 100) * 6.4,
//                           child: Text(
//                             "Sign in",
//                             style: TextStyle(
//                                 fontSize: 15,
//                                 fontFamily: 'Montserrat',
//                                 fontWeight: FontWeight.w700,
//                                 color: Color.fromRGBO(97, 59, 219, 1)),
//                           ),
//                           decoration: BoxDecoration(
//                             color: Color.fromRGBO(255, 255, 255, 1),
//                             borderRadius: BorderRadius.circular(26),
//                             border: Border.all(
//                                 color: Color.fromRGBO(255, 255, 255, 1)),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: (size.height / 100) * 3),
//                       Align(
//                           alignment: Alignment.bottomCenter,
//                           child: InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => Signup()));
//                               },
//                               child: Text('Have an account? Sign up',
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       fontFamily: 'Montserrat',
//                                       fontWeight: FontWeight.w600,
//                                       color:
//                                           Color.fromRGBO(255, 255, 255, 1))))),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/sizeconfig.dart';
import '../../controller/auth_controller.dart';
import '../../widgets/common_text_field.dart';
import '../../widgets/default_container.dart';
import '../../widgets/loading_screen.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController email = TextEditingController();

  final authcontrolller = Get.put(AuthController());
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Obx(() => authcontrolller.resetshow.value
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Container(
                      height: 100 * SizeConfig.heightMultiplier,
                      width: 100 * SizeConfig.widthMultiplier,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromRGBO(187, 85, 234, 1),
                            Color.fromRGBO(134, 100, 244, 1),
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // SizedBox(
                              //   height: 2 * SizeConfig.heightMultiplier,
                              // ),
                              Text(
                                "Reset Password",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Source Sans Pro",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 3.5 * SizeConfig.textMultiplier,
                                ),
                              ),
                              SizedBox(
                                height: 6 * SizeConfig.heightMultiplier,
                              ),
                              CommonTextFeild(
                                controller: authcontrolller.resetcontroller,
                                hidetext: false,
                                maxlines: 1,
                                hinttext: "Email",
                                keyboardtype: TextInputType.emailAddress,
                                showicon: false,
                                preffixicon: Icons.email,
                                validations: (value) {
                                  if (value.isEmpty) {
                                    return "Please Enter Email";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 3 * SizeConfig.heightMultiplier,
                              ),
                              DefaultContainer(
                                  fontWeight: FontWeight.w600,
                                  buttonname: "Reset",
                                  height: 8.3 * SizeConfig.heightMultiplier,
                                  width: 80 * SizeConfig.widthMultiplier,
                                  buttoncolor: Colors.white,
                                  press: () async {
                                    // authcontrolller.resetpassword();

                                    if (_formkey.currentState.validate()) {
                                      authcontrolller.resetpassword();
                                      setState(() {
                                        authcontrolller.resetshow.value = true;
                                      });
                                      print(authcontrolller.signinshow);
                                    }
                                  }),
                              // // Loading
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Loading(
                              //               bg: Colors.transparent,
                              //             )));
                              // //FIREBASE
                              // bool value =
                              //     await _repository.resetPassword(email.text);
                              //     if (value) {
                              //       Navigator.pop(context);
                              //       //NAVIGATION
                              //       // Navigator.pushReplacement(
                              //       //     context,
                              //       //     MaterialPageRoute(
                              //       //         builder: (context) => Decider()));
                              //       Fluttertoast.showToast(
                              //           msg:
                              //               "Check your mail to reset new password",
                              //           toastLength: Toast.LENGTH_SHORT,
                              //           gravity: ToastGravity.BOTTOM,
                              //           timeInSecForIosWeb: 3,
                              //           backgroundColor: Colors.grey[500],
                              //           fontSize: 14);
                              //     } else {
                              //       Navigator.pop(context);
                              //       Fluttertoast.showToast(
                              //           msg: "Invalid email",
                              //           toastLength: Toast.LENGTH_SHORT,
                              //           gravity: ToastGravity.BOTTOM,
                              //           timeInSecForIosWeb: 3,
                              //           backgroundColor: Colors.grey[500],
                              //           // textColor: theme.primaryColor,
                              //           fontSize: 14);
                              //     }
                              //   } else {
                              //     Fluttertoast.showToast(
                              //         msg: "Enter email",
                              //         toastLength: Toast.LENGTH_SHORT,
                              //         gravity: ToastGravity.BOTTOM,
                              //         timeInSecForIosWeb: 3,
                              //         backgroundColor: Colors.red,
                              //         // textColor: theme.primaryColor,
                              //         fontSize: 14);
                              //   }
                              // }
                              //
                              //
                              //
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
  }
}
