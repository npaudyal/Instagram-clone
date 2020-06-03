import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';



final GoogleSignIn googleSignIn = GoogleSignIn(); 

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  handleSignIn(GoogleSignInAccount account){
     if(account !=null){
          print('User signed in: $account');
          setState(() {
            isAuth = true;
          });
        }
        else {
          setState(() {
            isAuth = false;
          });
        }
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
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),

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
