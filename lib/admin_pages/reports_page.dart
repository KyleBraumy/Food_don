
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../models/userfiles.dart';
import '../widgets/constant_widgets.dart';

class Reportsp extends StatefulWidget {
  const Reportsp({Key? key}) : super(key: key);

  @override
  State<Reportsp> createState() => _ReportspState();
}

class _ReportspState extends State<Reportsp> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final reportsRef = FirebaseFirestore.instance.collection('reports');

var rport_id;
del()async{
  await rport_id;
reportsRef
.doc(rport_id)
    .delete();
}

clear()async{
  await rport_id;
  reportsRef
      .doc(rport_id)
      .update({
    'Handled':true
  });
}
  buildReports(){
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('Timestamp',descending: true)
            .where('Handled',isEqualTo:false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Center(child: Text('Error loading reports..'));
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
                child: Text('No reports yet...'),
              ),
            );
          }
          return ListView(
            children:snapshot.data!.docs
                .map((DocumentSnapshot document){
              Map<String, dynamic> data=
              document.data()! as Map<String,dynamic>;
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
                                     rport_id=data['Report_Id'];
                                       del();
                                  },
                                  child:Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.delete,color: Colors.red,),
                                  )),
                            ],
                          );
                        }

                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:22.0,top:10,bottom: 22),
                      child:Row(
                        children: [
                          CustomText2('Reported user for '),
                          CustomText4(data['Content'].toString(),Colors.red),

                        ],
                      )
                    ),
                    GestureDetector(
                      child: StreamBuilder(
                          stream: usersRef.doc(data['PostOwnerID']).snapshots(),
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
                                  ],
                                ),
                                Expanded(child: SizedBox()),
                                GestureDetector(
                                    onTap: ()async{
                                      rport_id=data['Report_Id'];
                                      clear();
                                    },
                                    child:Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: Colors.green.shade50,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: CustomText2('Clear'),
                                          )),
                                    )),
                              ],
                            );
                          }

                      ),
                      onLongPress:()=> showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context){
                            return DraggableScrollableSheet(
                                      expand: false,
                                      initialChildSize: 0.3,
                                      minChildSize: 0.3,
                                      maxChildSize: 0.3,
                                      builder: (BuildContext context, ScrollController scrollcontroller){
                                        return Column(
                                          children:[
                                            ListTile(
                                              title: Text('Delete user'),
                                            ),
                                            ListTile(
                                              title: Text('Disable user'),
                                            ),
                                            ListTile(
                                              title: Text('Delete Post'),
                                            ),
                                          ],
                                        );
                                      }
                                  );

                          }
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 90,
        elevation: 0,
        title: CustomText8('Reports'),
      ),
      body:PageView(
        children: [
          buildReports(),
        ],
      ),
    );
  }
}
