import 'package:flutter/material.dart';

import '../constant/sizeconfig.dart';

class DefaultContainer extends StatelessWidget {
  final String buttonname;
  // ignore: prefer_typing_uninitialized_variables
  final height;
  // ignore: prefer_typing_uninitialized_variables
  final width;
  final Color buttoncolor;
  // ignore: prefer_typing_uninitialized_variables
  final press;
  final FontWeight fontWeight;
  const DefaultContainer(
      {Key key,
      @required this.buttonname,
      @required this.height,
      @required this.width,
      @required this.buttoncolor,
      @required this.press,
      @required this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: buttoncolor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            buttonname,
            style: TextStyle(
              fontSize: 3 * SizeConfig.textMultiplier,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(97, 59, 219, 1),
            ),
          ),
        ),
      ),
    );
  }
}
