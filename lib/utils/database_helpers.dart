import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'organeasy.db';
  static const _databaseVersion = 3; // Atualizado para versão 3

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 🔥 Criação das tabelas
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        room TEXT NOT NULL,
        memberId INTEGER NOT NULL,
        memberName TEXT NOT NULL,
        status TEXT NOT NULL,
        color INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE members (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  initial TEXT NOT NULL,
  color INTEGER NOT NULL,
  assigned_tasks INTEGER DEFAULT 0,
  completion REAL DEFAULT 0.0
)

    ''');

    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  Future<bool> checkColumnExists(Database db, String tableName, String columnName) async {
  final result = await db.rawQuery('PRAGMA table_info($tableName)');
  return result.any((row) => row['name'] == columnName);
}


  /// 🔄 Atualização da estrutura do banco
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN date TEXT');
      await db.rawUpdate('UPDATE tasks SET date = ? WHERE date IS NULL', [
        DateTime.now().toIso8601String(),
      ]);
    }

    if (oldVersion < 3) {
  await db.execute('ALTER TABLE tasks ADD COLUMN memberId INTEGER DEFAULT 0');
  await db.execute('ALTER TABLE tasks ADD COLUMN memberName TEXT DEFAULT ""');

  if (!(await checkColumnExists(db, 'members', 'assigned_tasks'))) {
    await db.execute('ALTER TABLE members ADD COLUMN assigned_tasks INTEGER DEFAULT 0');
  }

  if (!(await checkColumnExists(db, 'members', 'completion'))) {
    await db.execute('ALTER TABLE members ADD COLUMN completion REAL DEFAULT 0.0');
  }
}

  }
}
