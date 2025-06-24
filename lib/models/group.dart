class Chat {
  final String id;
  final String name;
  final int timestamp;
  String? lastMessage;
  int? lastMessageTime;
  bool isPinned; // <-- agrega esto

  Chat({
    required this.id,
    required this.name,
    required this.timestamp,
    this.lastMessage,
    this.lastMessageTime,
    this.isPinned = false, // <-- valor por defecto
  });

  // Asegúrate de incluir isPinned en fromMap y toMap
  factory Chat.fromMap(Map<String, dynamic> map) => Chat(
        id: map['id'],
        name: map['name'],
        timestamp: map['timestamp'] is int
            ? map['timestamp']
            : int.tryParse(map['timestamp']?.toString() ?? '0') ?? 0,
        lastMessage: map['lastMessage'],
        lastMessageTime: map['lastMessageTime'] is int
            ? map['lastMessageTime']
            : int.tryParse(map['lastMessageTime']?.toString() ?? '0'),
        isPinned: map['isPinned'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'timestamp': timestamp,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        'isPinned': isPinned ? 1 : 0,
      };
}