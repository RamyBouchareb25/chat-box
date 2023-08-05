class UserModel {
  final String? uid;
  final String? name;
  final String? email;
  final String? status;
  final String? profilePhoto;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.status,
    this.profilePhoto,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['UserId'],
      name: map['Name'],
      email: map['E-Mail'],
      status: map['Status'],
      profilePhoto: map['PhotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'UserId': uid,
      'Name': name,
      'E-Mail': email,
      'Status': status,
      'PhotoUrl': profilePhoto,
    };
  }
}
