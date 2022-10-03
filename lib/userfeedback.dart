import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UserFeedbacks extends StatefulWidget {
  const UserFeedbacks({Key? key}) : super(key: key);

  @override
  State<UserFeedbacks> createState() => _UserFeedbacksState();
}


class _UserFeedbacksState extends State<UserFeedbacks> {
  bool isSending=false;
  var fdback;
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  String feedbackId= Uuid().v4();

  final feedbacksRef=FirebaseFirestore.instance.collection('feedbacks');
final TextEditingController _textEditingController=TextEditingController();

  handleSendFeedack()async{
    final DateTime timestamp= DateTime.now();
    setState((){
      isSending=true;
    });
    await feedbacksRef.doc(feedbackId).set({
      'OwnerID':currentUserId,
      'Feedback_Id':feedbackId,
      'Timestamp':timestamp,
      'Read':false,
      'Content':fdback,
      'Expire_at':timestamp.add(Duration(days:30))
    });
    setState((){
      isSending=false;
      String feedbackId= Uuid().v4();
      fdback='';
    });
    _textEditingController.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:SingleChildScrollView(
        child:Column(
          children: [
            Container(
              margin:EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: Colors.green.shade100.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: TextFormField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    maxLength:500,
                    readOnly: isSending?true:false,
                    style: TextStyle(
                        overflow:TextOverflow.visible
                    ),
                    validator:(val)=>val==''?null:null,
                    onChanged:(val){
                      setState(() =>fdback=val);
                    },
                    decoration: InputDecoration(
                        labelText: '   Type Something',border: InputBorder.none
                    ),

                  ),
                ),
              ),
            ),
            RaisedButton(
                onPressed: ()=>handleSendFeedack(),
                child: Text('Send feedback')),
          ],
        ),
      )
    );
  }
}
