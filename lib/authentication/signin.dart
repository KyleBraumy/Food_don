import 'package:flutter/material.dart';
import 'package:sates/main_pages/home.dart';
import 'package:sates/startup/startpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sates/authentication/auth.dart';

class signin extends StatefulWidget {
  final Function? toggleView;
  signin({this.toggleView});

  @override
  State<signin> createState() => _signinState();
}

class _signinState extends State<signin> {

  FirebaseFirestore firestore= FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  final _formKey= GlobalKey<FormState>();

  String error="";
  String email="";
  String password="";

  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                          Container(
                            margin: EdgeInsets.all(3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                    widget.toggleView!(),
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
                                    height: size.height/29,
                                    width: size.width/3,
                                    child: Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),

                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] ),
                  ),
                ),
                //Sign IN to account
                Text('Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize:30,
                  ),
                ),

                SizedBox(
                  height: 30,
                ),
                //email
                Padding(
                  padding:EdgeInsets.only(left:30,right:30,bottom: 20),
                  child: Container(
                    height:size.height/17,
                    child: TextFormField(
                      validator: (val)=>val!.isEmpty?'Enter an email':null,
                      onChanged: (val){
                        setState(() => email=val);
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline),
                        hintText: 'Enter your email ',labelText: 'Email',border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      ),

                    ),
                  ),
                ),
                //password
                Padding(
                  padding:EdgeInsets.only(left:30,right:30,bottom: 10),
                  child: Container(
                    height:size.height/17,
                    child: TextFormField(
                      validator: (val)=>val!.length< 6 ?'Enter a password 6+ chars long':null,
                      onChanged: (val){
                        setState(() => password=val);
                      },

                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_open),
                        hintText: 'Create Password',labelText: 'Password',border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      ),
                      obscureText: true,
                    ),
                  ),
                ),
                //error
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(

                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  alignment: Alignment.center,
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async{
                          if (_formKey.currentState!.validate()){
                            dynamic result = await _auth.signInWithEmailandPassword(email, password);
                            if (result == null){
                              setState(()=>error = 'The User with this credentials could not be found');
                            }else{
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> home()));
                            }

                          }

                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
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
                          height: size.height/20,
                          width: size.width/3,
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),

                        ),
                      ),
                    ],
                  ),
                ),
                Text(error),
              ],
            ),
          ),
        ),
      ),


    );
  }
}
