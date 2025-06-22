import 'package:flutter/material.dart';
import 'package:free_mess/models/message.dart';
import 'package:free_mess/database/database_helper.dart';
import 'package:free_mess/models/user.dart';
import 'chat_info_screen.dart';


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
    setState(() {});
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
                leading: const Icon(Icons.push_pin, color: Color(0xFF229ED9)),
                title: const Text('Fijar'),
                onTap: () {
                  // Lógica para fijar mensaje
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensaje fijado (demo)')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text('Bloquear'),
                onTap: () {
                  // Lógica para bloquear mensaje
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensaje bloqueado (demo)')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(msg);
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
    return GestureDetector(
      onLongPress: () => _showMessageOptions(msg),
      child: Container(
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: GestureDetector(
          onTap: () async {
            int membersCount = 1;
            String? photoUrl;
            bool isGroup = widget.chatId.startsWith('group_');
            List<String> memberNames = [];
            if (isGroup) {
              final dbHelper = DatabaseHelper();
              final members = await dbHelper.getParticipantsByChat(widget.chatId);
              membersCount = members.length;
              memberNames = members.map((u) => u.name).toList();
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatInfoScreen(
                  chatName: widget.chatName,
                  photoUrl: photoUrl,
                  membersCount: membersCount,
                  isGroup: isGroup,
                  memberNames: memberNames,
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
        actions: const [
          Icon(Icons.search, color: Color(0xFF229ED9)),
          SizedBox(width: 16),
        ],
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
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
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
    );
  }
}