import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/item_model.dart';
import 'dart:io';
import 'dart:async';
import 'repository.dart';

class NewsDbProvider implements Source, Cache {
  Database db;

  Future<List<int>> fetchTopIds() {
    return null;
  }

  NewsDbProvider() {
    init(); //init method is called when NewDbProvider class instance, if there are multiple instances, there will be multiple times init method is called, so, we put the call to this method to class constructor
  }

  void init() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path,
        'item.db'); //if u see null as comment quantity in the topIds list, change database name
    db = await openDatabase(path, version: 1,
        onCreate: (Database newDB, int version) {
      newDB.execute("""CREATE TABLE Items
      (
      id INTEGER PRIMARY KEY,
      type TEXT,
      by TEXT,
      time INTEGER,
      text TEXT,
      parent INTEGER,
      kids BLOB,
      dead INTEGER,
      deleted INTEGER,
      url TEXT,
      score INTEGER,
      title TEXT,
      descendants INTEFER)
      """);
    });
  }

  //async coz we need it every time we access to database
  Future<ItemModel> fetchItem(int id) async {
    final maps = await db.query(
      /* maps coz all the data fetched will come out as list of Map objects, List<Map<String,dynamic>>
      { "id":1,
        "title":"ItemTitle1",
        "text":"Text from the item 1",
        "descendants":230 }
       { "id":2,
        "title":"ItemTitle2",
        "text":"Text from the item 2",
        "descendants":240 }
       */
      "Items",
      columns: null,
      //null coz we want all columns. if we want to fetch only title, then write ['title'];
      where: "id = ?",
      whereArgs: [id], //coz to avoid sql injection
    );

    if (maps.length > 0) {
      //if we got at least one data
      return ItemModel.fromDb(maps.first);
    }
    return null; // if we got no data, return null
  }

  Future<int> addItem(ItemModel item) {
    return db.insert("Items", item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> clear() {
    return db.delete("Items");
  }
}

final newsDbProvider = NewsDbProvider();
