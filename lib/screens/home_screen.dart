import 'package:flutter/material.dart';
import 'package:free_mess/models/group.dart';
import 'package:free_mess/database/database_helper.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';
import 'search_contacts_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Chat> chats = [];
  String userName = "Tú";
  String? userPhotoUrl; // Puedes asignar una URL si tienes foto
  String userPhone = 'TuTeléfono'; // Variable para el teléfono del usuario
  bool _isSearching = false;
  String _searchText = '';
  TextEditingController _searchController = TextEditingController();
  Set<String> selectedChatIds = {}; // IDs de chats seleccionados
  bool isSelectionMode = false;

  @override
void initState() {
  super.initState();
  loadCurrentUser(); // <-- Agrega esto
  loadChats();       // (o tu método para cargar chats)
}


  void loadCurrentUser() async {
  final dbHelper = DatabaseHelper();
  final user = await dbHelper.getUser('current_user');
  setState(() {
    userName = user != null && user['name'] != null && user['name'].toString().isNotEmpty
        ? user['name']
        : "Tú";
    userPhone = user != null && user['phone'] != null && user['phone'].toString().isNotEmpty
        ? user['phone']
        : "TuTeléfono";
  });
}

  void loadChats() async {
    final dbHelper = DatabaseHelper();
    chats = await dbHelper.getAllChats();

    for (var chat in chats) {
      final lastMsg = await dbHelper.getLastMessageForChat(chat.id);
      print('Chat: ${chat.name}, Último mensaje: ${lastMsg?.text}');
      chat.lastMessage = lastMsg?.text ?? '';
      chat.lastMessageTime = lastMsg?.timestamp; // <-- Aquí
    }

    // Ordena los chats por la hora del último mensaje (o por timestamp si no hay mensajes)
    chats.sort((a, b) {
      // Primero, los fijados arriba
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // Si ambos son fijados o ambos no, ordena por último mensaje/creación
      return (b.lastMessageTime ?? b.timestamp).compareTo(a.lastMessageTime ?? a.timestamp);
    });
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
      await dbHelper.insertUserByFields(
        id: p,
        name: p,
        phone: '', // o un número real si lo tienes
      );
      await dbHelper.addParticipantToChat(chat.id, p);
    }
    loadChats();
  }

  void startConversation(String contact) async {
    final dbHelper = DatabaseHelper();
    // Inserta el usuario si no existe
    await dbHelper.insertUserByFields(
      id: contact,
      name: contact,
      phone: '', // o un número real si lo tienes
    );
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
                          // No hagas Navigator.pop(context) aquí
                          final existingChats = chats.where((chat) =>
                            !chat.id.startsWith('group_') &&
                            (chat.name == contact || chat.name == userName)
                          );
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
                leading: Icon(Icons.push_pin, color: Color(0xFF229ED9)),
                title: Text(chat.isPinned ? 'Desfijar' : 'Fijar'),
                onTap: () async {
                  Navigator.pop(context);
                  final dbHelper = DatabaseHelper();
                  await dbHelper.setChatPinned(chat.id, !chat.isPinned);
                  loadChats();
                  _showCustomSnackBar(
                    chat.isPinned ? 'Conversación desfijada' : 'Conversación fijada',
                    icon: Icons.push_pin,
                  );
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
  }

  Widget _buildChatTile(Chat chat) {
    bool selected = selectedChatIds.contains(chat.id);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          isSelectionMode = true;
          selectedChatIds.add(chat.id);
        });
      },
      onTap: () {
        if (isSelectionMode) {
          setState(() {
            if (selected) {
              selectedChatIds.remove(chat.id);
              if (selectedChatIds.isEmpty) isSelectionMode = false;
            } else {
              selectedChatIds.add(chat.id);
            }
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(chatId: chat.id, chatName: chat.name),
            ),
          ).then((_) => loadChats());
        }
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
                  chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '',
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
                  left: 0,
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
              if (chat.isPinned)
                Positioned(
                  bottom: 0,
                  right: 0, // <-- Cambiado a right
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.push_pin, color: Colors.grey, size: 18),
                  ),
                ),
            ],
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
            chat.lastMessage?.isNotEmpty == true ? chat.lastMessage! : "Sin mensajes aún",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF7B8D93),
              fontSize: 15,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (chat.lastMessageTime != null)
                Text(
                  _formatTime(chat.lastMessageTime!),
                  style: const TextStyle(
                    color: Color(0xFF7B8D93),
                    fontSize: 13,
                  ),
                ),
              // Puedes agregar aquí un badge de mensajes no leídos si lo deseas
            ],
          ),
        ),
        ),
      );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      // Show hour and minute if today
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      // Show day/month
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
    }
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
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF229ED9)),
                onPressed: () {
                  setState(() {
                    isSelectionMode = false;
                    selectedChatIds.clear();
                  });
                },
              )
            : // ...tu avatar como antes...
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          initialName: userName,
                          initialPhone: 'TuTeléfono', // Aquí pon el número real si lo tienes
                          photoUrl: userPhotoUrl,
                        ),
                      ),
                    );
                    if (result != null && result is Map) {
                      setState(() {
                        userName = result['name'] ?? userName;
                        userPhone = result['phone'] ?? userPhone; // <-- agrega esto
                      });
                    }
                  },
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
              ),
        title: isSelectionMode
            ? Text(
                '${selectedChatIds.length} seleccionados',
                style: const TextStyle(
                  color: Color(0xFF222B45),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            : _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Buscar...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18),
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
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: Icon(
                    // Si TODOS los seleccionados están fijados, muestra el icono de "desfijar"
                    selectedChatIds.isNotEmpty && selectedChatIds.every((id) => chats.firstWhere((c) => c.id == id).isPinned)
                      ? Icons.push_pin_outlined // Puedes usar otro icono si prefieres
                      : Icons.push_pin,
                    color: Color(0xFF229ED9),
                  ),
                  tooltip: selectedChatIds.isNotEmpty && selectedChatIds.every((id) => chats.firstWhere((c) => c.id == id).isPinned)
                      ? 'Desfijar'
                      : 'Fijar',
                  onPressed: () async {
                    final dbHelper = DatabaseHelper();
                    final hasUnpinned = selectedChatIds.any((id) => !(chats.firstWhere((c) => c.id == id).isPinned));
                    if (hasUnpinned) {
                      // Fijar todos los seleccionados
                      for (var chatId in selectedChatIds) {
                        await dbHelper.setChatPinned(chatId, true);
                      }
                      _showCustomSnackBar(
                        selectedChatIds.length == 1
                            ? 'Conversación fijada'
                            : 'Conversaciones fijadas',
                        icon: Icons.push_pin,
                      );
                    } else {
                      // Todos están fijados, así que desfijar
                      for (var chatId in selectedChatIds) {
                        await dbHelper.setChatPinned(chatId, false);
                      }
                      _showCustomSnackBar(
                        selectedChatIds.length == 1
                            ? 'Conversación desfijada'
                            : 'Conversaciones desfijadas',
                        icon: Icons.push_pin_outlined, // Icono de desfijar
                      );
                    }
                    setState(() {
                      isSelectionMode = false;
                      selectedChatIds.clear();
                    });
                    loadChats();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'Eliminar chats',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF222B45),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                selectedChatIds.length == 1
                                    ? '¿Seguro que deseas eliminar esta conversación?'
                                    : '¿Seguro que deseas eliminar estas ${selectedChatIds.length} conversaciones?',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF7B8D93),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF229ED9),
                                        side: const BorderSide(color: Color(0xFF229ED9)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    if (confirm == true) {
                      for (var chatId in selectedChatIds) {
                        await _deleteChat(chats.firstWhere((c) => c.id == chatId));
                      }
                      setState(() {
                        isSelectionMode = false;
                        selectedChatIds.clear();
                      });
                      _showCustomSnackBar(
                        selectedChatIds.length == 1
                          ? 'Conversación eliminada'
                          : 'Conversaciones eliminadas',
                        icon: Icons.delete,
                      );
                    }
                  },
                ),
              ]
            : [
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
        child: const Icon(Icons.add_comment_rounded, color: Colors.white, size: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}