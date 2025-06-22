import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_mess/database/database_helper.dart';
import 'package:free_mess/models/user.dart';

// Make sure the User class is defined in models/user.dart as:
// class User {
//   final String name;
//   final String phone;
//   User({required this.name, required this.phone});
// }

class ProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String? photoUrl;

  const ProfileScreen({
    Key? key,
    required this.initialName,
    required this.initialPhone,
    this.photoUrl,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _saving = false;
  String userName = '';
  String userPhone = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _fetchUserData();
  }

  void _fetchUserData() async {
    final dbHelper = DatabaseHelper();
    final user = await dbHelper.getUser('current_user');
    if (user != null) {
      setState(() {
        userName = user['name'] ?? '';
        userPhone = user['phone'] ?? '';
        _nameController.text = userName;
        _phoneController.text = userPhone;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre y el teléfono no pueden estar vacíos'),
          backgroundColor: Color(0xFF229ED9),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    // Actualiza el usuario en la base de datos
    final dbHelper = DatabaseHelper();
    await dbHelper.insertUser(AppUser(id: 'current_user', name: name, phone: phone));

    setState(() => _saving = false);

    // Devuelve los datos actualizados al HomeScreen
    Navigator.pop(context, {'name': name, 'phone': phone});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Color(0xFF222B45),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF229ED9)),
        // Eliminado el icono de guardar
      ),
      backgroundColor: const Color(0xFFF4F8FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFF229ED9),
                backgroundImage: widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                    ? NetworkImage(widget.photoUrl!)
                    : null,
                child: (widget.photoUrl == null || widget.photoUrl!.isEmpty)
                    ? Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF229ED9),
        elevation: 4,
        onPressed: _saving ? null : _saveProfile,
        icon: const Icon(Icons.save, color: Colors.white),
        label: _saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Guardar',
                style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}