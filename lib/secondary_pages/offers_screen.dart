import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

import '../models/requests.dart';
import '../models/userfiles.dart';
import '../widgets/constant_widgets.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final requestsRef = FirebaseFirestore.instance.collection('requests');
  final requestsTimelineRef = FirebaseFirestore.instance.collection('requestsTimeline');
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
  List<Requests>posts=[];
  getTimeline()async{
    QuerySnapshot snapshot=
    await requestsRef
        .doc(currentUserId)
        .collection('userRequests')
        .where('RequestId', isEqualTo:r_Id.toString())
        .get();


    List<Requests> posts=snapshot.docs.map((doc)=>Requests.fromDocument(doc))
        .toList();
    this.posts=posts;

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
            .collection('offersReceived')
            .where('Status',isNull:true)
            .where('Pending',isNull:true)
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
                height: 160,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,left:8),
                          child: CustomText7('Made an offer to your post',
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: ()=> showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context){
                                r_Id=data['RequestId'].toString();
                                getTimeline();
                                return FutureBuilder(
                                    future:getTimeline(),
                                    builder: (context, snapshot) {
                                      return DraggableScrollableSheet(
                                          expand: false,
                                          initialChildSize: 0.6,
                                          minChildSize: 0.4,
                                          maxChildSize: 0.9,
                                          builder: (BuildContext context, ScrollController scrollcontroller){
                                            return ListView(
                                              children:posts,
                                            );
                                          }
                                      );
                                    }
                                );
                              }
                          ),
                          child: Padding(
                            padding:EdgeInsets.only(right:8,top: 8),
                            child: CustomText4('View post',
                                Colors.green
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
                            padding: const EdgeInsets.fromLTRB(20.0,15,20,5),
                            child:Row(
                              children: [
                                CachedNetworkImage(
                                  imageUrl:gUser.profilePhotoUrl.toString(),
                                  imageBuilder: (context, imageProvider) => Container(
                                    height: 45,
                                    width: 45,
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
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: CustomText2(gUser.lname.toString()+" "+gUser.fname.toString(),

                                  ),
                                ),
                              ],
                            ),
                          );


                        }

                    ),
                    Padding(
                      padding:EdgeInsets.fromLTRB(8,8,8,15),
                      child: CustomText6(data['Timestamp'],
                      ),
                    ),
                    Row(
                      children: [

                        Expanded(child: SizedBox()),
                        GestureDetector(
                            onTap: ()async{
                              From=data['From'].toString();
                              unique_id=data['UniqueId'].toString();
                              setState(()=>value = true );
                              handleOffer();

                            },
                            child:Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.green,
                                ),
                                child: FittedBox(child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: CustomText4('Yes',Colors.white),
                                )))),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: (){
                            handleOffer();
                            setState(()=>value = false);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.red,
                              ),
                              child: FittedBox(child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CustomText4('No',Colors.white),
                              ))),
                        ),
                      ],
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

  ///offers sent list getter
  buildSentOffersList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(currentUserId)
            .collection('offersSent')
            .where('Status',isNull:true)
            .where('Pending',isNull:true)
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
                height: 120,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,left:8),
                          child: CustomText7('Sent Request about this post',

                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: ()=> showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context){
                                r_Id=data['RequestId'].toString();
                                getTimeline();
                                return FutureBuilder(
                                    future:getTimeline(),
                                    builder: (context, snapshot) {
                                      return DraggableScrollableSheet(
                                          expand: false,
                                          initialChildSize: 0.2,
                                          minChildSize: 0.2,
                                          maxChildSize: 0.2,
                                          builder: (BuildContext context, ScrollController scrollcontroller){
                                            return ListView(
                                              children:posts,
                                            );
                                          }
                                      );
                                    }
                                );
                              }
                          ),
                          child: Padding(
                            padding:EdgeInsets.only(right:8,top: 8),
                            child: CustomText4('View post',
                                Colors.green
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
                            padding: const EdgeInsets.fromLTRB(20.0,15,20,5),
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
                                  child: CustomText2(gUser.lname.toString()+" "+gUser.fname.toString(),
                                  ),
                                ),
                              ],
                            ),
                          );


                        }

                    ),
                    Padding(
                      padding:EdgeInsets.fromLTRB(8,8,8,15),
                      child: CustomText6(data['Timestamp'],

                      ),
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
  ///offers approved list
  buildApprovedList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(currentUserId)
            .collection('offersReceived')
            .where('Status',isEqualTo:true)
            .where('Pending',isNull:true)
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
              child:Text('No approved requests yet'),
            );
          }
          return ListView(
            children:snapshot.data!.docs
                .map((DocumentSnapshot document){
              Map<String, dynamic> data=
              document.data()! as Map<String,dynamic>;
              return Container(
                  height: 120,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(

                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top:8.0,left:8),
                            child: CustomText7('Approved request about your post',
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          GestureDetector(
                            onTap: ()=> showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context){
                                  r_Id=data['PostId'].toString();
                                  getTimeline();
                                  return FutureBuilder(
                                      future:getTimeline(),
                                      builder: (context, snapshot) {
                                        return DraggableScrollableSheet(
                                            expand: false,
                                            initialChildSize: 0.6,
                                            minChildSize: 0.4,
                                            maxChildSize: 0.9,
                                            builder: (BuildContext context, ScrollController scrollcontroller){
                                              return ListView(
                                                children:posts,
                                              );
                                            }
                                        );
                                      }
                                  );
                                }
                            ),
                            child: Padding(
                              padding:EdgeInsets.only(right:8,top: 8),
                              child: CustomText4('View post',
                                  Colors.green
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
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0,right: 8),
                                child: Container(
                                  height: 50,
                                  color: Colors.green.shade50.withOpacity(0.3),
                                ),
                              );
                            }
                            //Deserialize
                            //print(widget.profileId);
                            var DocData = snapshot.data as DocumentSnapshot;
                            GUser gUser = GUser.fromDocument(DocData);
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20.0,15,20,5),
                              child:Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl:gUser.profilePhotoUrl.toString(),
                                    imageBuilder: (context, imageProvider) => Container(
                                      height: 45,
                                      width: 45,
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
                                  Padding(
                                    padding: const EdgeInsets.only(left:8.0),
                                    child: CustomText2(gUser.lname.toString()+" "+gUser.fname.toString(),

                                    ),
                                  ),
                                ],
                              ),
                            );


                          }

                      ),
                      Padding(
                        padding:EdgeInsets.fromLTRB(8,8,8,15),
                        child: CustomText6(data['Timestamp'],

                        ),
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
var r_Id;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar:AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
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
                    icon:Icon(Icons.downloading_outlined),
                    title:Text('Pending'),
                  ),
                  TitledNavigationBarItem(
                    icon:Icon(Icons.send_outlined),
                    title:Text('Sent'),
                  ),
                  TitledNavigationBarItem(
                    icon:Icon(Icons.download_done_outlined),
                    title:Text('Approved'),
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
          buildApprovedList(),
        ],
      ),

    );
  }
}
