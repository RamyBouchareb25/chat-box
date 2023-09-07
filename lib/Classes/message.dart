enum MessageType { Text, Image, Video, Audio, File, Location, Sticker }

class MessageData {
  String? id;
  final String? messageId;
  final String? message;
  final String? senderId;
  final String? receiverId;
  final String? timestamp;
  final MessageType? type;
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
    MessageType getMessageType(String type) {
      switch (type) {
        case 'MessageType.Text':
          return MessageType.Text;
        case 'MessageType.Image':
          return MessageType.Image;
        case 'MessageType.Video':
          return MessageType.Video;
        case 'MessageType.Audio':
          return MessageType.Audio;
        case 'MessageType.File':
          return MessageType.File;
        case 'MessageType.Location':
          return MessageType.Location;
        case 'MessageType.Sticker':
          return MessageType.Sticker;
        default:
          return MessageType.Text;
      }
    }

    return MessageData(
      id: data['id'],
      messageId: data['messageId'],
      message: data['message'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      timestamp: data['timestamp'],
      type: getMessageType(data['type']),
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
      'type': type.toString(),
      'isRead': isRead,
    };
  }

  @override
  String toString() {
    return 'MessageData(id: $id, messageID: $messageId, message: $message, senderId: $senderId, receiverId: $receiverId, timestamp: $timestamp, type: $type, isRead: $isRead)';
  }
}
