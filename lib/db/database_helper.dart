import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = join(await getDatabasesPath(), 'alloy_blend.db');
    return openDatabase(dbPath, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE grades(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          standard TEXT,
          notes TEXT
        )''');
      await db.execute('''
        CREATE TABLE grade_chemistry(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          grade_id INTEGER NOT NULL,
          element TEXT NOT NULL,
          min_pct REAL,
          max_pct REAL,
          target_pct REAL,
          FOREIGN KEY(grade_id) REFERENCES grades(id) ON DELETE CASCADE
        )''');
    });
  }

  Future<List<Map<String, dynamic>>> getGrades() async {
    final db = await database;
    return db.query('grades', orderBy: 'name');
  }

  Future<int> insertGrade(Map<String, dynamic> row) async =>
      (await database).insert('grades', row);

  Future<int> updateGrade(int id, Map<String, dynamic> row) async =>
      (await database).update('grades', row, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteGrade(int id) async {
    final db = await database;
    await db.delete('grade_chemistry', where: 'grade_id = ?', whereArgs: [id]);
    return db.delete('grades', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getChemistry(int gradeId) async =>
      (await database).query('grade_chemistry',
          where: 'grade_id = ?', whereArgs: [gradeId], orderBy: 'element');

  Future<void> replaceChemistry(int gradeId, List<Map<String, dynamic>> rows) async {
    final db = await database;
    await db.delete('grade_chemistry', where: 'grade_id = ?', whereArgs: [gradeId]);
    for (var row in rows) {
      await db.insert('grade_chemistry', {...row, 'grade_id': gradeId});
    }
  }
}
