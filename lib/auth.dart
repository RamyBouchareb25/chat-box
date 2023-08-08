import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEMailAndPassword(
      {required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _auth.currentUser!.updateDisplayName(name);
    UserModel user = UserModel(
      uid: _auth.currentUser!.uid,
      name: name,
      email: email,
      status: "offline",
      profilePhoto: "",
    );
    FirebaseFirestore.instance.collection("Users").add(user.toMap());
  }

  Future<void> signOut() async {
    await _auth.signOut();
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
  }
}
