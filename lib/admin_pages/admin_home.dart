import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sates/admin_pages/search.dart';
import 'package:sates/widgets/constant_widgets.dart';

import '../authentication/auth.dart';
import '../models/userfiles.dart';
import '../startup/wrapper.dart';
import 'admin_sidebar.dart';
import 'displayUserInformation.dart';

class A_home extends StatefulWidget {
  const A_home({Key? key}) : super(key: key);

  @override
  State<A_home> createState() => _A_homeState();
}


final AuthService _auth= AuthService();
///Logout
logout(parentContext){
  return showDialog(
      context: parentContext,
      builder: (context){
        return SimpleDialog(
          title: Text('Are you sure you want to log out'),
          children: [
            Row(
              children: [
                SimpleDialogOption(
                    child:Text('Yes'),
                    onPressed:()
                    async{
                      await _auth.signOut();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context)=> Wrapper()));

                    }

                ),
                SimpleDialogOption(
                  child:Text('No'),
                  onPressed: ()=>Navigator.pop(context),
                ),
              ],
            ),

          ],
        );
      }
  );
}




class _A_homeState extends State<A_home> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  var scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    getUserGender();
    //buildProfileRate();
    //checkUserPermission();
    //print('Profile Init');
    super.initState();
  }




  buildUserCount(){
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('Id',isNull:false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Center(child: Text('Error loading list..'));
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(
              child:Text('Loading...'),
            );
          }
          if(snapshot.hasData && snapshot.data?.size==0){
            return Center(
              child:Text('No user yet...'),
            );
          }
          var DocData = snapshot.data as QuerySnapshot;
          return Column(
                children: [
                  Text('Number of users'),
                  Container(
                    height: 75,
                    width: 75,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        shape: BoxShape.circle
                    ),
                    child:Center(child: Text(snapshot.data!.size.toString())),
                  ),
                ],
              );

        }
    );
  }
  buildUserDomination(){
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('Identify_as',isEqualTo:'Individual')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Center(child: Text('Error loading list..'));
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(
              child:Text('Loading...'),
            );
          }
          if(snapshot.hasData && snapshot.data?.size==0){
            return Center(
              child:Text('No user yet...'),
            );
          }
          var DocData = snapshot.data as QuerySnapshot;
          return FittedBox(
            child: Column(
              children: [
                Text('Number of users as individuals'),
                Container(
                  height: 65,
                  margin: EdgeInsets.only(left:30,right:30,top: 7),
                  width:MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child:Center(child: Text(snapshot.data!.size.toString())),
                ),
              ],
            ),
          );

        }
    );
  }
  buildUserDomination2(){
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('Identify_as',isEqualTo:'Organization')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Center(child: Text('Error loading list..'));
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(
              child:Text('Loading...'),
            );
          }
          if(snapshot.hasData && snapshot.data?.size==0){
            return Center(
              child:Text('No user yet...'),
            );
          }
          var DocData = snapshot.data as QuerySnapshot;
          return FittedBox(
            child: Column(
              children: [
                Text('Number of users as Organization'),
                Container(
                  height: 65,
                  margin: EdgeInsets.only(left:30,right:30,top: 7),
                  width:MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                  ),
                  child:Center(child: Text(snapshot.data!.size.toString())),
                ),
              ],
            ),
          );

        }
    );
  }


  getUserGender() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await usersRef
        .where('Gender', isEqualTo: 'Female')
        .get();
    QuerySnapshot querysnapshot = await usersRef
        .where('Gender', isEqualTo: 'Male')
        .get();

    setState(() {
      isLoading = false;
      fmale= snapshot.docs.length;
      male= querysnapshot.docs.length;
    });
  }

  buildUserlist(){
  return Scaffold(
    backgroundColor: Colors.green.shade50,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 90,
      title:CustomText8('List of Users'),
    ),
    body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('Last Name',descending:false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Center(child: Text('Error loading list..'));
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(
              child:Text('Loading...'),
            );
          }
          if(snapshot.hasData && snapshot.data?.size==0){
            return Center(
              child:Text('No user yet...'),
            );
          }
          return ListView(
            children:snapshot.data!.docs
                .map((DocumentSnapshot document){
              Map<String, dynamic> data=
              document.data()! as Map<String,dynamic>;
              return data['Id']==null?SizedBox():Column(
                children: [
                  GestureDetector(
                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return DisplayUserInformation(
                        id: data['Id'],
                        email: data['Email'],
                        Fname: data['First Name'],
                        city: data['City'],
                        phone1: data['Contact 1'],
                        phone2: data['Contact 2'],
                        Lname: data['Last Name'],
                        rate: data['Rating'],
                        ratevalue: data['Rating_value'],
                        no_rate_ppl: data['No_ppl_rated'],
                        profilephotoUrl: data['ProfilePhotoUrl'],
                        coverphotoUrl: data['BackProfilePhotoUrl'],
                        bio: data['Bio'],
                        address: data['Address'],
                        occupation: data['Occupation'],
                        works_at: data['Works_at'],
                        identify_as: data['Identify_as'],
                        streetName: data['Street name'],

                      );
                    })),
                    child:Padding(
                      padding: EdgeInsets.only(top:3.0,),
                      child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl:data['ProfilePhotoUrl'].toString(),
                              imageBuilder: (context, imageProvider) => Container(
                                height: 70,
                                width: 70,
                                margin:  EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border:Border.all(
                                      width: 1,
                                      color: Colors.orange
                                  ),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                            Column(
                              children: [
                                CustomText2((data['Last Name']+" "+data['First Name']).toString()),
                                CustomText7(data['Identify_as'].toString()),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );



            })
                .toList()

                .cast(),

          );

        }
    ),
  );
}

  void toggleView(){
    setState(()=>isSearch=!isSearch);
  }
  var fmale;
  var male;
