import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_async/sqlite3_async.dart';

//import 'package:sqlite3/sqlite3.dart' as sqlite;

class DatabaseHandler {
  late AsyncDatabase _db;
  late String _dbPath;

  DatabaseHandler() {
    openDatabase();
  }

  Future<void> openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    _dbPath = join(directory.path, "Linear_pos_destop.db");
    _db = await AsyncDatabase.open(_dbPath);
  }

  Future<void> createTable() async {
    await _db.execute("CREATE TABLE IF NOT EXISTS printter_sticker ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "form TEXT NOT NULL)");
  }

/////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  Future<void> insert_printter(int id, String name) async {
    await _db.execute('''
      INSERT OR REPLACE INTO printter_select (id, name) 
      VALUES (?, ?)
    ''', [id, name]); // Replace the existing record or insert a new one

    print('Printer name inserted or updated');
  }

  Future<List<Map<String, dynamic>>> get_printer() async {
    final List<Map<String, dynamic>> result = await _db.select("SELECT * FROM printter_select");
    return result;
  }

/////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////
}
