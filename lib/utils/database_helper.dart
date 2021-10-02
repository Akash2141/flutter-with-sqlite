import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test_project/model/user.dart';

class DatabaseHelper{
  static final DatabaseHelper _databaseHelper=DatabaseHelper._createInstance();
  DatabaseHelper._createInstance();
  factory DatabaseHelper(){
    return _databaseHelper;
  }

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'demo.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,age INTEGER NOT NULL, country TEXT NOT NULL, email TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertUser(User user) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('users', user.toMap());
    return result;
  }

  Future<int> updateUser(User user) async{
    int result= 0;
    final Database db=await initializeDB();
    result=await db.update(
      'users',
      user.toMap(),
      where: "id = ?",
      whereArgs: [user.id],
    );
    return result;
  }

  Future<List<User>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('users');
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await initializeDB();
    await db.delete(
      'users',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> truncateDB() async {
    final db = await initializeDB();
    await db.execute("delete from users");
  }

}
