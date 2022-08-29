import 'dart:async';
import 'package:flutter/material.dart';
import 'wrapper.dart';


class Firstpage extends StatefulWidget {
  const Firstpage({Key? key}) : super(key: key);

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  @override
  void initState() {
    Timer(Duration(seconds: 4), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Wrapper()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    return const Scaffold(
        backgroundColor: Colors.green,
        body: Center(
          child: Text('FOODIE',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
              color: Colors.white,
              decoration:TextDecoration.underline,
            ),),
        )
    );
  }
}
