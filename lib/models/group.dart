class Chat {
  final String id;
  final String name;
  final int timestamp;
  String? lastMessage;
  int? lastMessageTime; // <-- Agrega esto

  Chat({
    required this.id,
    required this.name,
    required this.timestamp,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      name: map['name'],
      timestamp: map['timestamp'] is int
          ? map['timestamp']
          : int.tryParse(map['timestamp']?.toString() ?? '0') ?? 0,
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] is int
          ? map['lastMessageTime']
          : int.tryParse(map['lastMessageTime']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timestamp': timestamp,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
    };
  }
}