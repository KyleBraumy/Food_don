
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../models/userfiles.dart';
import '../widgets/constant_widgets.dart';

class Feedbackpp extends StatefulWidget {
  const Feedbackpp({Key? key}) : super(key: key);

  @override
  State<Feedbackpp> createState() => _FeedbackppState();
}

class _FeedbackppState extends State<Feedbackpp> {


  final usersRef = FirebaseFirestore.instance.collection('users');

  ///building container for reviews from firestore
  buildFeedbacks(){
  return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('feedbacks')
                .orderBy('Timestamp',descending: true)
                .limit(flimit)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
              if (snapshot.hasError){
                return Center(child: Text('Error loading reviews..'));
              }
              if(snapshot.connectionState==ConnectionState.waiting){
                return Center(
                  child:Text('Loading...'),
                );
              }
              if(snapshot.hasData && snapshot.data?.size==0){
                return Center(
                  child:Padding(
                    padding: const EdgeInsets.all(100.0),
                    child: Text('No Feedbacks yet...'),
                  ),
                );
              }
              return ListView(
                children:snapshot.data!.docs
                    .map((DocumentSnapshot document){
                  Map<String, dynamic> data=
                  document.data()! as Map<String,dynamic>;
                  isShow=true;
                  return Container(
                    margin: EdgeInsets.all(8),
                    color: Colors.white,
                    width:MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder(
                            stream: usersRef.doc(data['OwnerID']).snapshots(),
                            //Resolve Value Available In Our Builder Function
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(child: Text('null'));
                              }
                              //Deserialize
                              //print(widget.profileId);
                              var DocData = snapshot.data as DocumentSnapshot;
                              GUser gUser = GUser.fromDocument(DocData);
                              return Row(
                                mainAxisAlignment:MainAxisAlignment.start,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl:gUser.profilePhotoUrl.toString(),
                                    imageBuilder: (context, imageProvider) => Container(
                                      height: 45,
                                      width: 45,
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
                                      Text((gUser.lname!+" "+gUser.fname!).toString()),
                                      CustomText6(data['Timestamp']),
                                    ],
                                  ),
                                  Expanded(child: SizedBox()),
                                  GestureDetector(
                                      onTap: ()async{

                                      },
                                      child:Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: Colors.green,
                                          ),
                                          child: FittedBox(child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: CustomText4('Read',Colors.white),
                                          )))),
                                ],
                              );
                            }

                        ),

                        Padding(
                          padding: const EdgeInsets.only(left:22.0,top:10,bottom: 22),
                          child:ReadMoreText(
                            data['Content'].toString(),
                            trimLines: 3,
                            colorClickableText: Colors.pink,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: '  Show more',
                            trimExpandedText: '   Show less',
                            moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                                color: Colors.green
                            ),
                            lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                                color: Colors.green
                            ),
                          ),
                        )
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
    void changelimit(){
     flimit+=25;
    }
bool isShow=false;
int flimit=25;
 /* ///method to build username ,time an photo of review container
  buildReviewHeader(){
    return StreamBuilder(
      stream: usersRef.doc(rfrom).get(),
      //Resolve Value Available In Our Builder Function
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        //Deserialize
        //print(widget.profileId);
        var DocData = snapshot.data as QuerySnapshot;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // buildCountColumn(label: 'posts', count: postCount),
            ///Username
            Padding(
              padding: const EdgeInsets.only(left: 11,top:11),
              child: CircleAvatar(
                radius: 20,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl:gUser.profilePhotoUrl!,
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
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:8.0,top:11),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (gUser.lname.toString()+" "+gUser.fname.toString()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(left:2),
                      height:5,
                      width: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:3,top:1),
                      child:Text(gUser.identify_as.toString(),
                        style: TextStyle(
                          fontSize:12,
                          color: Colors.grey,
                        ),),
                    ),
                  ],
                ),
              ],
            ),

          ],
        );
      },
    );
  }
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 90,
        elevation: 0,
        title: CustomText8('User Feedback'),
      ),
      body:PageView(
        children: [
          buildFeedbacks(),
          isShow!=false?
          Center(child: RaisedButton(onPressed:()=>changelimit())):SizedBox(),
        ],
      ),
    );
  }
}
