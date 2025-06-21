class Chat {
  final String id;
  final String name;
  final int timestamp; // Para ordenar por último mensaje

  Chat({
    required this.id,
    required this.name,
    required this.timestamp,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      name: map['name'],
      timestamp: map['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timestamp': timestamp,
    };
  }
}