import 'package:artistcase/pages/SplashScreen/upsplash_screen/upsplash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:socialapp/services/helper_method.dart';
import 'dart:async';


import '../../constant/constant.dart';
import '../../roots/bottom_navigation_bar.dart';

// import 'package:socialapp/views/SignupScreen.dart';
// import 'package:socialapp/views/walkthrough1.dart';

class SplashScreen extends StatefulWidget {
  // const Splash({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      if (firebaseAuth.currentUser == null) {
        Get.offAll(() => UnSplashScreen());
        // user not logged ==> Login Screen
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => UnSplashScreen(),
        //     ),
        //     (route) => false);
      } else {
        Get.offAll(() => BottomNavigationTabBar());
        // user already logged in ==> Home Screen
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(builder: (_) => BottomNavigationTabBar()),
        //     (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(
              // height: (size.height/100)*20,
              // width: (size.height/100)*20,
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      "images/splash.png",
                      height: (size.height / 100) * 24,
                      width: (size.height / 100) * 22,
                    ),
                    // SizedBox( height: (size.height/100)*5,),
                    // Text(
                    //   "Artistcase",
                    //   style: TextStyle(
                    //       color: Color.fromRGBO(0, 0, 0, 1),
                    //       fontWeight: FontWeight.w500,
                    //       fontFamily: 'Montserrat',
                    //       fontSize: 28),
                    // )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }

  @override
  void didChangeDependencies() {
    precacheImage(AssetImage('images/unsplash1.jpg'), context);
    super.didChangeDependencies();
  }
}
