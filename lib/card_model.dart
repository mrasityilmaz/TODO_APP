import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/db/db_model.dart';

class CardModel {
  int? id;
  String? title;
  String? content;
  String? url;

  CardModel({this.id, this.title, this.content, this.url});

  CardModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['url'] = url;
    return data;
  }
}

class CardNtfr extends ChangeNotifier {
  List<CardModel> cards = [];

  addCard(CardModel? card, Iterable<CardModel>? getcards) {
    cards = [];
    if (card != null) {
      cards.add(card);
    } else if (getcards != null) {
      cards.addAll(getcards);
    }

    notifyListeners();
  }

  deleteCard(int index, DatabaseControl db) {
    db.deleteCard(index, db.database!);

    notifyListeners();
  }

  refreshCards() {
    notifyListeners();
  }
}
