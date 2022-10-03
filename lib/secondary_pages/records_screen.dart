import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sates/models/post.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

import '../models/userfiles.dart';
import '../widgets/constant_widgets.dart';

class Records extends StatefulWidget {
  const Records({Key? key}) : super(key: key);

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  final PageController _pageController= PageController();
  int pageIndex=0;
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  final recordsRef = FirebaseFirestore.instance.collection('records');
  final usersRef = FirebaseFirestore.instance.collection('users');
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final postsTimelineRef = FirebaseFirestore.instance.collection('postsTimeline');
  List<Post>posts=[];

  getPost()async{
    QuerySnapshot snapshot=
    await postsRef
        .doc(currentUserId)
        .collection('userposts')
        .where('PostId', isEqualTo:p_Id.toString())
        .get();


    List<Post> posts=snapshot.docs.map((doc)=>Post.fromDocument(doc))
        .toList();
    this.posts=posts;





  }

var p_Id;
  ///pending approvals list getter
  buildPendingApprovalsList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('records')
            .doc(currentUserId)
            .collection('receivedSuccessfully')
            .where('Pending',isEqualTo: true)
            .where('Status',isEqualTo:true)
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
              return Container(
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
                          child: CustomText7('Did you receive the package from',

                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: ()=> showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context){
                                p_Id=data['PostId'].toString();
                                getPost();
                                return FutureBuilder(
                                    future:getPost(),
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
                    Padding(
                      padding:EdgeInsets.fromLTRB(8,8,8,15),
                      child: CustomText6(data['Timestamp'],

                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding:EdgeInsets.fromLTRB(8,8,8,15),
                          child: CustomText6(data['Timestamp'],

                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                            onTap: (){
                              From=data['From'].toString();
                              unique_id=data['UniqueId'].toString();
                              p_id=data['PostId'].toString();
                              setState(()=>value = false );
                              handleResponse();

                            },
                            child: Container(

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.green,
                                ),
                                child: FittedBox(child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CustomText4('Yes',Colors.white),
                                )))),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: (){

                          },
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.red,
                              ),
                              child: FittedBox(child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CustomText4('No',Colors.white),
                              )))
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
  buildSuccesfullySharedList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('records')
            .doc(currentUserId)
            .collection('sharedSuccessfully')
            .where('Pending',isEqualTo:false)
            .where('Status',isEqualTo: true)
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
                          child:  CustomText7('You successfully sent a package to',

                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: ()=> showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context){
                                p_Id=data['PostId'].toString();
                                getPost();
                                return FutureBuilder(
                                    future:getPost(),
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
  buildReceivedSuccessfullyList(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('records')
            .doc(currentUserId)
            .collection('receivedSuccessfully')
            .where('Pending',isEqualTo:false)
            .where('Status',isEqualTo:true)
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
                          child: CustomText7('You successfully received a package from',
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: ()=> showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context){
                                p_Id=data['PostId'].toString();
                                getPost();
                                return FutureBuilder(
                                    future:getPost(),
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


 changePostStatus()async{
    ///change timeline status
    await postsRef
        .doc(From)
        .collection('userposts')
        .doc(p_id)
        .update({
      'On Timeline':false,
      'Donated':true,
    });
    ///delete from timeline
    await postsTimelineRef
        .doc(p_id)
        .update({
      'On Timeline':false,
      'Donated':true,
    });

  }


  ///change user receivedSuccessfully records
  changeUserPendingStatus({bool? pending,
    String? from,String? unique_id}){
    recordsRef
        .doc(currentUserId)
        .collection('receivedSuccessfully')
        .doc(unique_id)
        .update({
      'Pending':pending,
    });

  }

  ///change postOWner sharedSuccessfully records
  changeSenderPendingStatus({bool? pending,
    String? from,String? unique_id}){
    recordsRef
        .doc(from)
        .collection('sharedSuccessfully')
        .doc(unique_id)
        .update({
      'Pending':pending,
    });

  }

handleResponse()async{
await value;
  await changeUserPendingStatus(
      from: From,
      unique_id: unique_id,
      pending:value,
  );
  await changeSenderPendingStatus(
  pending:value,
  from: From,
  unique_id: unique_id,
  );

  changePostStatus();


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
  bool? value;
  var From;
  var To;
  var unique_id;
  var UserfName;
  var UserlName;
  var UserUrl;
var p_id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar:AppBar(
        elevation: 0,
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
            ///records
            FittedBox(
              child: Text('Records',
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
                    title:Text('Shared'),
                  ),
                  TitledNavigationBarItem(
                    icon:Icon(Icons.call_received_outlined),
                    title:Text('Received'),
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
          buildSuccesfullySharedList(),
          buildReceivedSuccessfullyList(),
        ],
      ),

    );
  }
}
