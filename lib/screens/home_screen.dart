import 'package:flutter/material.dart';
import 'package:free_mess/models/group.dart';
import 'package:free_mess/database/database_helper.dart';
import 'chat_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chats.isEmpty
          ? const Center(child: Text('No hay chats aún'))
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.group, color: Colors.white),
                  ),
                  title: Text(chat.name),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatId: chat.id, chatName: chat.name),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text('Nuevo Grupo'),
                content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Nombre del grupo')),
                actions: [
                  TextButton(onPressed: Navigator.of(context).pop, child: const Text('Cancelar')),
                  TextButton(
                    onPressed: () {
                      createChat(controller.text);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Crear'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}