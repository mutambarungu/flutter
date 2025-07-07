import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class DBHelper {
  static Database? _database;

  // Initialize and get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  // Insert a new user with a unique ID
  Future<int> insertUser(Map<String, dynamic> user) async {
    try {
      final db = await database; 

      if (!user.containsKey('id') || user['id'] == null || user['id'].isEmpty) {
        user['id'] = Uuid().v4();
      }

      return await db.insert('users', user);
    } catch (e) {
      print("Error inserting user: $e");
      return -1;
    }
  }

  // Initialize the database
  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE,
            password TEXT,
            first_name TEXT,
            last_name TEXT,
            created_on TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            type TEXT CHECK(type IN ('income', 'expense')),
            category TEXT,
            amount REAL NOT NULL CHECK(amount > 0),
            date TEXT NOT NULL,
            description TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      print("Querying DB for email: $email");
      print("Database returned: $users");

      if (users.isNotEmpty) return users.first;
      return null;
    } catch (e) {
      print(" Error fetching user by email: $e");
      return null;
    }
  }
}

