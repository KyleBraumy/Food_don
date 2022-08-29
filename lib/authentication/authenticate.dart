import 'package:flutter/material.dart';
import 'package:sates/authentication/signin.dart';
import 'package:sates/authentication/createpage.dart';

import '../startup/startpage.dart';


class Authenticate extends StatefulWidget {


  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn=true;

  void toggleView(){
    setState(()=>showSignIn=!showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn){
      return signin(toggleView:toggleView);
    }else {
      return createpage(toggleView:toggleView);
    }

  }
}


