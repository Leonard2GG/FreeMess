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
  late AppUser currentUser;
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
    if (user != null) {
      setState(() {
        currentUser = user;
      });
    } else {
      throw Exception("Current user not found");
    }
  }

  void loadMessages() async {
    final dbHelper = DatabaseHelper();
    messages = await dbHelper.getMessagesByChat(widget.chatId);
    setState(() {});
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final message = Message(
        chatId: widget.chatId,
        senderId: currentUser.id,
        text: text,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: "sent", // Nuevo campo para el estado
      );
      final dbHelper = DatabaseHelper();
      await dbHelper.addMessage(message);
      loadMessages();
      _controller.clear();
    }
  }

  // Devuelve el icono y color según el estado del mensaje
  Widget _getStatusIcon(String status) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundColor: const Color(0xFF229ED9),
              radius: 16,
              child: Text(
                msg.senderId.isNotEmpty ? msg.senderId[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: isMe
                      ? const EdgeInsets.only(right: 28)
                      : const EdgeInsets.only(left: 0),
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
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isMe ? Colors.white : const Color(0xFF222B45),
                    ),
                  ),
                ),
                // Estado solo para mensajes propios
                if (isMe)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _getStatusIcon(msg.status ?? "sent"),
                  ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              radius: 16,
              child: const Icon(Icons.person_outline, color: Color(0xFF229ED9), size: 18),
            ),
        ],
      ),
    );
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
            // Simulación: obtén la cantidad de integrantes y foto si tienes esa info
            int membersCount = 1; // Por defecto 1 para chat individual
            String? photoUrl;
            bool isGroup = widget.chatId.startsWith('group_');
            if (isGroup) {
              // Si tienes método para obtener miembros, úsalo aquí
              final dbHelper = DatabaseHelper();
              final members = await dbHelper.getParticipantsByChat(widget.chatId);
              membersCount = members.length;
              // Si tienes foto, asígnala a photoUrl
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatInfoScreen(
                  chatName: widget.chatName,
                  photoUrl: photoUrl,
                  membersCount: membersCount,
                  isGroup: isGroup,
                ),
              ),
            );
          },
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline, color: Color(0xFF229ED9)),
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
            child: ListView.builder(
              reverse: false,
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isMe = msg.senderId == currentUser.id;
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
                      onPressed: _sendMessage,
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