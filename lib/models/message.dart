class Message {
  final int? id;
  final String chatId;
  final String senderId;
  final String text;
  final int timestamp;
  final String? status;

  Message({
    this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'chat_id': chatId,
      'sender_id': senderId,
      'text': text,
      'timestamp': timestamp,
      'status': status,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      chatId: map['chat_id'],
      senderId: map['sender_id'],
      text: map['text'],
      timestamp: map['timestamp'],
      status: map['status'],
    );
  }
}