import 'package:flutter/material.dart';
import 'package:free_mess/models/message.dart';
import 'package:free_mess/database/database_helper.dart';
import 'package:free_mess/models/user.dart';

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
      currentUser = user;
    } else {
      // Handle the case where user is null, e.g., show an error or navigate away
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
      );
      final dbHelper = DatabaseHelper();
      await dbHelper.addMessage(message);
      loadMessages();
      _controller.clear();
    }
  }

  Widget _buildMessage(Message msg, bool isMe) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 8),
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 14,
              child: Text('U', style: TextStyle(color: Colors.white)),
            ),
          ),
        Expanded(
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
              child: Text(
                msg.text,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.person_outline),
            SizedBox(width: 8),
            Text('Chat'),
          ],
        ),
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isMe = msg.senderId == currentUser.id;
                return _buildMessage(msg, isMe);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}