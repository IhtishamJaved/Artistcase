import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/facebook_login_screen/facebook_login_screen.dart';
import '../../../constant/sizeconfig.dart';


class SecondUnSplashScreen extends StatefulWidget {
  @override
  State<SecondUnSplashScreen> createState() => _SecondUnSplashScreenState();
}

class _SecondUnSplashScreenState extends State<SecondUnSplashScreen> {
  // const ({ Key? key }) : super(key: key);
  final theImage = Image.asset("images/unsplash2.jpg");

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 100 * SizeConfig.heightMultiplier,
            width: double.infinity,
            child: FittedBox(
              child: theImage,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "Share your Feelings",
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "and moment with us",
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => FaceBookLogInScreen());
                  },
                  child: Container(
                    height: (size.height / 100) * 12,
                    width: (size.width / 100) * 12,
                    child: Image.asset('images/round_arrow.png'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    precacheImage(theImage.image, context);
    super.didChangeDependencies();
  }
}
