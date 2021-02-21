import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_stream/utils/model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.createInstance();
  static Database _database;
  DatabaseHelper.createInstance();

  factory DatabaseHelper() => _instance;

  initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'sqflite_stream.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE members('
          ' id INTEGER PRIMARY KEY, name TEXT, age INTEGER '
          ')',
        );
      },
    );
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return _database;
  }

  insertMember(Member member) async {
    final Database db = await database;

    db.insert(
      'members',
      member.toMap(),
    );
  }

  Future<List<Member>> members() async {
    final Database db = await database;

    var mapList = await db.query('members');

    return List.generate(
        mapList.length, (index) => Member.fromMap(mapList[index]));
  }

  updateMember(Member member) async {
    final Database db = await database;

    db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  deleteMember(Member member) async {
    final Database db = await database;

    db.delete(
      'members',
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> getCount() async {
    final Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM members');
    int count = Sqflite.firstIntValue(x);

    return count;
  }
}
