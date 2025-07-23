import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kanso/models/event.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'kanso.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE events (
            id TEXT PRIMARY KEY,
            title TEXT,
            dateTime TEXT,
            endTime TEXT,
            notes TEXT,
            isCompleted INTEGER,
            taskType TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertEvent(Event event) async {
    final dbClient = await db;
    return await dbClient.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateEvent(Event event) async {
    final dbClient = await db;
    return await dbClient.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(String id) async {
    final dbClient = await db;
    return await dbClient.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Event>> getEvents() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('events');
    return maps.map((map) => Event.fromMap(map)).toList();
  }

  Future<void> close() async {
    final dbClient = await db;
    await dbClient.close();
  }
}
