

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';


final GoogleSignIn googleSignIn = GoogleSignIn(); 
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final timelineRef = Firestore.instance.collection('timeline');

final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');


final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection("comments");
final activityFeedRef = Firestore.instance.collection("activityFeed");

User currentUser;
final DateTime timestamp = DateTime.now();
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  

  @override
  void initState() { 
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {

       handleSignIn(account);
     }, onError: (err) {
        print(err);
     });
    //Reauthenticate users when app is opened

    googleSignIn.signInSilently()
    .then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print(err);
    });


  }   

      createUserInFirestore()async {
           final GoogleSignInAccount user =  googleSignIn.currentUser;
           DocumentSnapshot doc = await usersRef.document(user.id).get();

          if(!doc.exists){
            final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => 
            CreateAccount()));
          

          usersRef.document(user.id).setData({
            "id": user.id,
            "username": username,
            "photoUrl": user.photoUrl,
            "email": user.email,
            "displayName": user.displayName,
            "bio": "",
            "timestamp":timestamp 

          });

          await followersRef
          .document(user.id)
          .collection("userFollowers")
          .document(user.id)
          .setData({});


          doc = await usersRef.document(user.id).get();
          }

          currentUser = User.fromDocument(doc);
           //So that it counld be passed on to different pages 
           print(currentUser);
          }

  handleSignIn(GoogleSignInAccount account )async {
     if(account !=null){
          await createUserInFirestore();
          
          setState(() {
            isAuth = true;
          });

         configurePushNotifications();

        }
        else {
          setState(() {
            isAuth = false;
          });
        }
  }
configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      // print("Firebase Messaging Token: $token\n");
      usersRef
          .document(user.id)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        // print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
          // print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
        // print("Notification NOT shown");
      },
    );
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      // print("Settings registered: $settings");
    });
  }

@override
void dispose() {
  pageController.dispose();
  super.dispose();
}
  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onTap(int pageIndex) {
    pageController.animateToPage
    (pageIndex,
    duration: Duration(milliseconds :300),
    curve: Curves.bounceInOut
    );
  }
  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  Widget buildAuthScreen() {

    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
         Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),

        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),),
             BottomNavigationBarItem(
            icon:Icon(Icons.notifications_active),),
             BottomNavigationBarItem(
            icon:Icon(Icons.photo_camera, size: 36.0),),
             BottomNavigationBarItem(
            icon:Icon(Icons.search),),
             BottomNavigationBarItem(
            icon:Icon(Icons.account_circle),),
          
        ],
      ),
    );
    // return RaisedButton(
    //   child: Text("Logout"),
    //   onPressed: logout,
    // );
  }

  
  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
                
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'FutterShare',
                  style: TextStyle(
                  fontFamily: 'Signatra',
                  fontSize: 50.0,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap:
                    login,
                

                child: Container(
                  width: 260.0,
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  )),
                ),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
