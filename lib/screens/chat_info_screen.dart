import 'package:flutter/material.dart';
import 'package:free_mess/database/database_helper.dart';
import 'package:free_mess/screens/chat_screen.dart';

class ChatInfoScreen extends StatelessWidget {
  final String chatName;
  final String? photoUrl;
  final int membersCount;
  final bool isGroup;
  final List<String> memberNames;
  final List<String>? memberPhones;

  const ChatInfoScreen({
    super.key,
    required this.chatName,
    this.photoUrl,
    required this.membersCount,
    required this.isGroup,
    this.memberNames = const [],
    this.memberPhones,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: Text(
          isGroup ? 'Información del grupo' : 'Información del contacto',
          style: const TextStyle(
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
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFF229ED9),
                child: Text(
                  chatName.isNotEmpty ? chatName[0].toUpperCase() : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                chatName,
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFF222B45),
                  fontWeight: FontWeight.bold,
                ),
              ),
              // SOLO para contacto individual: muestra el número debajo del nombre
              if (!isGroup && memberPhones != null && memberPhones!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Text(
                    memberPhones![0],
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF229ED9),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              // SOLO para grupo: muestra la lista de integrantes con número al lado
              if (isGroup)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Integrantes ($membersCount)',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7B8D93),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: memberNames.length,
                      itemBuilder: (context, index) {
                        final name = memberNames[index];
                        final phone = '50306119';
                        return Card(
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
                                name.isNotEmpty ? name[0].toUpperCase() : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF222B45),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (phone.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      phone.startsWith('+53') ? phone : '+53 $phone',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF229ED9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  backgroundColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 48,
                                          backgroundColor: const Color(0xFF229ED9),
                                          child: Text(
                                            name.isNotEmpty ? name[0].toUpperCase() : '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Color(0xFF222B45),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          phone.startsWith('+53') ? phone : '+53 $phone',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF229ED9),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF229ED9),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  elevation: 0,
                                                ),
                                                onPressed: () async {
                                                  Navigator.pop(context); // Cierra el diálogo

                                                  final dbHelper = DatabaseHelper();
                                                  final existingChat = await dbHelper.getChatWithUser(name);

                                                  String chatId;
                                                  if (existingChat != null) {
                                                    chatId = existingChat['id'];
                                                  } else {
                                                    chatId = await dbHelper.createChatWithUser(name, phone);
                                                  }

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => ChatScreen(
                                                        chatId: chatId,
                                                        chatName: name,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'Mensaje',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
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
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}