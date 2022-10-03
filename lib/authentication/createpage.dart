import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart'as Im;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sates/startup/startpage.dart';
import 'package:sates/authentication/createpage2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sates/authentication/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sates/startup/wrapper.dart';
import 'dart:async';

import 'package:uuid/uuid.dart';

import '../main_pages/home.dart';
import '../widgets/constant_widgets.dart';


final storageRef = FirebaseStorage.instance.ref('Images');
final FirebaseAuth auth =FirebaseAuth.instance;
final usersRef = FirebaseFirestore.instance.collection('users');



class createpage extends StatefulWidget {
  final Function? toggleView;

  createpage({this.toggleView});


  @override
  State<createpage> createState() => _createpageState(
  );
}

class _createpageState extends State<createpage> {
 final bool? newUser=true ;
  FirebaseFirestore firestore= FirebaseFirestore.instance;
 final currentUser= auth.currentUser;
  final AuthService _auth = AuthService();
  String postId=Uuid().v4();
  final _formKey= GlobalKey<FormState>();
  String error="";
  String email="";
  String password="";
  String username="";
  String City="";
  String Address="";



  File? file;

  handleTakePhoto(context)async{
    Navigator.pop(context);
    var image= await ImagePicker.platform.pickImage(source:ImageSource.camera);
    setState((){
      file=File(image!.path);
    });
  }
  handleChooseFromGallery(context)async{
    Navigator.pop(context);
    var image= await ImagePicker.platform.pickImage(source:ImageSource.gallery);
    setState((){
      file=File(image!.path);
    });
  }
  clearImage(){
    setState((){
      file=null;
    });
  }
  selectImage(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Select Image'),
            children: [
              SimpleDialogOption(
                child:Text('Photo with Camera'),
                onPressed:()=>handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child:Text('Choose image from Gallery'),
                onPressed:()=>handleChooseFromGallery(context),
              ),
              SimpleDialogOption(
                child:Text('Cancel'),
                onPressed: ()=>Navigator.pop(context),
              ),
            ],
          );
        }
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    //Read Image File We Have In State Putting It In imageFile
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressesImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 50));
    setState(() {
      file = compressesImageFile;
    });
  }
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
    storageRef.child('profile_$postId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
               children: [
                 SafeArea(
                   child: Container(
                   height: size.height/2.6,
                   color: Colors.white,
                   child: Stack(
                     children:[
                       Image(
                         image:AssetImage('assets/images/sharing.png')),
                       Container(
                         margin: EdgeInsets.all(2),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           children: [
                             GestureDetector(
                               onTap: () {
                                 widget.toggleView!();
                               },
                               child: Container(
                                 alignment: Alignment.center,
                                 margin: EdgeInsets.all(9),
                                 decoration: BoxDecoration(
                                   color: Colors.orange,
                                   borderRadius: BorderRadius.circular(15),
                                   boxShadow: [
                                     BoxShadow(
                                       color: Colors.yellow.withOpacity(0.5),
                                       spreadRadius: 5,
                                       blurRadius: 7,
                                       offset: Offset(0,1),
                                     ),
                                   ],
                                 ),
                                 height: size.height/29,
                                 width: size.width/4,
                                 child: Text(
                                   'Sign In',
                                   style: TextStyle(
                                     fontSize: 14,
                                     color: Colors.white,
                                   ),
                                 ),

                               ),
                             ),
                           ],
                         ),
                       ),
                  ] ),
                     ),
                 ),
                 //create account
                 Padding(
                   padding: const EdgeInsets.only(top: 8.0,bottom: 20),
                   child: Text('Create an account',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       fontFamily: 'Gotham',
                       fontWeight: FontWeight.bold,
                       color: Colors.green,
                       fontSize:30,
                     ),
                   ),
                 ),

                  SizedBox(
                    height: 20,
                  ),
                 ///email
                 Padding(
                   padding: const EdgeInsets.only(left:30,right:30,bottom: 20),
                   child: Container(
                     decoration: BoxDecoration(
                         color: Colors.green.shade50,
                         borderRadius: BorderRadius.circular(20)
                     ),
                     child: Padding(
                       padding: EdgeInsets.only(left:12.0),
                       child: TextFormField(
                         validator: (val)=>val!.isEmpty?'Enter an email':null,
                         onChanged: (val){
                           setState(() => email=val);
                         },
                         decoration: InputDecoration(
                         labelText: 'Email',border: InputBorder.none
                         ),

                       ),
                     ),
                   ),
                 ),
                 ///password
                 Padding(
                   padding: EdgeInsets.only(left:30,right:30,bottom: 20),
                   child: Container(
                     decoration: BoxDecoration(
                         color: Colors.green.shade50,
                         borderRadius: BorderRadius.circular(20)
                     ),
                     child: Padding(
                       padding: EdgeInsets.only(left:12.0),
                       child: TextFormField(
                         validator: (val)=>val!.length< 6 ?'Enter a password 6+ chars long':null,
                         onChanged: (val){
                           setState(() => password=val);
                         },
                         decoration: InputDecoration(
                          labelText: 'Password',border:InputBorder.none
                         ),
                         obscureText: true,
                       ),
                     ),
                   ),
                 ),
                 //DoB
                 Padding(
                   padding: const EdgeInsets.all(20.0),
                   child: SizedBox(
                   ),
                 ),
                 //error
                 Text(error),

               ],
             ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        onPressed: ()async{
          if (_formKey.currentState!.validate()){
            dynamic result = await _auth.registerWithEmailandPassword(
                email,
                password,);

            if (result == null){
              setState(()=>error = 'Please supply a valid email\nor Connect to the internet\nAnd try again.');
            }else{
              final currentUserId= FirebaseAuth.instance.currentUser!.uid;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context)=> Wrapper(id:currentUserId)));
            }

          }
        }, label:CustomText4(
          'Done',Colors.white
      ),
      ),

    );
  }


}
