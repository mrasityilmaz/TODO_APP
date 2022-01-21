import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/card_model.dart';

DatabaseControl databaseControl = DatabaseControl();

class DatabaseControl {
  final String _databaseName = "tododb";
  final String _tableName = "Cards";
  final int _dbversion = 1;
  Database? database;

  Future<void> open() async {
    database = await openDatabase(
      _databaseName,
      
      version: _dbversion,
      onCreate: (db, version) async {
        _createDb(db);
      },
    );
  }

  Future<void> _createDb(Database db) => db.execute(
      "CREATE TABLE Cards (id INTEGER PRIMARY KEY,title  VARCHAR,content VARCHAR,url VARCHAR)");

  Future<int> addCard(CardModel card) async {
    var result = await database!.insert("Cards", card.toJson());
    return result;
  }

  Future<void> deleteCard(int id, Database db) async {
    await db.delete(
      'Cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> getCards(BuildContext context) async {
    List<Map<String, dynamic>> result = await database!.query(_tableName);
    Iterable<CardModel> getter = result.map((e) {
      debugPrint(e.toString());
      return CardModel.fromJson(e);
    });
    Provider.of<CardNtfr>(context, listen: false).addCard(null, getter);
  }
}
