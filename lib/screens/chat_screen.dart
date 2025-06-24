import 'package:flutter/material.dart';
import 'package:free_mess/models/message.dart';
import 'package:free_mess/database/database_helper.dart';
import 'package:free_mess/models/user.dart';
import 'chat_info_screen.dart';
import 'package:free_mess/screens/home_screen.dart'; // importa HomeScreen


class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  const ChatScreen({Key? key, required this.chatId, required this.chatName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AppUser? currentUser;
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];
  bool _isSearching = false;
  String _searchQuery = '';
  List<Message> _filteredMessages = [];

  Set<int> selectedMessageIds = {};
  bool isSelectionMode = false;

  void _showCustomSnackBar(String message, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) Icon(icon, color: const Color(0xFF229ED9)),
            if (icon != null) const SizedBox(width: 12),
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

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
    loadMessages();
  }

  void loadCurrentUser() async {
  final dbHelper = DatabaseHelper();
  final user = await dbHelper.getUser("current_user");
  print("Usuario cargado: $user");
  if (user != null) {
    setState(() {
      currentUser = AppUser.fromMap(user);
    });
  } else {
    print("ERROR: Current user not found");
    // Puedes mostrar un mensaje de error aquí si quieres
  }
}

  void loadMessages() async {
  final dbHelper = DatabaseHelper();
  messages = await dbHelper.getMessagesByChat(widget.chatId);
  _filterMessages();
  setState(() {});
}

void _filterMessages() {
  if (_searchQuery.isEmpty) {
    _filteredMessages = messages;
  } else {
    _filteredMessages = messages
        .where((msg) => msg.text.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }
}

  void _sendMessage() async {
    print("Intentando enviar mensaje...");
    if (currentUser == null) {
      print("Usuario no cargado");
      return;
    }
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        final message = Message(
          chatId: widget.chatId,
          senderId: currentUser!.id,
          text: text,
          timestamp: timestamp,
          status: "sent",
        );
        final dbHelper = DatabaseHelper();
        print("Antes de addMessage");
        await dbHelper.addMessage(message);
        print("Después de addMessage");
        await dbHelper.updateChatTimestamp(widget.chatId, timestamp);
        print("Después de updateChatTimestamp");
        loadMessages();
        _controller.clear();
      } catch (e) {
        print("Error al enviar mensaje: $e");
      }
    } else {
      print("El texto está vacío");
    }
  }

  void _deleteMessage(Message msg) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteMessage(msg.id!);
    loadMessages();
  }

  void _showMessageOptions(Message msg) {
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
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar'),
                onTap: () async {
                  Navigator.pop(context);
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
                            const Text(
                              'Eliminar mensaje',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222B45),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '¿Seguro que deseas eliminar este mensaje?',
                              style: TextStyle(
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
                    _deleteMessage(msg);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.delete, color: Color(0xFF229ED9)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Mensaje eliminado',
                                style: TextStyle(
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
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getStatusIcon(String? status) {
    switch (status) {
      case "sent":
        return const Icon(Icons.check, size: 16, color: Colors.grey);
      case "delivered":
        return const Icon(Icons.done_all, size: 16, color: Colors.grey);
      case "read":
        return const Icon(Icons.done_all, size: 16, color: Color(0xFF229ED9));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMessage(Message msg, bool isMe) {
    bool selected = selectedMessageIds.contains(msg.id);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          isSelectionMode = true;
          selectedMessageIds.add(msg.id!);
        });
      },
      onTap: () {
        if (isSelectionMode) {
          setState(() {
            if (selected) {
              selectedMessageIds.remove(msg.id!);
              if (selectedMessageIds.isEmpty) isSelectionMode = false;
            } else {
              selectedMessageIds.add(msg.id!);
            }
          });
        }
      },
      child: Container(
        color: selected ? const Color(0xFFE3F4FB) : Colors.transparent,
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isMe ? 60 : 12,
          right: isMe ? 12 : 60,
        ),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              CircleAvatar(
                backgroundColor: const Color(0xFF229ED9),
                radius: 18,
                child: Text(
                  msg.senderId.isNotEmpty ? msg.senderId[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            if (!isMe) const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF229ED9) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: isMe ? Colors.white : const Color(0xFF222B45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(msg.timestamp),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (isMe)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: _getStatusIcon(msg.status ?? "sent"),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) const SizedBox(width: 8),
            if (isMe)
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                radius: 18,
                child: const Icon(Icons.person_outline, color: Color(0xFF229ED9), size: 18),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return "$hour:$min";
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navega al HomeScreen y elimina todas las rutas anteriores
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
        return false; // Previene el pop normal
      },
      child: Scaffold(
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
                      selectedMessageIds.clear();
                    });
                  },
                )
              : null,
          title: isSelectionMode
              ? Text(
                  '${selectedMessageIds.length} seleccionados',
                  style: const TextStyle(
                    color: Color(0xFF222B45),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : _isSearching
                  ? TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Buscar mensajes...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 18),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterMessages();
                        });
                      },
                    )
                  : GestureDetector(
                      onTap: () {
                        // Abre la info del contacto/grupo
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatInfoScreen(
                              chatName: widget.chatName,
                              membersCount: 1, // Reemplaza con el valor real si lo tienes
                              isGroup: false,  // Reemplaza con el valor real si lo tienes
                              // Pasa aquí los demás datos necesarios
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF229ED9),
                            radius: 18,
                            child: Text(
                              widget.chatName.isNotEmpty ? widget.chatName[0].toUpperCase() : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.chatName,
                            style: const TextStyle(
                              color: Color(0xFF222B45),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
          actions: isSelectionMode
              ? [
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
                                  selectedMessageIds.length == 1
                                      ? '¿Seguro que deseas eliminar este mensaje?'
                                      : '¿Seguro que deseas eliminar estos ${selectedMessageIds.length} mensajes?',
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
                        for (var msgId in selectedMessageIds) {
                          await DatabaseHelper().deleteMessage(msgId);
                        }
                        setState(() {
                          isSelectionMode = false;
                          selectedMessageIds.clear();
                        });
                        loadMessages();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.delete, color: Color(0xFF229ED9)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Mensajes eliminados',
                                    style: TextStyle(
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
                          _searchQuery = '';
                          _filterMessages();
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
                  const SizedBox(width: 16),
                ],
          iconTheme: const IconThemeData(color: Color(0xFF229ED9)),
        ),
        body: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay mensajes aún',
                        style: TextStyle(
                          color: Color(0xFF7B8D93),
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: false,
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      itemCount: _filteredMessages.length,
                      itemBuilder: (context, index) {
                        final msg = _filteredMessages[index];
                        bool isMe = msg.senderId == currentUser!.id;
                        return _buildMessage(msg, isMe);
                      },
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF229ED9)),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF229ED9)),
                        onPressed: currentUser == null ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}