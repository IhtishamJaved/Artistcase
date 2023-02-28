import 'package:artistcase/pages/SplashScreen/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'constant/sizeconfig.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    timeDilation = 2.0;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig().init(constraints, orientation);
            SystemChrome.setPreferredOrientations(
              [
                DeviceOrientation.portraitUp,
              ],
            );
            return GetMaterialApp(
              themeMode: ThemeMode.dark,
              title: "Artistcase",
              theme: ThemeData(
                fontFamily: "OpenSans",
              ),
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
            );
          },
        );
      },
    );
  }
}
