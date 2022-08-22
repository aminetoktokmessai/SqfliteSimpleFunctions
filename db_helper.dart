import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database _db;

  final String DATABASE_NAME = "local_database.db";
  /*final String table_name = "table_name";
  final String table_id = "table_id";
  final String table_column = "table_column";*/
  
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'local_database.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    //await db.execute(
      //  'CREATE TABLE $table_name ($table_id INTEGER PRIMARY KEY, table_column INTEGER)');
  }

  Future<int> addRecordToTable(String tableName, List columnsToAdd, List valuesToAdd) async {
    var dbClient = await db;
    String columnsString = '(';
    String valuesString = 'VALUES(';
    for (int i = 0; i < columnsToAdd.length; ++i) {
      if (i == 0) {
        columnsString += columnsToAdd[i] + ',';
      } else if (i != columnsToAdd.length - 1) {
        columnsString += ' ' + columnsToAdd[i] + ',';
      } else {
        columnsString += ' ' + columnsToAdd[i] + ')';
      }
    }
    for (int j = 0; j < valuesToAdd.length; ++j) {
      if (j == 0) {
        valuesString += '?' + ',';
      } else if (j != valuesToAdd.length - 1) {
        valuesString += ' ' + '?' + ',';
      } else {
        valuesString += ' ' + '?' + ')';
      }
    }
    try {
      var p = await dbClient.rawInsert(
          'INSERT INTO $tableName'
          '$columnsString'
          '$valuesString',
          valuesToAdd);
      return p;
    } catch (e) {
      //print("Error INSERT!"+e.toString());
    }
    return null;
  }

  Future<List> getAllColumnValuesFromTable(String tableName, String columnToGet) async {
    var dbClient = await db;
    var tempList = [];
    List maps = await dbClient.query(
      '$tableName',
      columns: ['$columnToGet'],
    );
    for (var i = 0; i < maps.length; ++i) {
      tempList.add(maps[i][columnToGet]);
    }
    return tempList;
  }

  Future<List> getRowsStringsWithCondition(
      String tableName, String whereColumn, String whereValue, String columnToGet) async {
    if (whereValue != null) {
      var dbClient = await db;
      var tempList = [];
      List maps = await dbClient.query(
        '$tableName',
        where: "$whereColumn = ?",
        columns: ['$columnToGet'],
        whereArgs: [whereValue],
      );
      for (var i = 0; i < maps.length; ++i) {
        tempList.add(maps[i][columnToGet]);
      }
      return tempList;
    } else {
      return null;
    }
  }

  Future<String> getOneStringWithCondition(
      String tableName, String whereColumn, String whereValue, String columnToGet) async {
    if (whereValue != null) {
      var dbClient = await db;
      List maps;
      maps = await dbClient.query(
        '$tableName',
        where: "$whereColumn = ?",
        columns: ['$columnToGet'],
        whereArgs: [whereValue],
      ).catchError((error) => print("errrroor " + error.toString()));
      if (maps.length > 0) {
        return maps[0][columnToGet].toString();
      } else {
        return null;
      }
    } else {
      return null;
    }
  }


  Future<int> delete(String tableName, String whereColumn, String whereValue) async {
    var dbClient = await db;
    return await dbClient.delete(
      tableName,
      where: '$whereColumn = ?',
      whereArgs: [whereValue],
    );
  }

  Future<int> update(String tableName, String columnToUpdate,
      String valueToUpdate, String whereColumn, String whereValue) async {
    var dbClient = await db;
    var o = await dbClient.rawUpdate(
        'UPDATE $tableName SET $columnToUpdate = ? WHERE $whereColumn = ?',
        [valueToUpdate, whereValue]);
    return o;
  }
}
