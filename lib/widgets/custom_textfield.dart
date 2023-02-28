import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onTap;
  const CustomTextField({
    Key key,
    @required this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: onTap,
      controller: controller,
      style: TextStyle(
        fontSize: 14,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          )),
    );
  }
}
