import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart'as timeago;
import 'userfiles.dart';
import '../main_pages/profile.dart';




class Requests extends StatefulWidget {
  final String? requestId;
  final String? requested;
  final String? requested_as;
  final String? ownerId;
  final String? username;
  final String? pstatus;
  var timestamp;
  final String? location;
  final String? description;


  Requests({
    this.requestId,
    this.requested,
    this.requested_as,
    this.ownerId,
    this.username,
    this.pstatus,
    this.timestamp,
    this.location,
    this.description,
  });


  factory Requests.fromDocument(DocumentSnapshot doc) {
    return Requests(
      requestId: doc['RequestId'],
      requested: doc['Requested'],
      requested_as: doc['Requested as'],
      ownerId: doc['OwnerID'],
      username: doc['Username'],
      pstatus: doc['Price Status'],
      timestamp: doc['Timestamp'],
      location: doc['Location'],
      description: doc['Description'],

    );
  }


  @override
  State<Requests> createState() => _RequestsState(
  requestId: this.requestId,
    requested: this.requested,
    requested_as:this.requested_as,
    ownerId:this.ownerId,
    username:this.username,
    pstatus:this.pstatus,
    timestamp: this.timestamp,
    location:this.location,
    description: this.description,

  );
}




class _RequestsState extends State<Requests> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final requestsRef = FirebaseFirestore.instance.collection('requests');
  String uniqueO_Id=const Uuid().v4();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;


  final String? requestId;
  final String? requested;
  final String? requested_as;
  final String? ownerId;
  final String? username;
  final String? pstatus;

  var timestamp;
  final String? location;
  final String? description;



  _RequestsState({
    this.requestId,
    this.requested,
    this.requested_as,
    this.ownerId,
    this.username,
    this.pstatus,
    this.timestamp,
    this.location,
    this.description,
  }

      );


  addToSenderOfferDocuments({String? Request,required DateTime timestamp}){
    requestsRef
        .doc(currentUserId)
        .collection('offersSent')
        .doc(uniqueO_Id)
        .set({
      'Description':Request,
      'To':ownerId,
      'Status':null,
      'RequestId':requestId,
      'UniqueId':uniqueO_Id,
      'Timestamp':timestamp,
    });

  }
  addToDestinationOfferDocuments({String? Request,required DateTime timestamp}){
    requestsRef
        .doc(ownerId)
        .collection('offersReceived')
        .doc(uniqueO_Id)
        .set({
      'Description':Request,
      'From':currentUserId,
      'Status':null,
      'RequestId':requestId,
      'UniqueId':uniqueO_Id,
      'Timestamp':timestamp,
    });


  }
  removefromSenderOfferDocuments({required String New_uniqueO_id}){
    requestsRef
        .doc(currentUserId)
        .collection('offersSent')
        .doc(New_uniqueO_id)
        .delete();

  }
  removefromDestinationOfferDocuments({required String New_uniqueO_id}){
    requestsRef
        .doc(ownerId)
        .collection('offersReceived')
        .doc(New_uniqueO_id)
        .delete();


  }



  handleSubmitOfferRequest()async{
    final DateTime Timestamp= DateTime.now();
    addToDestinationOfferDocuments(
      Request: request,
        timestamp: Timestamp,
    );

    addToSenderOfferDocuments(
      Request: request,
      timestamp: Timestamp,
    );
    setState((){
      uniqueO_Id=const Uuid().v4();
    });
    Navigator.pop(context);

  }
  handleCancelOfferRequest()async{
    await new_uniqueO_id;
    removefromDestinationOfferDocuments(
        New_uniqueO_id: new_uniqueO_id
    );
    ///Add post to timeline
    removefromSenderOfferDocuments(
        New_uniqueO_id: new_uniqueO_id
    );
    Navigator.pop(context);

  }

