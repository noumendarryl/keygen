import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:keygen/security/password_encryption.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseConnection {
  static const _databaseName = 'keygen.db';
  static const _databaseVersion = 1;

  static const table = 'accounts';
  static const columnId = 'id';
  static const columnSite = 'site';
  static const columnUsername = 'username';
  static const columnPassword = 'password';
  static const columnCreatedAt = 'created_at';

  DatabaseConnection._privateConstructor();
  static final DatabaseConnection instance =
      DatabaseConnection._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    const String directory = '/var/keygen/';
    const path = '$directory/$_databaseName';
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnSite TEXT,
        $columnUsername TEXT,
        $columnPassword TEXT NOT NULL UNIQUE,
        $columnCreatedAt INTEGER NOT NULL
      )
    ''');
  }

  Future<int?> insert(BuildContext context, Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      return await db.insert(table, row);
    } catch(e) {
      AwesomeDialog(
        context: context,
        width: 500.0,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: 'Oops...',
        titleTextStyle: const TextStyle(
          fontSize: 23.0,
        ),
        desc:
        'Cannot save the same password twice because it has to be unique',
        descTextStyle: const TextStyle(
          fontSize: 18.0,
        ),
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
        buttonsTextStyle: const TextStyle(
          fontSize: 19.0,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ).show();
    }
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> rows = await db.query(table);
    final results = rows.map((row) {
      final password = PasswordEncryption.decryptPassword(
          row[DatabaseConnection.columnPassword]);
      final createdAt = DateTime.fromMillisecondsSinceEpoch(
          row[DatabaseConnection.columnCreatedAt]);
      return {
        ...row,
        columnPassword: password,
        columnCreatedAt: createdAt,
      };
    }).toList();
    return results;
  }

  Future<int> update(int id, String site, String username, String password,
      int createdAt) async {
    final db = await instance.database;
    Map<String, dynamic> row = {
      columnSite: site,
      columnUsername: username,
      columnPassword: PasswordEncryption.encryptPassword(password),
      columnCreatedAt: createdAt,
    };
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updatePassword(int id, String password, int createdAt) async {
    final db = await instance.database;
    Map<String, dynamic> row = {
      columnPassword: PasswordEncryption.encryptPassword(password),
      columnCreatedAt: createdAt,
    };
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> deleteAllRows() async {
    final db = await database;
    await db.delete(table);
  }
}