bool isLoading=false;
bool isSearch=false;
  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return isSearch?Search(toggleView:toggleView,):Scaffold(
      drawer: Drawer(child:Admin_sidebar(),),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 90,
        backgroundColor: Colors.green.shade500,
        title: Text('Welcome Admin'),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: ()=>
                logout(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.logout_rounded,semanticLabel:'Logout',),
            ),
          ),
          GestureDetector(
            onTap: (){
              setState(()=>isSearch=!isSearch);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.search_rounded),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                width:size.width,
                color: Colors.green.shade50,
                margin: EdgeInsets.all(8),
                child: 
                Padding(
                  padding: EdgeInsets.all(9),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return buildUserlist();
                                })),
                                child:Container(
                                  color: Colors.green.shade50,
                                  child: buildUserCount(),
                                ),
                              ),
                            ],
                          ),
                          Expanded(child: SizedBox()),
                          Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:  EdgeInsets.only(bottom:20.0),
                                child: Row(
                                  children: [
                                    Text('Males'),
                                    Container(
                                      height: 75,
                                      width: 75,
                                      margin: EdgeInsets.only(left: 25),
                                      decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          shape: BoxShape.circle
                                      ),
                                      child: Center(child: Text(male.toString())),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom:20.0),
                                child: Row(
                                  children: [
                                    Text('Females'),
                                    Container(
                                      height: 75,
                                      width: 75,
                                     margin: EdgeInsets.only(left:12),
                                      decoration: BoxDecoration(
                                          color: Colors.blue.shade200,
                                          shape: BoxShape.circle
                                      ),
                                      child:Center(child: Text(fmale.toString())),
                                    ),
                                  ],
                                ),
                              ),
                              //Expanded(child: SizedBox()),


                            ],
                          ),
                        ],
                      ),
                      buildUserDomination(),
                      buildUserDomination2(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
}
/* GridView(
            padding: EdgeInsets.all(5),
            physics: ScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5,
              childAspectRatio:1,
            ),
            children:[
              GestureDetector(
                onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return buildUserlist();
                })),
                child:Container(
                  color: Colors.green.shade50,
                  child: buildUserCount(),
                ),
              ),
              Container(
                color: Colors.green.shade50,
                child: buildUserDomination(),
              ),
              Container(
                color: Colors.green.shade50,
                child: buildUserDomination2(),
              ),
            ]
        ),*/