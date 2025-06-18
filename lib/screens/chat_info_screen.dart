import 'package:flutter/material.dart';

class ChatInfoScreen extends StatelessWidget {
  final String chatName;
  final String? photoUrl;
  final int membersCount;
  final bool isGroup;
  final List<String> memberNames;

  const ChatInfoScreen({
    super.key,
    required this.chatName,
    this.photoUrl,
    required this.membersCount,
    required this.isGroup,
    this.memberNames = const [],
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
              photoUrl != null && photoUrl!.isNotEmpty
                  ? CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(photoUrl!),
                    )
                  : CircleAvatar(
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
              const SizedBox(height: 16),
              if (isGroup)
                Column(
                  children: [
                    Text(
                      'Integrantes: $membersCount',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7B8D93),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: memberNames.length,
                      itemBuilder: (context, index) {
                        final name = memberNames[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF229ED9),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Color(0xFF222B45),
                              ),
                            ),
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