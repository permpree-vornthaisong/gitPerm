import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_async/sqlite3_async.dart';
import 'dart:io';

class DBHelper {
  late AsyncDatabase _db;
  late String _dbPath;

  DBHelper();

  Future<void> openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    _dbPath = join(directory.path, "values.db");
    _db = await AsyncDatabase.open(_dbPath);
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS values_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value TEXT
      )
    ''');
  }

  Future<int> insertValue(String value) async {
    await _db.execute(
      'INSERT INTO values_table (value) VALUES (?)',
      [value],
    );
    // ดึง id ล่าสุดที่ insert
    final result = await _db.select('SELECT last_insert_rowid() as id');
    return result.first['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getAllRows() async {
    final result = await _db.select('SELECT id, value FROM values_table');
    return result;
  }

  Future<List<String>> getAllValues() async {
    final result = await _db.select('SELECT value FROM values_table');
    return result.map((row) => row['value'] as String).toList();
  }

  Future<void> updateValue(int id, String newValue) async {
    await _db.execute(
      'UPDATE values_table SET value = ? WHERE id = ?',
      [newValue, id],
    );
  }

  Future<void> deleteValue(int id) async {
    await _db.execute(
      'DELETE FROM values_table WHERE id = ?',
      [id],
    );
  }
}
