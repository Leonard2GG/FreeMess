import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  final Function(String, List<String>) onCreate;
  const CreateGroupScreen({super.key, required this.onCreate});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final nameController = TextEditingController();
  final searchController = TextEditingController();
  final List<String> contacts = ['Ana', 'Luis', 'Pedro', 'María', 'Sofía'];
  final List<String> selectedContacts = [];
  List<String> filteredContacts = [];

  @override
  void initState() {
    super.initState();
    filteredContacts = List.from(contacts);
    searchController.addListener(_filterContacts);
  }

  void _filterContacts() {
    setState(() {
      filteredContacts = contacts
          .where((c) => c.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF229ED9)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF222B45),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF229ED9), width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _createGroup() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      _showCustomSnackBar('Por favor ingresa el nombre del grupo');
      return;
    }
    if (selectedContacts.isEmpty) {
      _showCustomSnackBar('Selecciona al menos un integrante');
      return;
    }
    widget.onCreate(name, selectedContacts);
    Navigator.pop(context);
  }

  Widget _buildContactTile(String contact) {
    final selected = selectedContacts.contains(contact);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            selectedContacts.remove(contact);
          } else {
            selectedContacts.add(contact);
          }
        });
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        color: selected ? const Color(0xFFE3F4FB) : Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF229ED9),
                child: Text(
                  contact.isNotEmpty ? contact[0].toUpperCase() : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF229ED9),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                ),
            ],
          ),
          title: Text(
            contact,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF222B45),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text(
          'Crear Grupo',
          style: TextStyle(
            color: Color(0xFF222B45),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF229ED9)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.group_add,
                  size: 48,
                  color: Color(0xFF229ED9),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del grupo',
                prefixIcon: const Icon(Icons.group_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar contacto',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 18),
            Text(
              'Selecciona participantes',
              style: TextStyle(
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredContacts.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay contactos',
                        style: TextStyle(
                          color: Color(0xFF7B8D93),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        return _buildContactTile(contact);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF229ED9),
        elevation: 4,
        onPressed: _createGroup,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          'Crear grupo',
          style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}