import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'contact.dart';

class DatabaseHelper {
 
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {

    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final path = join(await getDatabasesPath(), 'pocket_notes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        
        return db.execute(
          'CREATE TABLE contacts('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'name TEXT, '
          'phone_number TEXT)',
        );
      },
    );
  }

  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap());
  }


  Future<List<Contact>> getContacts() async {
    final db = await database;
    final rows = await db.query('contacts', orderBy: 'id');
    
    debugPrint('contacts table: $rows');
    return rows.map((row) => Contact.fromMap(row)).toList();
  }

  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}