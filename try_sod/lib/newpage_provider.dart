import 'package:flutter/material.dart';
import 'db_helper.dart';

class ValueItem {
  final int id;
  final String value;
  ValueItem({required this.id, required this.value});
}

class NewPageProvider extends ChangeNotifier {
  final List<ValueItem> _items = [];
  static final DBHelper dbHelper = DBHelper();

  List<ValueItem> get items => _items;

  Future<void> initDb() async {
    await dbHelper.openDatabase();
    await loadValues();
  }

  Future<void> addValue(String newValue) async {
    final id = await dbHelper.insertValue(newValue);
    _items.add(ValueItem(id: id, value: newValue));
    notifyListeners();
  }

  Future<void> loadValues() async {
    _items.clear();
    final rows = await dbHelper.getAllRows();
    _items.addAll(rows.map((row) =>
        ValueItem(id: row['id'] as int, value: row['value'] as String)));
    notifyListeners();
  }

  Future<void> updateValue(int id, String newValue) async {
    await dbHelper.updateValue(id, newValue);
    final idx = _items.indexWhere((item) => item.id == id);
    if (idx != -1) {
      _items[idx] = ValueItem(id: id, value: newValue);
      notifyListeners();
    }
  }

  Future<void> deleteValue(int id) async {
    await dbHelper.deleteValue(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
