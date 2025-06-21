import 'package:flutter/material.dart';
import 'package:free_mess/models/group.dart';
import 'package:free_mess/database/database_helper.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';
import 'search_contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Chat> chats = [];
  String userName = "Tú";
  String? userPhotoUrl; // Puedes asignar una URL si tienes foto
  bool _isSearching = false;
  String _searchText = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  void loadChats() async {
    final dbHelper = DatabaseHelper();
    chats = await dbHelper.getAllChats();
    // Ordena los chats para que el más reciente esté primero
    //chats.sort((a, b) => b.id.compareTo(a.id));// Si usas timestamp en el id
    chats.sort((a, b) => b.timestamp.compareTo(a.timestamp)); 
    setState(() {});
  }

  void createChat(String name) async {
    final dbHelper = DatabaseHelper();
    final chat = Chat(
      id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await dbHelper.insertChat(chat);
    await dbHelper.addParticipantToChat(chat.id, 'current_user');
    loadChats();
  }

  void createGroup(String name, List<String> participants) async {
    final dbHelper = DatabaseHelper();
    final chat = Chat(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await dbHelper.insertChat(chat);
    await dbHelper.addParticipantToChat(chat.id, 'current_user');
    for (var p in participants) {
      await dbHelper.addParticipantToChat(chat.id, p);
    }
    loadChats();
  }

  void startConversation(String contact) async {
    final dbHelper = DatabaseHelper();
    // Buscar si ya existe un chat individual con ese contacto
    final existingChats = chats.where((chat) =>
        !chat.id.startsWith('group_') &&
        (chat.name == contact || chat.name == userName));
    if (existingChats.isNotEmpty) {
      // Ya existe, navega a ese chat
      final chat = existingChats.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(chatId: chat.id, chatName: chat.name),
        ),
      );
    } else {
      // No existe, crea uno nuevo y navega
      final chat = Chat(
        id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
        name: contact,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await dbHelper.insertChat(chat);
      await dbHelper.addParticipantToChat(chat.id, 'current_user');
      await dbHelper.addParticipantToChat(chat.id, contact);
      loadChats();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(chatId: chat.id, chatName: chat.name),
        ),
      );
    }
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
                  Navigator.pop(context); // Cierra el modal de opciones
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchContactsScreen(
                        onSelect: (contact) async {
                          final dbHelper = DatabaseHelper();
                          final existingChats = chats.where((chat) =>
                            !chat.id.startsWith('group_') &&
                            (chat.name == contact || chat.name == userName)
                          );
                          Navigator.pop(context); // Cierra SearchContactsScreen
                          if (existingChats.isNotEmpty) {
                            final chat = existingChats.first;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(chatId: chat.id, chatName: chat.name),
                              ),
                            );
                          } else {
                            final chat = Chat(
                              id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
                              name: contact,
                              timestamp: DateTime.now().millisecondsSinceEpoch,
                            );
                            await dbHelper.insertChat(chat);
                            await dbHelper.addParticipantToChat(chat.id, 'current_user');
                            await dbHelper.addParticipantToChat(chat.id, contact);
                            loadChats();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(chatId: chat.id, chatName: chat.name),
                              ),
                            );
                          }
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

  void _showCustomSnackBar(String message, {IconData icon = Icons.info_outline}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: const Color(0xFF229ED9)),
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

  void _showChatOptions(Chat chat) {
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
                leading: const Icon(Icons.push_pin, color: Color(0xFF229ED9)),
                title: const Text('Fijar'),
                onTap: () {
                  Navigator.pop(context);
                  _showCustomSnackBar('Conversación fijada', icon: Icons.push_pin);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text('Bloquear'),
                onTap: () {
                  Navigator.pop(context);
                  _showCustomSnackBar('Conversación bloqueada', icon: Icons.block);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar'),
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteChat(chat);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteChat(Chat chat) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteChat(chat.id);
    loadChats();
    _showCustomSnackBar('Conversación eliminada', icon: Icons.delete);
  }

  Widget _buildChatTile(Chat chat) {
    // Simulación de último mensaje y hora
    String lastMessage = "Último mensaje...";
    String time = "12:34";
    int unreadCount = 0; // Puedes cambiarlo según tu lógica

    return GestureDetector(
      onLongPress: () => _showChatOptions(chat),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF229ED9),
            child: Text(
              chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          title: Text(
            chat.name,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF222B45),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF7B8D93),
              fontSize: 15,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: unreadCount > 0 ? const Color(0xFF229ED9) : Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF229ED9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(chatId: chat.id, chatName: chat.name),
            ),
          ),
        ),
      ),
    );
  }

  // The _buildContactTile method has been removed because HomeScreen does not have an onSelect property or method.

  @override
  Widget build(BuildContext context) {
    final filteredChats = _searchText.isEmpty
        ? chats
        : chats.where((chat) => chat.name.toLowerCase().contains(_searchText.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: userPhotoUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(userPhotoUrl!),
                  radius: 20,
                )
              : CircleAvatar(
                  backgroundColor: const Color(0xFF229ED9),
                  radius: 20,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar conversación...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: Color(0xFF222B45),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              )
            : const Text(
                'Free Mess',
                style: TextStyle(
                  color: Color(0xFF222B45),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF229ED9)),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchText = '';
                  _searchController.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF229ED9)),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF229ED9)),
            onPressed: () {
              // Menú de opciones
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0xFF229ED9)),
      ),
      body: filteredChats.isEmpty
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                return _buildChatTile(chat);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF229ED9),
        elevation: 4,
        onPressed: showAddOptions,
        child: const Icon(Icons.edit, color: Colors.white, size: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}