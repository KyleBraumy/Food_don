import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../widgets/constant_widgets.dart';

class DisplayUserInformation extends StatefulWidget {
  var Fname;
  var Lname;
  var streetName;
  var city;
  var phone1;
  var phone2;
  var address;
  var works_at;
  var id;
  String? rate;
  String? ratevalue;
  int? no_rate_ppl;
  var email;
  var bio;
  var occupation;
  var identify_as;
  var profilephotoUrl;
  var coverphotoUrl;

  DisplayUserInformation({
    this.Fname,
    this.Lname,
    this.streetName,
    this.city,
    this.email,
    this.rate,
    this.ratevalue,
    this.no_rate_ppl,
    this.bio,
    this.phone1,
    this.id,
    this.phone2,
    this.address,
    this.works_at,
    this.occupation,
    this.profilephotoUrl,
    this.coverphotoUrl,
    this.identify_as,
  });

  @override
  State<DisplayUserInformation> createState() => _DisplayUserInformationState();
}

class _DisplayUserInformationState extends State<DisplayUserInformation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title:CustomText8('User Details'),
      ),
      body: SingleChildScrollView(
        child:
        Container(
          color: Colors.green.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl:widget.profilephotoUrl,
                imageBuilder: (context, imageProvider) => Container(
                  height: 170,
                  width: 200,
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
              CustomText2(widget.id),
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
                          initialValue:widget.Lname,
                          decoration: InputDecoration(
                            labelText:'Last Name',
                           border: InputBorder.none, /*OutlineInputBorder(
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
                          initialValue:widget.Fname,
                          decoration: InputDecoration(
                            labelText:'First Name',
                            border: InputBorder.none, /*OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),*/
                          ),

                        ),
                      ),
                    ),
                    Container(
                      margin:  EdgeInsets.fromLTRB(30.0,0,30,20),
                      decoration: BoxDecoration(
                          color: Colors.green.shade100.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left:8.0),
                        child: TextFormField(
                          initialValue:widget.identify_as,
                          decoration: InputDecoration(
                            labelText:'Identify_as',
                            border: InputBorder.none, /*OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),*/
                          ),

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
                          initialValue:widget.phone1,
                          decoration: InputDecoration(
                            labelText:'Contact line 1',
                            border: InputBorder.none, /*OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),*/
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
                          initialValue:widget.phone2,
                          decoration: InputDecoration(
                            labelText:'Contact line 2',
                            border: InputBorder.none, /*OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),*/
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
                          initialValue:widget.address,
                          decoration: InputDecoration(
                            labelText:'Address',
                            border: InputBorder.none, /*OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),*/
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
                          initialValue:widget.streetName,
                          decoration: InputDecoration(
                            labelText:'Street name',
                            border: InputBorder.none, /*OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),*/
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30.0,10,30,10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green.shade100.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: TextFormField(
                          initialValue:widget.city,
                          decoration: InputDecoration(
                            labelText:'City',
                            border: InputBorder.none, /*OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),*/
                          ),
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
                          initialValue:widget.occupation,
                          decoration: InputDecoration(
                            labelText:'Occupation',
                            border: InputBorder.none, /*OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),*/
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
                          initialValue:widget.works_at,
                          decoration: InputDecoration(
                            labelText:'Works at',
                            border: InputBorder.none, /*OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),*/
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
    );
  }
}
