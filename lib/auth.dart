import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEMailAndPassword(
      {required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    
    
  }

  Future<void> resetPass() async {
    await _auth.sendPasswordResetEmail(email: "drboucharebsarah@gmail.com");
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String token,
  }) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _auth.currentUser!.updateDisplayName(name);
    UserModel user = UserModel(
      uid: _auth.currentUser!.uid,
      name: name,
      email: email,
      status: "online",
      profilePhoto: "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Images%2FProfile-Dark.png?alt=media&token=14a7aa82-5323-4903-90fc-a2738bd42577",
      token: [token]
    );
    FirebaseFirestore.instance.collection("Users").add(user.toMap());
  }

  Future<void> signOut() async {
    FirebaseFirestore.instance
        .collection("Users")
        .where("UserId", isEqualTo: Auth().currentUser!.uid)
        .get()
        .then((value) {
      for (var element in value.docs) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(element.id)
            .update({"Status": "offline"});
      }
    });
    await _auth.signOut();
  }
}
