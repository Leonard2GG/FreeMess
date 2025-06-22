class AppUser {
  final String id;
  final String name;
  final String phone; // <-- Agrega esto

  AppUser({required this.id, required this.name, required this.phone}); // <-- Agrega phone

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone, // <-- Agrega phone
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '', // <-- Agrega phone
    );
  }
}