import 'package:flutter/material.dart';

import '../../../constant/sizeconfig.dart';
import '../second_upsplash_scrren/second_upsplash_screen.dart';

class UnSplashScreen extends StatefulWidget {
  // const unsplash1({ Key? key }) : super(key: key);

  @override
  State<UnSplashScreen> createState() => _UnSplashScreenState();
}

class _UnSplashScreenState extends State<UnSplashScreen> {
  final theImage = Image.asset("images/unsplash1.jpg");
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 100 * SizeConfig.heightMultiplier,
            width: double.infinity,
            // //    color: Colors.blue,
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
                    "Let the world connect \n with Artistcase",
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondUnSplashScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: (size.height / 100) * 12,
                      width: (size.width / 100) * 12,
                      child: Image.asset('images/round_arrow.png'),
                    ))
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
