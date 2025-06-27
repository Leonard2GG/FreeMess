class Tables {
  static const String users = '''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      name TEXT,
      phone TEXT
    )
  ''';

  static const String messages = '''
    CREATE TABLE messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      chat_id TEXT NOT NULL,
      sender_id TEXT NOT NULL,
      text TEXT NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''';

  static const String chats = '''
    CREATE TABLE chats (
      id TEXT PRIMARY KEY,
      name TEXT,
      lastMessage TEXT,
      lastMessageTime INTEGER,
      timestamp INTEGER,
      isPinned INTEGER DEFAULT 0
    )
  ''';

  static const String chatParticipants = '''
    CREATE TABLE chat_participants (
      chat_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      FOREIGN KEY(chat_id) REFERENCES chats(id),
      FOREIGN KEY(user_id) REFERENCES users(id),
      PRIMARY KEY(chat_id, user_id)
    )
  ''';
}