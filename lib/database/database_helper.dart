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
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute(Tables.users);
    await db.execute(Tables.chats);
    await db.execute(Tables.messages);
    await db.execute(Tables.chatParticipants);
  }

  // CRUD Usuarios
  Future<void> insertUser(AppUser user) async {
    final db = await this.db;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppUser?> getUser(String id) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? AppUser.fromMap(maps.first) : null;
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

  // CRUD Participantes
  Future<void> addParticipantToChat(String chatId, String userId) async {
    final db = await this.db;
    await db.insert('chat_participants', {'chat_id': chatId, 'user_id': userId});
  }
}