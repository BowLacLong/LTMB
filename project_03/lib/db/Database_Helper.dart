import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/User.dart';
import '../models/Task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'task_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT,
        password TEXT,
        email TEXT,
        avatar TEXT,
        createdAt TEXT,
        lastActive TEXT,
        role TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        status TEXT,
        priority INTEGER,
        dueDate TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        assignedTo TEXT,
        createdBy TEXT,
        category TEXT,
        attachments TEXT,
        completed INTEGER
      )
    ''');
  }

  //User

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final res = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final res = await db.query('users');
    return res.map((e) => User.fromMap(e)).toList();
  }

  //Task

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasksForUser(String userId, {bool isAdmin = false}) async {
    final db = await database;
    final res = isAdmin
        ? await db.query('tasks')
        : await db.query('tasks', where: 'assignedTo = ?', whereArgs: [userId]);

    return res.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> searchTasks(String keyword, String userId, {bool isAdmin = false}) async {
    final db = await database;
    final res = await db.query(
      'tasks',
      where: isAdmin
          ? 'title LIKE ? OR description LIKE ?'
          : '(title LIKE ? OR description LIKE ?) AND assignedTo = ?',
      whereArgs: isAdmin
          ? ['%$keyword%', '%$keyword%']
          : ['%$keyword%', '%$keyword%', userId],
    );
    return res.map((e) => Task.fromMap(e)).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<Task?> getTaskById(String id) async {
    final db = await database;
    final res = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return Task.fromMap(res.first);
    return null;
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<List<Task>> getTasksByUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'assignedTo = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

}
