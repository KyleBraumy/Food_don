import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String title;
  double? letterspacing;
   CustomText(this.title,this.letterspacing, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontFamily: 'Gotham',
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        letterSpacing: letterspacing==null?
          0:
          letterspacing,
      ),

    );
  }
}
class CustomText2 extends StatelessWidget {
  final String title;
   CustomText2(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontFamily: 'Gotham',
          fontWeight: FontWeight.bold,

      ),

    );
  }
}
