import 'package:flutter/material.dart';

class SearchContactsScreen extends StatefulWidget {
  final Function(String) onSelect;
  const SearchContactsScreen({super.key, required this.onSelect});

  @override
  State<SearchContactsScreen> createState() => _SearchContactsScreenState();
}

class _SearchContactsScreenState extends State<SearchContactsScreen> {
  final searchController = TextEditingController();
  final List<String> contacts = ['Ana', 'Luis', 'Pedro', 'María', 'Sofía'];
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
    super.dispose();
  }

  Widget _buildContactTile(String contact) {
    return GestureDetector(
      onTap: () {
        widget.onSelect(contact); // Llama al callback para crear la conversación
        Navigator.pop(context);   // Cierra la pantalla de búsqueda
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: CircleAvatar(
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
          'Buscar Contacto',
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
                  Icons.person_search,
                  size: 48,
                  color: Color(0xFF229ED9),
                ),
              ),
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
            const SizedBox(height: 18),
            Text(
              'Contactos',
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
    );
  }
}