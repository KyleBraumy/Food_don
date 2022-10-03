import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:sates/admin_pages/reports_page.dart';

import 'admin_handle.dart';
import 'feedback_page.dart';



class Admin_sidebar extends StatefulWidget {

  @override
  State<Admin_sidebar> createState() => _Admin_sidebarState();
}

class _Admin_sidebarState extends State<Admin_sidebar> {
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  height: size.height/4,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit:BoxFit.cover,
                        image: AssetImage('assets/images/foodshare_sideabar_background.jpg')),
                  )
              ),
              Text('FoodShare',style: TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),),
              SizedBox(height:40),
              ///feedbacks
              GestureDetector(
                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return  Feedbackpp();
                })),
                child: Container(
                  margin: EdgeInsets.only(top:5),
                  height:70,
                  color: Colors.green.shade100.withOpacity(0.3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:17.0),
                        child: Icon(Icons.approval_outlined,
                          color: Colors.orange,size: 30,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0),
                        child: Text('Feedbacks',
                          style: TextStyle(
                              fontFamily: 'Gotham',
                              fontWeight:FontWeight.bold,
                              letterSpacing: 1
                          ),
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
              ///Reports
              GestureDetector(
                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return  Reportsp();
                })),
                child: Container(
                  margin: EdgeInsets.only(top:15),
                  height:70,
                  color: Colors.green.shade100.withOpacity(0.3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:17.0),
                        child: Icon(Icons.local_offer_outlined,
                          color: Colors.orange,size: 30,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0),
                        child: Text('Reports',
                          style: TextStyle(
                              fontFamily: 'Gotham',
                              fontWeight:FontWeight.bold,
                              letterSpacing: 1
                          ),
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
              ///Records
              GestureDetector(
                onTap: (){},
                child: Container(
                  margin: EdgeInsets.only(top:15),
                  height:70,
                  color: Colors.green.shade100.withOpacity(0.3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:17.0),
                        child: Icon(Icons.receipt_long_outlined,
                          color: Colors.orange,size: 30,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0),
                        child: Text('Records',
                          style: TextStyle(
                              fontFamily: 'Gotham',
                              fontWeight:FontWeight.bold,
                              letterSpacing: 1
                          ),
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
              ///Handle reported users
              GestureDetector(
                onTap:  ()=>Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return  Admin_handle();
                })),
                child: Container(
                  margin: EdgeInsets.only(top:15),
                  height:70,
                  color: Colors.green.shade100.withOpacity(0.3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:17.0),
                        child: Icon(Icons.receipt_long_outlined,
                          color: Colors.orange,size: 30,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0),
                        child: Text('Handle users',
                          style: TextStyle(
                              fontFamily: 'Gotham',
                              fontWeight:FontWeight.bold,
                              letterSpacing: 1
                          ),
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
              Divider(thickness: 0.3,color: Colors.blue,),
            ],
          ),
        ),
      ),
    );
  }
}
