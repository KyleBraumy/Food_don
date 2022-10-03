import 'package:flutter/material.dart';
import 'package:sates/authentication/authenticate.dart';
import 'package:sates/authentication/signin.dart';
import 'package:sates/startup/wrapper.dart';
import '../authentication/createpage.dart';
import 'dart:async';

class Startpage extends StatefulWidget {

  @override
  State<Startpage> createState() => _StartpageState();
}

class _StartpageState extends State<Startpage> {

  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                child: Container(
                  height: size.height/2.6,
                  color: Colors.white,
                  child: Stack(
                      children:[
                        Image(
                            image:AssetImage('assets/images/sharing.png')),
                      ] ),
                ),
              ),
              //create account
              Padding(
                padding: const EdgeInsets.only(top: 8.0,bottom: 20),
                child: Text('FoodShare',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize:30,
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),
              ///create account or Sign up
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Authenticate()));

                  },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0,1),
                      ),
                    ],
                  ),
                  height: size.height/17,
                  width: size.width/1.3,
                  child: Text(
                    'Sign in / Create account',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Gotham',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                ),
              ),
             /* GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> createpage(View:true,)));
                  },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0,1),
                      ),
                    ],
                  ),
                  height: size.height/17,
                  width: size.width/1.3,
                  child: Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),

                ),
              ),*/
            ],
          ),
        ),
      ),

    );
  }
}
