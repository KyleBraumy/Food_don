import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sates/models/post.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

import '../models/userfiles.dart';

class ApprovalsScreen extends StatefulWidget {

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  final PageController _pageController= PageController();
  final timelineRef = FirebaseFirestore.instance.collection('postsTimeline');
  final requestsRef = FirebaseFirestore.instance.collection('requests');
  final recordsRef = FirebaseFirestore.instance.collection('records');
  final usersRef = FirebaseFirestore.instance.collection('users');
  int pageIndex=0;
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  List<Post>posts=[];
  getTimeline()async{

    QuerySnapshot snapshot=
    await timelineRef
        .orderBy('Timestamp',descending: true)
        .get();
    List<Post> posts=snapshot.docs.map((doc)=>Post.fromDocument(doc))
        .toList();
    this.posts=posts;

  }
  buildTimeline(){
    if(posts==null){
      return Text('No posts');
    }
    return ListView(children:posts);
  }


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

  @override
  void initstate(){
    //getTimeline();
    super.initState();

  }
///change request sender approval status
  changeSenderApprovalStatus({bool? status,String? from,String? unique_id}){
    requestsRef
        .doc(from)
        .collection('acceptanceRequestsSent')
        .doc(unique_id)
        .update({
      'Status':status,
    });


  }

  ///change request receiver(postOwner) approval status
  changeReceiverApprovalStatus({bool? status,String? from,String? unique_id}){
    requestsRef
        .doc(currentUserId)
        .collection('acceptanceRequestsReceived')
        .doc(unique_id)
        .update({
      'Status':status,
    });

  }
///Approval on postOwner device
  ///update records sharedSuccessfully
  addToSenderSharedSuccessfully({
    bool? status,String? from,String? unique_id,
    String? timestamp,required bool pending
  }){
    recordsRef
        .doc(currentUserId)
        .collection('sharedSuccessfully')
        .doc(unique_id)
        .update({
      'Status':status,
      'Timestamp':timestamp,
      'Pending':pending,
    });
  }

  ///Update request sender receivedSuccessfully records
  addToReceiverReceivedSuccessfully({bool? status,
    String? from,String? unique_id, String? timestamp,
    required bool pending,
  }){
    recordsRef
        .doc(from)
        .collection('receivedSuccessfully')
        .doc(unique_id)
        .update({
      'Status':status,
      'Timestamp':timestamp,
      'Pending':pending,
    });
  }


  handleYes()async{
    final DateTime Timestamp= DateTime.now();
    await addToReceiverReceivedSuccessfully(
      status:true,
      pending: true,
      timestamp: Timestamp.toString(),
      unique_id:unique_id,
      from:From,
    );
    await addToSenderSharedSuccessfully(
      status:true,
      pending: true,
      timestamp: Timestamp.toString(),
      unique_id:unique_id,
    );
  }

  handleApproval()async{
    await handleYes();
    await changeSenderApprovalStatus(
      from: From,
      unique_id: unique_id,
      status:value,
    );
    await changeReceiverApprovalStatus(
      status:value,
      from: From,
      unique_id: unique_id,
    );

  }
  ///pending approvals list getter
  buildPendingApprovalsList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(currentUserId)
            .collection('acceptanceRequestsReceived')
            .where('Status',isEqualTo:null)
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

              return data['Status'].toString()=="null"?
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
                                      return PostView(postId: data['PostId'].toString(),Id: currentUserId,);
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
                              handleApproval();

                            },
                            child: Text('Yes')),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: (){
                            handleApproval();
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
              ):
              SizedBox();

            })
                .toList()

                .cast(),

          );
        }
    );
  }

  ///approvals sent list getter
  buildSentAcceptanceRequestsList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(currentUserId)
            .collection('acceptanceRequestsSent')
            .where('Pending',isEqualTo:true)
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
              return data['Status'].toString()=="null"?
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
                                      return PostView(postId: data['PostId'].toString(),Id:data['To'].toString(),);
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
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text((data['To']).toString(),
                        style: TextStyle(
                            color: Colors.green
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              SizedBox();

            })
                .toList()

                .cast(),

          );
        }
    );
  }

/*  ///approvals received list getter
  buildReceivedAcceptanceRequestsList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(currentUserId)
            .collection('acceptanceRequestsReceived')
            .where('Pending',isEqualTo: false)
            .where('Status',isEqualTo: "true")
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
              child:Text('No received requests'),
            );
          }
          return ListView(
            children:snapshot.data!.docs
                .map((DocumentSnapshot document){
              Map<String, dynamic> data=
              document.data()! as Map<String,dynamic>;
              // From=data['To'].toString();
              // unique_id=data['UniqueId'].toString();
              return data['Status'].toString()=="null"?
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
                                      return PostView(postId: data['PostId'].toString(),Id:data['From'].toString(),);
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
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text((data['To']).toString(),
                        style: TextStyle(
                            color: Colors.green
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              SizedBox();

            })
                .toList()

                .cast(),

          );
        }
    );
  }*/

bool? value;
  var From;
  var To;
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
              child: Text('Approvals',
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
          buildPendingApprovalsList(),
          buildSentAcceptanceRequestsList(),

        ],
      ),

    );
  }
}
