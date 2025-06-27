import 'package:free_mess/database/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/message.dart';
import '../models/group.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  DatabaseHelper._internal();

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DB_NAME);

    return await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute(Tables.users);
    await db.execute(Tables.chats);
    await db.execute(Tables.messages);
    await db.execute(Tables.chatParticipants);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE chats ADD COLUMN lastMessageTime INTEGER");
    }
  }

  // CRUD Usuarios
  Future<void> insertUser(AppUser user) async {
    final db = await this.db;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? maps.first : null;
  }

  // CRUD Chats
  Future<void> insertChat(Chat chat) async {
    final db = await this.db;
    await db.insert('chats', chat.toMap());
  }

  Future<List<Chat>> getAllChats() async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query('chats');
    return maps.map((map) => Chat.fromMap(map)).toList();
  }

  // CRUD Mensajes
  Future<void> addMessage(Message message) async {
    final db = await this.db;
    await db.insert('messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Message>> getMessagesByChat(String chatId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
    return maps.map((map) => Message.fromMap(map)).toList();
  }

  // Eliminar mensaje por id
  Future<void> deleteMessage(int id) async {
    final db = await this.db;
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Participantes
  Future<void> addParticipantToChat(String chatId, String userId) async {
    final db = await this.db;
    await db.insert('chat_participants', {'chat_id': chatId, 'user_id': userId});
  }

  Future<List<AppUser>> getParticipantsByChat(String chatId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> participantMaps = await db.query(
      'chat_participants',
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
    if (participantMaps.isEmpty) return [];

    // Obtener los IDs de usuario
    final userIds = participantMaps.map((e) => e['user_id'] as String).toList();

    // Buscar los usuarios en la tabla users
    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where: 'id IN (${List.filled(userIds.length, '?').join(',')})',
      whereArgs: userIds,
    );
    return userMaps.map((map) => AppUser.fromMap(map)).toList();
  }

  // Eliminar chat por id
  Future<void> deleteChat(String chatId) async {
    final db = await this.db;
    await db.delete('chats', where: 'id = ?', whereArgs: [chatId]);
    // Opcional: elimina también los mensajes y participantes relacionados
    await db.delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);
    await db.delete('chat_participants', where: 'chat_id = ?', whereArgs: [chatId]);
  }

  Future<void> updateChatTimestamp(String chatId, int timestamp) async {
    final db = await this.db;
    await db.update(
      'chats',
      {'timestamp': timestamp},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  Future<void> insertCurrentUserIfNotExists() async {
    final db = await this.db;
    final result = await db.query('users', where: 'id = ?', whereArgs: ['current_user']);
    if (result.isEmpty) {
      await db.insert('users', {
        'id': 'current_user',
        'name': 'Tú',
        // agrega otros campos requeridos si los tienes
      });
      print("Usuario current_user creado");
    }
  }

  Future<Message?> getLastMessageForChat(String chatId) async {
    final db = await this.db;
    final result = await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Message.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertUserByFields({required String id, required String name, required String phone}) async {
    final db = await this.db;
    await db.insert(
      'users',
      {
        'id': id,
        'name': name,
        'phone': phone,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getChatWithUser(String userName) async {
    final db = await this.db;
    final result = await db.query('chats', where: 'name = ?', whereArgs: [userName]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<String> createChatWithUser(String userName, String phone) async {
    final db = await this.db;
    final id = DateTime.now().millisecondsSinceEpoch.toString() + "_" + (DateTime.now().microsecondsSinceEpoch % 100000).toString(); // Genera un id único simple
    await db.insert('chats', {
      'id': id,
      'name': userName,
      'lastMessage': '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    // También puedes agregar el usuario a la tabla de participantes si tienes una
    return id;
  }

  Future<void> setChatPinned(String chatId, bool pinned) async {
    final db = await this.db;
    await db.update(
      'chats',
      {'isPinned': pinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }
}