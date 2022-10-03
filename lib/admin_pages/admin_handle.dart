
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

import '../models/post.dart';
import '../widgets/constant_widgets.dart';

class Admin_handle extends StatefulWidget {
  const Admin_handle({Key? key}) : super(key: key);

  @override
  State<Admin_handle> createState() => _Admin_handleState();
}

class _Admin_handleState extends State<Admin_handle> {
  final PageController _pageController= PageController();
  TextEditingController searchController = TextEditingController();
  final timelineRef = FirebaseFirestore.instance.collection('postsTimeline');
  final postsRef = FirebaseFirestore.instance.collection('posts');
  var query;
  final _formkey= GlobalKey<FormState>();
  bool isLoading=false;
  int pageIndex=0;
  List<Post>posts=[];
  onPageChanged(int pageIndex){
    setState((){
      this.pageIndex = pageIndex;
    });
  }


  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }
  onTap(int pageIndex){
    _pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 250),
        curve: Curves.bounceInOut
    );
  }
  callback(){
   return AlertDialog();
  }
  getPost()async{
    QuerySnapshot snapshot=
    await timelineRef
        .where('PostId',isEqualTo:query)
        .get();
    List<Post> posts=snapshot.docs.map((doc)=>Post.fromDocument(doc))
        .toList();
    this.posts=posts;
  }

  buildSearchResults() {
    if (_formkey.currentState!.validate()){
      getPost();

      if(posts.length==0){
        return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nothing to see here....',
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.5)
                  ),
                ),
              ],
            )
        );
      }else{
        print(posts.length);
        return ListView(children:posts);
      }
    }else{
      return SizedBox();
    }

  }
  postDelete(){
    if(posts.length==0){
      return Form(
        key: _formkey,
        child: TextFormField(
          //textCapitalization:TextCapitalization.sentences,
          controller: searchController,
          validator: (val)=>val!.isEmpty?callback():null,
          onChanged: (val)async{
            setState(()=>query=val);
          },
          decoration: InputDecoration(
            hintText: 'Search For A User...',
            filled: true,
            suffixIcon:posts.length==0?
            GestureDetector(
              child: Icon(Icons.search),
              onTap: () async{
                await query;
                await getPost();

              },
            ):
            GestureDetector(
              child: Icon(Icons.delete),
              onTap: () async{
               del(query);
              },
            ),
          ),
        ),
      );
    }else{
      print(posts.length);

      return Column(
        children: [
          Form(
            key: _formkey,
            child: TextFormField(
              //textCapitalization:TextCapitalization.sentences,
              controller: searchController,
              validator: (val)=>val!.isEmpty?callback():null,
              onChanged: (val)async{
                setState(()=>query=val);
              },
              decoration: InputDecoration(
                hintText: 'Search For A User...',
                filled: true,
                suffixIcon:posts.length==0?
                GestureDetector(
                  child: Icon(Icons.search),
                  onTap: () async{
                    await query;
                    await getPost();

                  },
                ):
                GestureDetector(
                  child: Icon(Icons.delete),
                  onTap: () async{
                    del(query);
                  },
                ),
              ),
            ),
          ),
          Column(children:posts),
        ],
      );
    }
  }
  delete(String? id){
    timelineRef
    .doc(query)
        .delete();
  }
  del( String? id){
    return showDialog(
        context:  context,
        builder: (context){
          return SimpleDialog(
            title: Text('Delete post?'),
            children: [
              Row(
                children: [
                  SimpleDialogOption(
                    child:Text('Yes'),
                    onPressed:()=>
                        delete(id),
                  ),
                  SimpleDialogOption(
                    child:Text('No'),
                   onPressed: ()=>Navigator.pop(context),

                  ),
                ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        elevation: 0,
        title: CustomText8('Handle User Post'),
      ),
      body: SingleChildScrollView(
        child: postDelete(),
      ),
    );
  }
}
