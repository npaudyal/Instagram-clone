import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String desc;
  final String mediaUrl;
  final dynamic  likes;

  Post({this.postId, this.ownerId, this.username, this.location, this.desc, this.likes, this.mediaUrl });

  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc['PostId'],
       ownerId: doc['ownerId'],
        username: doc['username'],
         location: doc['location'],
          desc: doc['description'],
           mediaUrl: doc['mediaUrl'],
            likes: doc['likes'],
    );
  }

  int getLikeCount(likes){
    if(likes == null){
      return 0;
    }
    int count =0;
    likes.values.forEach((val) {
      if(val==true){
        count+=1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    desc: this.desc,
    mediaUrl: this.mediaUrl,
    likes: this.likes,
    likeCount: getLikeCount(this.likes)


  );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String desc;
  final String mediaUrl;
  Map likes;
  int likeCount;

buildPostHeader(){
  return FutureBuilder(
    future: usersRef.document(ownerId).get(),
    builder: (context, snapshot) {
      if(!snapshot.hasData){
        return circularProgress();
      }
      User user = User.fromDocument(snapshot.data);
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          backgroundColor: Colors.grey,
        ),
        title: GestureDetector(
            onTap: () => print("Person tapped"),
            child: Text(
            user.username,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
        ),
        subtitle: Text(location) ,
        trailing: IconButton(
          icon: Icon(Icons.more_vert),
           onPressed: () => print("deleting post")),
      );
      
    });

}

buildPostImage(){
  return GestureDetector(
    onDoubleTap: () => print("LIcking post"),
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        cachedNetworkImage(mediaUrl),

      ],
    ),
  );

}

buildPostFooter(){
  return Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
        Padding(padding: EdgeInsets.only(top:40, left: 20),),
        GestureDetector(
          onTap: () => print("Liking post"),
          child: Icon(Icons.favorite_border,
          size: 28, color: Colors.pink,),
        ),
        Padding(padding: EdgeInsets.only(right: 20),),
        GestureDetector(
          onTap: () => print("Reading Comments"),
          child: Icon(Icons.chat,
          size: 28, color: Colors.blue[900],),
        ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$likeCount likes",
                style: TextStyle(color: Colors.black,
                fontWeight: FontWeight.bold),


              ),
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$username",
                style: TextStyle(color: Colors.black,
                fontWeight: FontWeight.bold),


              ),
          ),
          Expanded(child: Text(desc))
        ],
      ),
    ],
  );
}
  _PostState({this.postId, this.ownerId, this.username, this.location, this.desc, this.likes, this.mediaUrl, this.likeCount });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
