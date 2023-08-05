class ChatData {
  final String? id;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String? status;
  final String? uid;

  ChatData({
    this.id,
    this.name,
    this.email,
    this.photoUrl,
    this.status,
    this.uid,
  });

  factory ChatData.fromMap(Map<String, dynamic> data) {
    return ChatData(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      status: data['status'],
      uid: data['uid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'status': status,
      'uid': uid,
    };
  }
}