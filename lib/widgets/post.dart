import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/comments.dart';
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
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String desc;
  final String mediaUrl;
  Map likes;
  int likeCount;
  bool isLiked;
  bool showHeart = false;


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
handleLikePost(){

  bool _isLiked = likes[currentUserId] == true;

  if(_isLiked){
    postsRef
    .document(ownerId)
    .collection("userPosts")
    .document(postId)
    .updateData({
      "likes.$currentUserId" : false
    });
    setState(() {
      likeCount-=1;
      _isLiked = false;
      likes[currentUserId] = false;
    });
  }

  else if(!_isLiked){
    postsRef
    .document(ownerId)
    .collection("userPosts")
    .document(postId)
    .updateData({
      "likes.$currentUserId" : true
    });
    setState(() {
      likeCount+=1;
      _isLiked = true;
      likes[currentUserId] = true;
      showHeart = true;
    });
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        showHeart = false;
      });
    });
  }

}

buildPostImage(){
  return GestureDetector(
    onDoubleTap: handleLikePost,
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        cachedNetworkImage(mediaUrl),
       showHeart ?  Animator(
          duration: Duration(milliseconds: 300),
          tween: Tween(begin: 0.8, end: 1.4),
          curve: Curves.elasticOut,
          cycles: 0,
          builder: (context, anim , child) => Transform.scale(
            scale: anim.value,
            child: Icon(Icons.favorite, size: 80, color: Colors.red),
          ),
        
        ) : Text(""),

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
          onTap: handleLikePost,
          child: Icon(
            isLiked ? Icons.favorite: Icons.favorite_border ,
          size: 28, color: Colors.pink,),
        ),
        Padding(padding: EdgeInsets.only(right: 20),),
        GestureDetector(
          onTap: () => showComments(
            context,
            postId: postId,
            ownerId: ownerId,
            mediaUrl: mediaUrl
          ),
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
    isLiked = (likes[currentUserId] == true);
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

showComments(BuildContext context , {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
    
  }));
}
