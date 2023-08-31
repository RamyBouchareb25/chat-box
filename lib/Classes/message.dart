class MessageData {
  String? id;
  final String? messageId;
  final String? message;
  final String? senderId;
  final String? receiverId;
  final String? timestamp;
  final String? type;
  final bool? isRead;

  MessageData({
    this.id,
    this.messageId,
    this.message,
    this.senderId,
    this.receiverId,
    this.timestamp,
    this.type,
    this.isRead,
  });
  factory MessageData.fromMap(Map<String, dynamic> data) {
    return MessageData(
      id: data['id'],
      messageId: data['messageId'],
      message: data['message'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      timestamp: data['timestamp'],
      type: data['type'],
      isRead: data['isRead'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'messageId': messageId,
      'message': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'type': type,
      'isRead': isRead,
    };
  }

  @override
  String toString() {
    return 'MessageData(id: $id, messageID: $messageId, message: $message, senderId: $senderId, receiverId: $receiverId, timestamp: $timestamp, type: $type, isRead: $isRead)';
  }
}
