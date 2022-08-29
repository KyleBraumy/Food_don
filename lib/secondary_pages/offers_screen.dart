import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

import '../models/requests.dart';
import '../models/userfiles.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final requestsRef = FirebaseFirestore.instance.collection('requests');
  final usersRef = FirebaseFirestore.instance.collection('users');
  int pageIndex=0;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final PageController _pageController= PageController();
  onTap(int pageIndex){
    _pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 250),
        curve: Curves.bounceInOut
    );
  }
  onPageChanged(int pageIndex){
    setState((){
      this.pageIndex = pageIndex;
    });
  }


  changeSenderApprovalStatus({bool? status,String? from,String? unique_id,bool? pending}){
    requestsRef
        .doc(from)
        .collection('OffersSent')
        .doc(unique_id)
        .update({
      'Status':status,
      'Pending':pending,
    });


  }
  changeReceiverApprovalStatus({bool? status,String? from,String? unique_id,bool? pending}){
    requestsRef
        .doc(currentUserId)
        .collection('offersReceived')
        .doc(unique_id)
        .update({
      'Status':status,
      'Pending':pending,
    });

  }

  handleOffer()async{
    await changeSenderApprovalStatus(
      from: From,
      unique_id: unique_id,
      status:value,
      pending:true,
    );
    await changeReceiverApprovalStatus(
      status:value,
      from: From,
      unique_id: unique_id,
      pending:true,
    );

  }
  ///pending offers list getter
  buildPendingOffersList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(currentUserId)
            .collection('acceptanceRequestsReceived')
            .where('Status',isEqualTo: null)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Something went wrong'),
                  ],
                )
            );
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Loading'),
                  ],
                )
            );
          }
          if(snapshot.hasData && snapshot.data?.size==0){
            return Center(
              child:Text('No pending approvals'),
            );
          }
          return ListView(
            children:snapshot.data!.docs
                .map((DocumentSnapshot document){
              Map<String, dynamic> data=
              document.data()! as Map<String,dynamic>;

              return
              Container(
                height: 150,
                margin: EdgeInsets.all(8),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,left:8),
                          child: Text('Request about your post',
                            style: TextStyle(
                                color: Colors.black
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: ()=> showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context){
                                return DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.6,
                                    minChildSize: 0.4,
                                    maxChildSize: 0.9,
                                    builder: (BuildContext context, ScrollController scrollcontroller){
                                      return RequestView(requestId: data['RequestId'].toString());
                                    }
                                );
                              }
                          ),

                          child: Padding(
                            padding: const EdgeInsets.only(top:8.0,left:8),
                            child: Text('View post',
                              style: TextStyle(
                                  color: Colors.green
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder(
                        stream: usersRef.doc(data['From']).snapshots(),
                        //Resolve Value Available In Our Builder Function
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          //Deserialize
                          //print(widget.profileId);
                          var DocData = snapshot.data as DocumentSnapshot;
                          GUser gUser = GUser.fromDocument(DocData);
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child:Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  child: Center(
                                    child: CachedNetworkImage(
                                      imageUrl:gUser.profilePhotoUrl.toString(),
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          //borderRadius: BorderRadius.circular(50),
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: Text(gUser.lname.toString()+" "+gUser.fname.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );


                        }

                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text('Do you want to approve request?'),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                            onTap: ()async{
                              From=data['From'].toString();
                              unique_id=data['UniqueId'].toString();
                              setState(()=>value = true );
                              handleOffer();

                            },
                            child: Text('Yes')),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: (){
                            handleOffer();
                            setState(()=>value = false);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right:10.0),
                            child: Text('No'),
                          ),
                        ),
                      ],
                    ),



                    /*  Container(
                        height: 200,
                        width: 200,
                        child: FittedBox(
                          child: buildTimeline(),
                        ),

                      ),*/
                    Divider(),
                  ],
                ),
              );

            })
                .toList()

                .cast(),

          );
        }
    );
  }

  ///offers sent list getter
  buildSentOffersList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(currentUserId)
            .collection('offersSent')
            .where('Status',isEqualTo: null)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Something went wrong'),
                  ],
                )
            );
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Loading'),
                  ],
                )
            );
          }
          if(snapshot.hasData && snapshot.data?.size==0){
            return Center(
              child:Text('No sent requests'),
            );
          }
          return ListView(
            children:snapshot.data!.docs
                .map((DocumentSnapshot document){
              Map<String, dynamic> data=
              document.data()! as Map<String,dynamic>;
              // From=data['To'].toString();
              // unique_id=data['UniqueId'].toString();
              return Container(
                height: 150,
                margin: EdgeInsets.all(8),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,left:8),
                          child: Text('Sent Request about this post',
                            style: TextStyle(
                                color: Colors.black
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: ()=> showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context){
                                return DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.6,
                                    minChildSize: 0.4,
                                    maxChildSize: 0.9,
                                    builder: (BuildContext context, ScrollController scrollcontroller){
                                      return RequestView(requestId: data['RequestId'].toString(),Id:data['To'].toString(),);
                                    }
                                );
                              }
                          ),

                          child: Padding(
                            padding: const EdgeInsets.only(top:8.0,left:8),
                            child: Text('View post',
                              style: TextStyle(
                                  color: Colors.green
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    StreamBuilder(
                          stream: usersRef.doc(data['To']).snapshots(),
                        //Resolve Value Available In Our Builder Function
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          //Deserialize
                          //print(widget.profileId);
                          var DocData = snapshot.data as DocumentSnapshot;
                          GUser gUser = GUser.fromDocument(DocData);
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child:Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  child: Center(
                                    child: CachedNetworkImage(
                                      imageUrl:gUser.profilePhotoUrl.toString(),
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          //borderRadius: BorderRadius.circular(50),
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: Text(gUser.lname.toString()+" "+gUser.fname.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );


                        }

                    ),
                  ],
                ),
              );

            })
                .toList()

                .cast(),

          );
        }
    );
  }







bool? value;
var From;
  var unique_id;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        title: Column(
          children: [
            SizedBox(
              height: 1,
            ),
            ///requests
            FittedBox(
              child: Text('Offers',
                style: TextStyle(
                    color: Colors.green,
                    fontSize:20
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            FittedBox(
              child: TitledBottomNavigationBar(
                activeColor: Colors.orange,
                inactiveColor: Colors.green,
                enableShadow: false,
                height: 40,
                reverse: true,
                currentIndex: pageIndex,
                onTap: onTap,
                items: [
                  TitledNavigationBarItem(
                    icon:Icon(Icons.all_inclusive),
                    title:Text('Pending'),
                  ),
                  TitledNavigationBarItem(
                    icon:Icon(Icons.free_breakfast),
                    title:Text('Sent'),
                  ),

                ],
              ),
            ),
          ],
        ),
        toolbarHeight:80,
        backgroundColor: Colors.white,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: [
          buildPendingOffersList(),
          buildSentOffersList(),
        ],
      ),

    );
  }
}
