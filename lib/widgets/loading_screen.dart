import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ignore: must_be_immutable
class Loading extends StatelessWidget {
  String text;
  @required
  Color bg;
  Loading({this.text, this.bg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2b2c2e),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 110,
              height: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[800]),
              child: SpinKitFadingCircle(
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          Text(text ?? '',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              )),
        ],
      ),
    );
  }
}
