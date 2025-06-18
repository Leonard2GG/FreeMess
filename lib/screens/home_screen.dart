import 'package:flutter/material.dart';
import 'package:free_mess/models/group.dart';
import 'package:free_mess/database/database_helper.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';
import 'search_contacts_screen.dart';

// Estas pantallas debes crearlas según tu lógica
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Chat> chats = [];

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  void loadChats() async {
    final dbHelper = DatabaseHelper();
    chats = await dbHelper.getAllChats();
    setState(() {});
  }

  void createChat(String name) async {
    final dbHelper = DatabaseHelper();
    final chat = Chat(id: 'chat_${DateTime.now().millisecondsSinceEpoch}', name: name);
    await dbHelper.insertChat(chat);
    await dbHelper.addParticipantToChat(chat.id, 'current_user');
    loadChats();
  }

  void createGroup(String name, List<String> participants) async {
    final dbHelper = DatabaseHelper();
    final chat = Chat(id: 'group_${DateTime.now().millisecondsSinceEpoch}', name: name);
    await dbHelper.insertChat(chat);
    await dbHelper.addParticipantToChat(chat.id, 'current_user');
    for (var p in participants) {
      await dbHelper.addParticipantToChat(chat.id, p);
    }
    loadChats();
  }

  void startConversation(String contact) async {
    // Aquí puedes buscar si ya existe un chat con ese contacto, si no, lo creas
    createChat(contact);
  }

  void showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.group, color: Color(0xFF229ED9)),
                title: const Text('Crear grupo'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateGroupScreen(
                        onCreate: (name, participants) {
                          createGroup(name, participants);
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add, color: Color(0xFF229ED9)),
                title: const Text('Nueva conversación'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchContactsScreen(
                        onSelect: (contact) {
                          startConversation(contact);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Color(0xFF222B45),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF229ED9)),
      ),
      body: chats.isEmpty
          ? const Center(
              child: Text(
                'No hay chats aún',
                style: TextStyle(
                  color: Color(0xFF7B8D93),
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF229ED9),
                      child: Text(
                        chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      chat.name,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF222B45),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF229ED9), size: 18),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: chat.id, chatName: chat.name),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF229ED9),
        elevation: 3,
        onPressed: showAddOptions,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}