import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthGoogle {
  Future<UserCredential> signInWithGoogle({required String token}) async {
    final GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleAccount!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCred =
        await FirebaseAuth.instance.signInWithCredential(credential);
    UserModel userModel = UserModel(
        uid: userCred.user!.uid,
        name: userCred.user!.displayName,
        email: userCred.user!.email,
        status: "online",
        profilePhoto: userCred.user!.photoURL ??
            "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Images%2FProfile-Dark.png?alt=media&token=14a7aa82-5323-4903-90fc-a2738bd42577",
        token: [token]);
    var value = await FirebaseFirestore.instance
        .collection("Users")
        .where("UserId", isEqualTo: userCred.user!.uid)
        .get();
    if (value.docs.isEmpty) {
      FirebaseFirestore.instance.collection("Users").add(userModel.toMap());
    }
    return userCred;
  }
}
