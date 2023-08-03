import 'package:chat_app/Classes/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserRepo extends GetxController {
  static UserRepo get to => Get.find();
  final _db = FirebaseFirestore.instance;
  Future<void> createUser(UserModel user) async {
    await _db.collection("Users").add(user.toJason());
  }
}
