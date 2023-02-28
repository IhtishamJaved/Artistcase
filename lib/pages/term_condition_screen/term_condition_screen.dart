import 'package:artistcase/constant/sizeconfig.dart';
import 'package:flutter/material.dart';

class TermConditionScreen extends StatelessWidget {
  const TermConditionScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(46, 12, 58, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 4 * SizeConfig.heightMultiplier,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35.0, top: 20),
            child: Container(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset("images/pop.png"),
              ),
            ),
          ),
          SizedBox(
            height: 10 * SizeConfig.heightMultiplier,
          ),
          Center(
            child: Text("Term And Condition",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    color: Color.fromRGBO(255, 255, 255, 1))),
          ),
          SizedBox(
            height: 4 * SizeConfig.heightMultiplier,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 10 * SizeConfig.widthMultiplier),
            child: Text(
              "What Are Terms and Conditions? A terms and conditions agreement outlines the website administrator's rules regarding user behavior and provides information about the actions the website administrator can and will perform. Essentially, your terms and conditions text is a contract between your website and its users.",
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
            ),
          )
        ],
      ),
    );
  }
}
