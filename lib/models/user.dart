import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String bio, email;
  final String displayName;
 final String id;
  final String username;
  final String photoUrl;

User({
  this.id,
  this.email,
  this.displayName,
  this.photoUrl,
  this.username,
  this.bio
});

factory User.fromDocument(DocumentSnapshot doc) {
  return User(
    id: doc['id'],
    email: doc['email'],
    username: doc['username'],
    photoUrl: doc["photoUrl"],
    bio: doc["bio"],
    displayName: doc["displayName"]

  );
}

}