offerValidation(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(currentUserId)
            .collection('offersSent')
            .where('To',isEqualTo:ownerId.toString())
            .where('RequestId',isEqualTo:requestId.toString())
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return SizedBox();
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return SizedBox();
          }
          ///Checking if there is already a request sent if not the send request is shown
          if(snapshot.hasData && snapshot.data?.size==0){
            return Column(
              children: [
                ListTile(
                  title:Text('View profile'),
                  onTap:() {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>
                            Profile(profileId:ownerId,)));
                  },
                ),
                ListTile(
                  title:Text('Make an offer to : '+"  "+username.toString()),
                  onTap:()=>handleSubmitOfferRequest(),
                ),
              ],
            );

          }
          ///If there is already a request, cancel request is shown
          return Column(
              children:snapshot.data!.docs
                  .map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data()! as Map<String,dynamic>;
                new_uniqueO_id=data['UniqueId'].toString();
                return Column(
                  children: [
                    ListTile(
                      title:Text('View profile'),
                      onTap:() {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>
                                Profile(profileId:ownerId,)));
                      },
                    ),
                    ListTile(
                      title:Text('Cancel offer to : '+"  "+username.toString()),
                      onTap:()=>handleCancelOfferRequest(),
                    )
                  ],
                );

              }) .toList()
          );


        }



    );
}


  String request="Request Post";
  var new_uniqueO_id;

  @override
  Widget build(BuildContext context) {
    ///getting size(height,width) of the target device
    final Size size =MediaQuery.of(context).size;

    ///Template for requests made by users
    return GestureDetector(
      onTap:()=> showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context){
            return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                builder: (BuildContext context, ScrollController scrollcontroller){
                  return ownerId!=currentUserId?
                  offerValidation():
                  Column(
                    children: [
                      ListTile(
                        title:Text('View profile'),
                        onTap:() {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>
                                Profile(profileId:ownerId,)));
                        },
                      ),
                    ],
                  );
                }
            );
          }
      ),
      child: Container(
        height: 120,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:  Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
         boxShadow: [
           BoxShadow(
             offset: Offset(0,5),
             spreadRadius: 2,
             color: Colors.grey.withOpacity(0.3),
             blurRadius:7,
           ),
         ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0,top: 3),
              child: Text('Requested for'+" "+requested.toString()),
            ),
            Row(
              children: [
                ///UserProfilePhoto
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 85,
                    width:85,
                    child:
                    ///StreamBuilder to get profile image upon update
                    StreamBuilder(
                        stream: usersRef.doc(widget.ownerId).snapshots(),
                        //Resolve Value Available In Our Builder Function
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          //Deserialize
                          //print(widget.profileId);
                          var DocData = snapshot.data as DocumentSnapshot;
                          GUser gUser = GUser.fromDocument(DocData);
                          return Center(
                            child: CachedNetworkImage(
                              imageUrl:gUser.profilePhotoUrl.toString(),
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  //shape: BoxShape.circle,
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          );
                        }

                    ),
                  ),
                ),
                ///Username,Position,Time
                ///Username & position
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>
                                Profile(profileId:ownerId,)));
                      },
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(username.toString(),
                              style: TextStyle(
                                fontSize:17,

                              ),
                              textAlign: TextAlign.left,
                              softWrap: true,),
                            Container(
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.all(8),
                              height:5,
                              width: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            ),
                            Text(requested_as.toString(),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black.withOpacity(0.5)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    FittedBox(
                      child: Text(timeago.format(timestamp.toDate()),
                        overflow:TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize:12,
                            color: Colors.black.withOpacity(0.5)
                        ),
                        softWrap: true,),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ///Price
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: pstatus.toString()=="free"? Colors.green:Colors.orange,
                      ),

                      ///Price
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(pstatus.toString(),
                            style: TextStyle(
                              fontSize:15,
                              color:Colors.white,
                            ),
                            softWrap: true,),
                        ),
                      ),
                    ),
                  ],
                ),
                ///Time post was made

               /* Expanded(
                  child: SizedBox(),
                ),
                ///Price
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: pstatus.toString()=="free"? Colors.green:Colors.orange,
                    ),

                    ///Price
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(pstatus.toString(),
                          style: TextStyle(
                            fontSize:17,
                            color:Colors.white,
                          ),
                          softWrap: true,),
                      ),
                    ),
                  ),
                ),*/
              ],
            ),

          ],
        ),
      ),
    );

  }
}






class RequestView extends StatefulWidget {


  String requestId;
  String? Id;
  RequestView({
    required this.requestId,
    this.Id,
  });

