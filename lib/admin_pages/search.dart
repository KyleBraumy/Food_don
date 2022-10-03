import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main_pages/profile.dart';
import '../models/userfiles.dart';
import '../widgets/progress.dart';
import 'displayUserInformation.dart';

class Search extends StatefulWidget {
  final Function? toggleView;
  Search({this.toggleView});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
   Future<QuerySnapshot>? searchResultsFuture;
  final usersRef = FirebaseFirestore.instance.collection('users');
  final _formkey= GlobalKey<FormState>();
  List<UserResult> searchResults = [];

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where('First Name', isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      searchResultsFuture = users;
    });
  }
bool isLoading=false;
  var query;

  callback(){
    setState(() {
      isSearch=true;
    });
  }



  clearSearch() {
    searchController.clear();
  }
bool isSearch=false;
  AppBar buildSearchField() {
    return AppBar(
      toolbarHeight: 90,
      backgroundColor: Colors.white,

      title: Form(
        key: _formkey,
        child: TextFormField(
          textCapitalization:TextCapitalization.sentences,
          controller: searchController,
          validator: (val)=>val!.isEmpty?'':callback(),
          onChanged: (val)async{
           setState(()=>query=searchController.text.capitalize());
           val.isEmpty?buildNoContent():buildSearchResults();
          },
          decoration: InputDecoration(
            hintText: 'Search For A User...',
            filled: true,
            prefixIcon:isSearch?GestureDetector(
              child: Icon(Icons.search),
              onTap: () async{
                setState(()=>query=searchController.text.capitalize());
                await query;
                print(query);
                await buildSearchResults();
              },
            ):SizedBox(),
            suffixIcon:isSearch?GestureDetector(
              child: Icon(Icons.clear),
              onTap: () {
                clearSearch();
              },
              onDoubleTap: (){
                widget.toggleView!();
              },
            ):SizedBox(),
          ),
        ),
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        //So You WOnt Get Keyboard Error Because It Resize
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.00,
              ),
            )
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    if (_formkey.currentState!.validate()){
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('Last Name',isGreaterThanOrEqualTo:query)
              .orderBy('Last Name',descending: false)
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
              return buildNoContent();
            }
            return Column(
              children: [
                Column(
                  children:snapshot.data!.docs
                      .map((DocumentSnapshot document){
                    Map<String, dynamic> data=
                    document.data()! as Map<String,dynamic>;
                    return Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () =>  Navigator.push(context,
                                MaterialPageRoute(builder: (context)=>
                                    DisplayUserInformation(
                                      id: data['Id'],
                                      email: data['Email'],
                                      Fname: data['First Name'],
                                      city: data['City'],
                                      phone1: data['Contact 1'],
                                      phone2: data['Contact 2'],
                                      Lname: data['Last Name'],
                                      rate: data['Rating'],
                                      ratevalue: data['Rating_value'],
                                      no_rate_ppl: data['No_ppl_rated'],
                                      profilephotoUrl: data['ProfilePhotoUrl'],
                                      coverphotoUrl: data['BackProfilePhotoUrl'],
                                      bio: data['Bio'],
                                      address: data['Address'],
                                      occupation: data['Occupation'],
                                      works_at: data['Works_at'],
                                      identify_as: data['Identify_as'],
                                      streetName: data['Street name'],

                                    ))),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: CachedNetworkImageProvider(data['ProfilePhotoUrl'].toString()),
                              ),
                              title: Text(
                                data['Last Name'].toString()+" "+data['First Name'],
                                style:
                                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                data['Email'].toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Divider(
                            height: 2.0,
                            color: Colors.white54,
                          )
                        ],
                      ),
                    );

                  })
                      .toList()

                      .cast(),

                ),
                GestureDetector(
                  onTap: (){
                    setState(()=>flimit+=2);
                  },
                  child: Text('See more',style:TextStyle(color: Colors.green),),
                ),
              ],
            );
          }
      );
    }else{
      return SizedBox();
    }

  }

  //AutomaticKeepAliveClientMixin Requirement #2
  bool get wantKeepAlive => true;
int flimit=1;
  @override
  Widget build(BuildContext context) {
    //AutomaticKeepAliveClientMixin Requirement #3
    super.build(context);
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: buildSearchField(),
      body:query==null?SizedBox():
      buildSearchResults(),

    );
  }
}

class UserResult extends StatelessWidget {
  final GUser user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => Profile(profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.profilePhotoUrl!),
              ),
              title: Text(
                user.lname!+" "+user.fname!,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.email!,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}