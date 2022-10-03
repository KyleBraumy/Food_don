import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart'as Im;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sates/startup/wrapper.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../authentication/auth.dart';
import '../main_pages/home.dart';
import '../widgets/progress.dart';




class Createpage3 extends StatefulWidget {

  String fName;
  String lName;
  String address;
  String occupation;
  String identify_as;
  String? works_at;
  String street_name;
  String phone1;
  String? phone2;
  String city;


  Createpage3({

    required this.fName,
    required this.lName,
    required this.address,
    required this.identify_as,
    this.works_at,
    required this.street_name,
    required this.city,
    required this.phone1,
    required this.phone2,
    required this.occupation,
  });

  @override
  State<Createpage3> createState() => _Createpage3State(

  );
}

class _Createpage3State extends State<Createpage3> {

  final usersRef = FirebaseFirestore.instance.collection('users');
  final storageRef = FirebaseStorage.instance.ref('Images');
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final timelineRef = FirebaseFirestore.instance.collection('postsTimeline');

  final AuthService _auth = AuthService();
  final _formkey= GlobalKey<FormState>();
  bool isUploading=false;
  String profilepicId=Uuid().v4();
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;


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

  @override
  void initState() {
    print(widget.works_at);
    super.initState();

  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    //Read Image File We Have In State Putting It In imageFile
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressesImageFile = File('$path/img_$profilepicId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 50));
    setState(() {
      file = compressesImageFile;
    });
  }
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
    storageRef.child('post_$profilepicId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }


 createUserDetails({var timestamp, String? profilephotoUrl,
   String? bio, String? lname, String? fName, String? occupation,
   String? address, String? identify_as, String? works_at, String? street_name,
   String? phone1, String? phone2, String? city
 })  {
     usersRef.doc(currentUserId).update({
      'Timestamp':timestamp,
      'ProfilePhotoUrl':profilephotoUrl,
      'BackProfilePhotoUrl':"",
      'Bio':bio,
      'Address':address,
      'First Name':fName,
      'Last Name':lname,
      'Occupation':occupation,
      'Identify_as':identify_as,
      'No_ppl_rated':0,
      'Rating':"0.0",
      'Rating_value':"0.0",
      'Works_at':works_at,
      'Street name':street_name,
      'City':city,
      'Contact 1':phone1,
      'Contact 2':phone2,
    });
  }

  handleSubmit()async{
    final DateTime timestamp= DateTime.now();
    setState((){
      isUploading=true;
    });
    await compressImage();
    String profilePhotoUrl=await uploadImage(file);

createUserDetails(timestamp:timestamp,
    profilephotoUrl:profilePhotoUrl,
    bio:bio,
    lname:widget.lName,
    fName:widget.fName,
    occupation:widget.occupation,
    address:widget.address,
    identify_as:widget.identify_as,
    works_at:widget.works_at,
    street_name:widget.street_name,
    phone1:widget.phone1,
    phone2:widget.phone2,
    city:widget.city,
);
    setState((){
      isUploading=false;
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Wrapper()));


  }

  String empty='You cannot leave this field empty';
  var bio;
  String error='';



  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child:Column(
            children: [
              isUploading? linearProgress():SizedBox(),
              file==null ?
              Container(
                margin: EdgeInsets.only(top:8),
                width: MediaQuery.of(context).size.width/2,
               height: MediaQuery.of(context).size.height/4,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100.withOpacity(0.3),
                     // borderRadius: BorderRadius.circular(20),
                      shape: BoxShape.circle,
                    border:Border.all(
                        width: 1,
                        color: Colors.orange
                    ),
                  ),

                child: Center(
                    child: Icon(Icons.person_outline_rounded,size:70,color:Colors.orange.withOpacity(0.7),),
              )):
              Container(
                margin: EdgeInsets.only(top:8),
                width: MediaQuery.of(context).size.width/2,
                height: MediaQuery.of(context).size.height/4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                    border:Border.all(
                        width: 1,
                        color: Colors.orange
                    ),
                    image: DecorationImage(
                        image: FileImage(file!),
                        fit: BoxFit.fitWidth
                    )
                ),
              ),
              ///Image upload Container
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      elevation: 2,
                        color: Colors.orange,
                        onPressed:isUploading?null:()=>selectImage(context),
                        child: file==null? Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right:8.0),
                              child: Icon(Icons.image_outlined,color: Colors.white,),
                            ),
                            Text('Upload Image',
                              style: TextStyle(color: Colors.white,
                                fontFamily: 'Gotham',
                                  fontWeight: FontWeight.bold,
                                fontSize:12,
                              ),),
                          ],
                        ):
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right:8.0),
                              child: Icon(Icons.image_outlined,color: Colors.white,),
                            ),
                            Text('Change Image',
                              style: TextStyle(color: Colors.white,
                                fontFamily: 'Gotham',
                                fontWeight: FontWeight.bold,
                                fontSize:12,
                              ),),
                          ],
                        )

                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: SizedBox(
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap:isUploading?null:()=>clearImage(),
                      child: FittedBox(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade100.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 0.5,
                              color: Colors.orange,
                            ),

                          ),

                          margin: EdgeInsets.all(8.0),
                         child: Padding(
                           padding: const EdgeInsets.all(5.0),
                           child: Row(
                             children: [
                               Icon(Icons.clear,size: 15,color: Colors.red,),
                               Text('Clear Image',
                                  style: TextStyle(color: Colors.red,
                                  fontFamily: 'Gotham',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                  ),),
                             ],
                           ),
                         ),
                        ),
                      ),
                    ),
                    
                  ),
                ],
              ),
              Form(
                key:_formkey,
                child: Column(
                  children: [
                    SizedBox(height: 20.0),
                    ///bio
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
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            readOnly: isUploading?true:false,
                            style: TextStyle(
                              overflow:TextOverflow.visible
                            ),
                            validator: (val)=>val!.isEmpty?empty:null,
                            onChanged: (val){
                              setState(() => bio=val);
                            },
                            decoration: InputDecoration(
                              labelText: '   Bio',border: InputBorder.none
                            ),

                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ///Dropdown
                    SizedBox(height: 20.0),

                    Text(error),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      ///Post button
      floatingActionButton: file==null?
      SizedBox():
      FloatingActionButton.extended(
        isExtended: true,
        onPressed:isUploading?null: ()async{
          if (_formkey.currentState!.validate()) {
            setState(() => handleSubmit(),);
          }
        }, label:Text(
        'Done',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      ),
    );

  }

}



