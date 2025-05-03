import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/task.dart';
import '../model/users.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        isAdmin INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT,
        priority INTEGER,
        dueDate TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        createdBy TEXT,
        assignedTo TEXT,
        category TEXT,
        attachments TEXT,
        completed INTEGER,
        userId INTEGER
      );
    ''');
  }

  // Thêm task mới
  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  // Cập nhật task
  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Xoá task
  Future<int> deleteTask(String id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Lấy danh sách task theo user
  Future<List<Task>> getTasks({required int userId, required bool isAdmin}) async {
    final db = await instance.database;
    final maps = await db.query(
      'tasks',
      where: isAdmin ? null : 'userId = ?',
      whereArgs: isAdmin ? null : [userId],
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Tạo user
  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  // Đăng nhập
  Future<User?> login(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Thêm hàm kiểm tra username đã tồn tại chưa
  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

// Thêm user mới sau khi kiểm tra username không trùng
  Future<int> insertUser(User user) async {
    final db = await database;

    // Kiểm tra xem username đã tồn tại chưa
    final exists = await usernameExists(user.username);
    if (exists) {
      throw Exception("Username đã tồn tại!");
    }

    // Nếu chưa tồn tại, thêm mới vào bảng users
    return await db.insert('users', user.toMap());
  }

// Lấy user theo username
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

// Lấy danh sách tất cả user thường (không phải admin)
  Future<List<User>> getNormalUsers() async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'isAdmin = ?',
      whereArgs: [0],
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

}
