class Message {
  final String chatId;
  final String senderId;
  final String text;
  final int timestamp;
  final String? status;

    Message({
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'chat_id': chatId,
      'sender_id': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      chatId: map['chat_id'],
      senderId: map['sender_id'],
      text: map['text'],
      timestamp: map['timestamp'],
      status: map['status'],
    );
  }
}