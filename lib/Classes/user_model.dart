class UserModel {
  final String? uid;
  final String? email;
  final String? password;
  final String? name;

  UserModel({this.uid, this.email, this.password, this.name});

  toJason() {
    return {
      "uid": uid,
      "email": email,
      "password": password,
      "name": name,
    };
  }
}
