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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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
              const SizedBox(height: 28),
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
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecciona participantes',
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Lista de contactos filtrados
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  final selected = selectedContacts.contains(contact);
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF229ED9),
                        child: Text(
                          contact.isNotEmpty ? contact[0].toUpperCase() : '',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        contact,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF222B45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Checkbox(
                        value: selected,
                        activeColor: const Color(0xFF229ED9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedContacts.add(contact);
                            } else {
                              selectedContacts.remove(contact);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (selected) {
                            selectedContacts.remove(contact);
                          } else {
                            selectedContacts.add(contact);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF229ED9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty && selectedContacts.isNotEmpty) {
                      widget.onCreate(name, selectedContacts);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Crear grupo',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}