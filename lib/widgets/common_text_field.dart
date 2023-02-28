import 'package:flutter/material.dart';

import '../constant/sizeconfig.dart';

// ignore: must_be_immutable
class CommonTextFeild extends StatefulWidget {
  CommonTextFeild(
      {Key key,
      @required this.controller,
      @required this.hidetext,
      @required this.maxlines,
      @required this.hinttext,
      @required this.keyboardtype,
      @required this.showicon,
      @required this.validations,
      @required this.preffixicon})
      : super(key: key);
  final TextEditingController controller;
  final String hinttext;
  bool hidetext;
  final TextInputType keyboardtype;
  final bool showicon;
  final int maxlines;

  final validations;

  final preffixicon;

  @override
  _CommonTextFeildState createState() => _CommonTextFeildState();
}

class _CommonTextFeildState extends State<CommonTextFeild> {
  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
  ];
  void initState() {
    _focusNodes.forEach((node) {
      node.addListener(() {
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10 * SizeConfig.heightMultiplier,
      width: 80 * SizeConfig.widthMultiplier,
      //    padding: EdgeInsets.only(top: 1 * SizeConfig.heightMultiplier),
      // decoration: BoxDecoration(
      //   color: Color.fromRGBO(66, 66, 71, 1),
      //   // borderRadius: BorderRadius.circular(15),
      // ),
      child: TextFormField(
        style: TextStyle(
          color: Colors.black54,
          fontFamily: 'Source Sans Pro',
          fontWeight: FontWeight.w600,
          fontSize: 2 * SizeConfig.textMultiplier,
        ),
        obscureText: widget.hidetext,
        controller: widget.controller,
        keyboardType: widget.keyboardtype,
        maxLines: widget.maxlines,
        validator: widget.validations,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
          // enabled: ,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
          // contentPadding: EdgeInsets.only(
          //     top: 1.8 * SizeConfig.heightMultiplier,
          //     left: 3 * SizeConfig.widthMultiplier,
          //     right: 3 * SizeConfig.widthMultiplier),
          errorStyle: TextStyle(
            height: 0.5,
          ),
          // isDense: true,

          prefixIcon: Icon(
            widget.preffixicon,
            color: _focusNodes[0].hasFocus ? Colors.green : Colors.grey,
          ),

          //  border: InputBorder.none,
          hintText: widget.hinttext,
          suffixIcon: widget.showicon
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      widget.hidetext = !widget.hidetext;
                    });
                  },
                  icon: widget.hidetext
                      ? Icon(Icons.visibility_off, color: Colors.grey)
                      : Icon(Icons.visibility, color: Colors.blue),
                )
              : null,
          hintStyle: TextStyle(
            color: Color.fromRGBO(150, 150, 154, 1),
            fontFamily: 'Source Sans Pro',
            fontWeight: FontWeight.w600,
            fontSize: 2 * SizeConfig.textMultiplier,
          ),
        ),
      ),
    );
  }
}
