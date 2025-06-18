class Chat {
  final String id;
  final String name;

  Chat({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(id: map['id'], name: map['name']);
  }
}