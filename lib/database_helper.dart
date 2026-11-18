import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dawai_pro.db');
    return _database!;
  }

  Future _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE medications ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL, '
      'dosage TEXT NOT NULL, '
      'time TEXT NOT NULL, '
      'notes TEXT'
      ')',
    );
  }

  Future insertMedication(Map row) async {
    final db = await instance.database;
    return await db.insert('medications', row);
  }

  Future queryAllMedications() async {
    final db = await instance.database;
    return await db.query('medications');
  }

  Future deleteMedication(int id) async {
    final db = await instance.database;
    return await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }
}