  @override
  State<RequestView> createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> {
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  final usersRef = FirebaseFirestore.instance.collection('users');
  ///Searching for post in current user documents which an offer was made for
  buildReceivedPostView(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(currentUserId)
            .collection('userRequests')
            .where('RequestId',isEqualTo: widget.requestId.toString())
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Text('Something went wrong');
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Text('Loading');
          }
          if(snapshot.data==null){
            return Text('Null');
          }
          return Scaffold(
            ///List of chats with other users
            body: ListView(
              children:snapshot.data!.docs
                  .map((DocumentSnapshot document){
                Map<String, dynamic> data=
                document.data()! as Map<String,dynamic>;
                return Container(
                  height: 120,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color:  Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0,5),
                          spreadRadius: 2,
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius:7,
                        ),
                      ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0,top: 3),
                        child: Text('Requested for'+" "+data['Requested'].toString()),
                      ),
                      Row(
                        children: [
                          ///UserProfilePhoto
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 85,
                              width:85,
                              child:
                              ///StreamBuilder to get profile image upon update
                              StreamBuilder(
                                  stream: usersRef.doc(widget.Id).snapshots(),
                                  //Resolve Value Available In Our Builder Function
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    //Deserialize
                                    //print(widget.profileId);
                                    var DocData = snapshot.data as DocumentSnapshot;
                                    GUser gUser = GUser.fromDocument(DocData);
                                    return Center(
                                      child: CachedNetworkImage(
                                        imageUrl:gUser.profilePhotoUrl.toString(),
                                        imageBuilder: (context, imageProvider) => Container(
                                          decoration: BoxDecoration(
                                            //shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(20),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    );
                                  }

                              ),
                            ),
                          ),
                          ///Username,Position,Time
                          ///Username & position
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: (){

                                },
                                child: FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(data['Username'].toString(),
                                        style: TextStyle(
                                          fontSize:17,

                                        ),
                                        textAlign: TextAlign.left,
                                        softWrap: true,),
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        margin: EdgeInsets.all(8),
                                        height:5,
                                        width: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(data['Requested as'].toString(),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.black.withOpacity(0.5)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              FittedBox(
                                child: Text(data['Timestamp'].toString(),
                                  style: TextStyle(
                                      fontSize:12,
                                      color: Colors.black.withOpacity(0.5)
                                  ),
                                  softWrap: true,),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ///Price
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: data['Price Status'].toString()=="free"? Colors.green:Colors.orange,
                                ),

                                ///Price
                                child: FittedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(data['Price Status'].toString(),
                                      style: TextStyle(
                                        fontSize:15,
                                        color:Colors.white,
                                      ),
                                      softWrap: true,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ///Time post was made

                        ],
                      ),

                    ],
                  ),
                );


              })
                  .toList()

                  .cast(),

            ),
          );
        }
    );
  }

///Searching for post in target documents which an offer was made for
  buildSentPostView(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.Id)
            .collection('userRequests')
            .where('RequestId',isEqualTo: widget.requestId.toString())
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Text('Something went wrong');
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Text('Loading');
          }
          if(snapshot.data==null){
            return Text('Null');
          }
          return Scaffold(
            ///List of chats with other users
            body: ListView(
              children:snapshot.data!.docs
                  .map((DocumentSnapshot document){
                Map<String, dynamic> data=
                document.data()! as Map<String,dynamic>;
                return Container(
                  height: 120,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color:  Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0,5),
                          spreadRadius: 2,
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius:7,
                        ),
                      ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0,top: 3),
                        child: Text('Requested for'+" "+data['Requested'].toString()),
                      ),
                      Row(
                        children: [
                          ///UserProfilePhoto
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 85,
                              width:85,
                              child:
                              ///StreamBuilder to get profile image upon update
                              StreamBuilder(
                                  stream: usersRef.doc(widget.Id).snapshots(),
                                  //Resolve Value Available In Our Builder Function
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    //Deserialize
                                    //print(widget.profileId);
                                    var DocData = snapshot.data as DocumentSnapshot;
                                    GUser gUser = GUser.fromDocument(DocData);
                                    return Center(
                                      child: CachedNetworkImage(
                                        imageUrl:gUser.profilePhotoUrl.toString(),
                                        imageBuilder: (context, imageProvider) => Container(
                                          decoration: BoxDecoration(
                                            //shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(20),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    );
                                  }

                              ),
                            ),
                          ),
                          ///Username,Position,Time
                          ///Username & position
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: (){

                                },
                                child: FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(data['Username'].toString(),
                                        style: TextStyle(
                                          fontSize:17,

                                        ),
                                        textAlign: TextAlign.left,
                                        softWrap: true,),
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        margin: EdgeInsets.all(8),
                                        height:5,
                                        width: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(data['Requested as'].toString(),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.black.withOpacity(0.5)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              FittedBox(
                                child: Text(data['Timestamp'].toString(),
                                  style: TextStyle(
                                      fontSize:12,
                                      color: Colors.black.withOpacity(0.5)
                                  ),
                                  softWrap: true,),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ///Price
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: data['Price Status'].toString()=="free"? Colors.green:Colors.orange,
                                ),

                                ///Price
                                child: FittedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(data['Price Status'].toString(),
                                      style: TextStyle(
                                        fontSize:15,
                                        color:Colors.white,
                                      ),
                                      softWrap: true,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ///Time post was made

                        ],
                      ),

                    ],
                  ),
                );


              })
                  .toList()

                  .cast(),

            ),
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    ///if the Id is equal to the current user Id then it means the user rather
    ///received , and if it is not equal it means the user sent the offer
    ///hence searching for the specific post depending on sender and receiver
    return widget.Id!=currentUserId? buildSentPostView():
    buildReceivedPostView();
  }
}
