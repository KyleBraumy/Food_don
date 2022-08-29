import 'package:flutter/material.dart';
import 'package:sates/authentication/signin.dart';
import 'package:sates/startup/startpage.dart';

import 'createpage3.dart';

class createpage2 extends StatefulWidget {
 String email;
 String password;
 createpage2({required this.email,required this.password});

  @override
  State<createpage2> createState() => _createpage2State();
}

class _createpage2State extends State<createpage2> {
  final _formKey= GlobalKey<FormState>();

 String empty='You cannot leave this empty';
 String numbersyntax='Enter Without initial zero \n Check to make sure there are 9 digits';
  var fName;
  var lName;
  var address;
  var occupation;
  var city;
  var phone1;
  var phone2;
  var street_name;
  var identify_as;
  var res_Id="Select an identity";
  var res_C="Select city closest to your residence";
  var works_at;
  var ccode="+233";

  void dropdownCallback(selectedValue){

    setState((){
      identify_as= selectedValue;
    });
  }

  void dropdownCallback2(selectedValue){
    setState((){
      city= selectedValue;
    });
  }


  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: Text('Creating account (2/3)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily:'Gotham',
            color: Colors.white,
            fontSize:20,
            fontWeight: FontWeight.bold,

          ),
        ),
      ),
      body: SingleChildScrollView(
      child:
       Form(
                 key: _formKey,
                 child: Container(
                   color: Colors.green.withOpacity(0.1),

                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Container(
                         width: size.width,
                         height: size.height/4,
                         child: SafeArea(
                           child: Center(
                             child: Text('Food Share',
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                 fontFamily:'Gotham',
                                 color: Colors.white,
                                 fontSize:10,
                                 fontWeight: FontWeight.bold,

                               ),
                             ),
                           ),
                         ),
                         decoration: BoxDecoration(
                             color: Colors.green,
                             borderRadius: BorderRadius.only(bottomLeft:Radius.circular(20),bottomRight:Radius.circular(20))
                         ),
                       ) ,
                       ///Identity section
                       Container(
                         decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(20)
                         ),
                         margin: EdgeInsets.all(18.0),
                         child: Column(
                           children: [
                             ///Identification
                             Padding(
                               padding: const EdgeInsets.all(8.0),
                               child: Text('Identification',
                                 style: TextStyle(
                                 fontFamily: 'Gotham',
                                 color: Colors.orange.withOpacity(0.6),
                                 fontSize:14,
                                   fontWeight: FontWeight.bold,
                                     letterSpacing: 2
                               ),
                              ),
                             ),
                             ///Last Name
                             Container(
                               margin: EdgeInsets.fromLTRB(30.0,10,30,20),
                               decoration: BoxDecoration(
                                   color: Colors.green.shade100.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(20)
                               ),
                               child: Padding(
                                 padding: const EdgeInsets.only(left:8.0),
                                 child: TextFormField(
                                   validator: (val)=>val!.isEmpty?'Enter your Last Name':null,
                                   onChanged: (val){
                                     setState(()=> lName=val
                                     );
                                   },
                                   decoration: InputDecoration(
                                    labelText: '   Enter your Last Name',border: InputBorder.none, /*OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(10),
                                   ),*/
                                   ),

                                 ),
                               ),
                             ),
                             ///First Name
                             Container(
                               margin:  EdgeInsets.fromLTRB(30.0,0,30,20),
                               decoration: BoxDecoration(
                                   color: Colors.green.shade100.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(20)
                               ),
                               child: Padding(
                                 padding: const EdgeInsets.only(left:8.0),
                                 child: TextFormField(

                                   validator: (val)=>val!.isEmpty?empty:null,
                                   onChanged: (val){
                                     setState(()=> fName=val
                                     );
                                   },
                                   decoration: InputDecoration(
                                     labelText: '  Enter your First name',border: InputBorder.none
                                   ),

                                 ),
                               ),
                             ),
                             ///Identify_as
                             Container(
                               decoration: BoxDecoration(
                                   color: Colors.green.shade100.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(15)
                               ),
                               height:size.height/17,

                               margin:EdgeInsets.fromLTRB(30.0,0,30,30),
                               child: Center(
                                 child: DropdownButton(
                                   hint: Padding(
                                     padding: const EdgeInsets.all(4.0),
                                     child: FittedBox(child: Text("  " +res_Id)),
                                   ),
                                   isExpanded: true,
                                   isDense: true,
                                   alignment: AlignmentDirectional.centerEnd,
                                   dropdownColor: Colors.white,
                                   elevation: 1,
                                   // itemHeight:48,
                                   underline: SizedBox(),
                                   value:identify_as,
                                   focusColor: Colors.white,
                                   style: TextStyle(
                                       fontSize: 20,
                                       color: Colors.orange
                                   ),
                                   items:[
                                     DropdownMenuItem(
                                       child:Text('Organization'),value: "Organization",
                                     ),
                                     DropdownMenuItem(
                                       child:Text('Individual'),value: "Individual",
                                     ),
                                   ],
                                   onChanged:dropdownCallback,
                                 ),
                               ),
                             ),
                             ///First phone number
                             Container(
                               margin:  EdgeInsets.fromLTRB(30.0,0,30,20),
                               decoration: BoxDecoration(
                                   color: Colors.green.shade100.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(20)
                               ),
                               child: Padding(
                                 padding: const EdgeInsets.only(left:8.0),
                                 child: TextFormField(
                                   validator: (val)=>val!.isEmpty?empty:
                                  (val.length>=10 || val.length<9 ?numbersyntax:null),
                                   onChanged: (val){
                                     setState(()=> phone1=val
                                     );
                                   },
                                   decoration: InputDecoration(
                                       labelText: '  Contact 1',border: InputBorder.none
                                   ),

                                 ),
                               ),
                             ),
                             ///Second phone number
                             Container(
                               margin: EdgeInsets.fromLTRB(30.0,0,30,20),
                               decoration: BoxDecoration(
                                   color: Colors.green.shade100.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(20)
                               ),
                               child: Padding(
                                 padding: const EdgeInsets.only(left:8.0),
                                 child: TextFormField(
                                   validator:(val)=>val!.isEmpty?empty:
                                   (val.length>=10 || val.length<9 ?numbersyntax:null),
                                   onChanged: (val){
                                     setState(()=> phone2=val
                                     );
                                   },
                                   decoration: InputDecoration(
                                       labelText: '  Contact 2',border: InputBorder.none
                                   ),

                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
                       ///Address section
                       Container(
                         decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(20)
                         ),
                         margin: EdgeInsets.fromLTRB(18.0,0,18,18),
                         child: Column(
                           children: [
                             ///Address title
                             Padding(
                               padding: const EdgeInsets.all(8.0),
                               child: Text('Address',
                                 style: TextStyle(
                                     fontFamily: 'Gotham',
                                     color: Colors.orange.withOpacity(0.6),
                                     fontSize:14,
                                     fontWeight: FontWeight.bold,
                                     letterSpacing: 2
                                 ),
                               ),
                             ),
                             ///Address
                             Padding(
                               padding: const EdgeInsets.fromLTRB(30.0,10,30,10),
                               child: Container(
                                 decoration: BoxDecoration(
                                     color: Colors.green.shade100.withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(20)
                                 ),
                                 child: TextFormField(
                                   validator: (val)=>val!.isEmpty?empty:null,
                                   onChanged: (val){
                                     setState(()=> address=val
                                     );
                                   },

                                   decoration: InputDecoration(
                                    labelText: '  Residential address',border: InputBorder.none
                                   ),
                                 ),
                               ),
                             ),
                             ///street_name
                             Padding(
                               padding: const EdgeInsets.fromLTRB(30.0,10,30,10),
                               child: Container(
                                 decoration: BoxDecoration(
                                     color: Colors.green.shade100.withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(20)
                                 ),
                                 child: TextFormField(
                                   validator: (val)=>val!.isEmpty?empty:null,
                                   onChanged: (val){
                                     setState(()=> street_name=val
                                     );
                                   },

                                   decoration: InputDecoration(
                                    labelText: ' Street name',border: InputBorder.none
                                   ),
                                 ),
                               ),
                             ),
                             ///city
                             Container(
                               height:size.height/17,
                               margin: EdgeInsets.fromLTRB(30.0,10,30,10),
                               decoration: BoxDecoration(
                                   color: Colors.green.shade100.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(20)
                               ),
                               child: Center(
                                 child: DropdownButton(
                                   hint: Padding(
                                     padding: const EdgeInsets.all(4.0),
                                     child: FittedBox(child: Text("  "+res_C)),
                                   ),
                                   isExpanded: true,
                                   isDense: true,
                                   alignment: AlignmentDirectional.centerEnd,
                                   dropdownColor: Colors.white,
                                   elevation: 1,
                                   // itemHeight:48,
                                   underline: SizedBox(),
                                   value:city,
                                   focusColor: Colors.white,
                                   style: TextStyle(
                                       fontSize: 20,
                                       color: Colors.orange
                                   ),
                                   items:[
                                     DropdownMenuItem(
                                       child:Text('Accra'),value: "Accra",
                                     ),
                                     DropdownMenuItem(
                                       child:Text('Central'),value: "Central",
                                     ),
                                     DropdownMenuItem(
                                       child:Text('Kumasi'),value: "Kumasi",
                                     ),
                                   ],
                                   onChanged:dropdownCallback2,
                                 ),
                               ),
                             ),

                           ],
                         ),
                       ),
                       ///employment section
                       Container(
                         decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(20)
                         ),
                         margin: EdgeInsets.fromLTRB(18.0,0,18,18),
                         child: Column(
                           children: [
                             ///Employment title
                             Padding(
                               padding: const EdgeInsets.all(4.0),
                               child: Text('Employment',
                                 style: TextStyle(
                                     fontFamily: 'Gotham',
                                     color: Colors.orange.withOpacity(0.6),
                                     fontSize:14,
                                     fontWeight: FontWeight.bold,
                                     letterSpacing: 2
                                 ),
                               ),
                             ),
                             ///Occupation
                             Padding(
                               padding: EdgeInsets.fromLTRB(30.0,10,30,10),
                               child: Container(
                                 decoration: BoxDecoration(
                                     color: Colors.green.shade100.withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(20)
                                 ),
                                 child: TextFormField(
                                   validator: (val)=>val!.isEmpty?empty:null,
                                   onChanged: (val){
                                     setState(()=> occupation=val
                                     );
                                   },

                                   decoration: InputDecoration(
                                       labelText: '   Occupation',border:InputBorder.none
                                   ),
                                 ),
                               ),
                             ),
                             ///works_at
                             Padding(
                               padding: const EdgeInsets.fromLTRB(30.0,10,30,30),
                               child: Container(
                                 decoration: BoxDecoration(
                                     color: Colors.green.shade100.withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(20)
                                 ),
                                 child: TextFormField(
                                  onChanged: (val){
                                     setState(()=> works_at=val
                                     );

                                   },

                                   decoration: InputDecoration(
                                   labelText: '  Where do you work at?',border:InputBorder.none
                                   ),
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(20.0),
                         child: SizedBox(
                         ),
                       ),

                     ],
                   ),
                 ),
               ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        onPressed: ()async{

          if (_formKey.currentState!.validate()){
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context)=> Createpage3(
                  email: widget.email,
                  password: widget.password,
                  fName: fName,
                  lName: lName,
                  address: address,
                  occupation: occupation,
                  city:city,
                  phone1:phone1,
                  phone2:phone2,
                  identify_as:identify_as,
                  street_name:street_name,
                  works_at:works_at,

                )));

            // dynamic result = await _auth.registerWithEmailandPassword(email, password,username,profilePhotoUrl);
            /*  if (result == null){
                               setState(()=>error = 'Please supply a valid email\nor Connect to the internet\nAnd try again.');
                             }else{
                               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> home()));
                             }
*/
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
