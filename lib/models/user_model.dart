class UserModel {
  final String? uid;
  final String? name;
  final String? email;
  final String? status;
  final String? profilePhoto;
  final List<dynamic>? token;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.status,
    this.profilePhoto,
    this.token,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['UserId'],
      name: map['Name'],
      email: map['E-Mail'],
      status: map['Status'],
      profilePhoto: map['PhotoUrl'],
      token: map['tokens'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'UserId': uid,
      'Name': name,
      'E-Mail': email,
      'Status': status,
      'PhotoUrl': profilePhoto,
      'tokens': token,
    };
  }
}
