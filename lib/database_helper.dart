// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, constant_identifier_names, use_key_in_widget_constructors, unused_local_variable, avoid_print, use_build_context_synchronously, unused_import, unused_element, library_private_types_in_public_api, unnecessary_new

import 'package:qrcheck/hesap.dart';
import 'package:qrcheck/student.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'history.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'lesson_info';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY,
            lesson_code TEXT,
            lesson_date TEXT,
            lesson_id TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertLesson(
      String lessonCode, DateTime dateTime, String lessonId) async {
    Database db = await database;

    List<Map<String, dynamic>> existingLessons = await db.query(
      tableName,
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );

    String formattedDate =
        "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
    String formattedTime =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    String tarih = "$formattedDate $formattedTime";

    if (existingLessons.isEmpty) {
      Map<String, dynamic> lessonMap = {
        'lesson_code': lessonCode,
        'lesson_date': tarih,
        'lesson_id': lessonId,
      };
      await db.insert(tableName, lessonMap);
    }
  }

  Future<void> deleteAllLessons() async {
    Database db = await database;
    await db.delete(tableName);
  }

  Future<List<Map<String, dynamic>>> getAllLessons() async {
    Database db = await database;
    return await db.query(tableName);
  }
}
