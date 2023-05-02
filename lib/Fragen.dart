import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

List<FrageElement> katalogFromJson(String str, String katalogstr) => List<FrageElement>.from(json.decode(str).map((x) => FrageElement.fromJson(x, katalogstr)));

List<HelperFragen> fragenFromJson(String str) {
  return List<HelperFragen>.from(json.decode(str).map((x) => HelperFragen.fromJson(x)));
}

class HelperFragen {
  String frage;
  String id;
  HelperFragen({
    required this.frage,
    required this.id,
  });

  factory HelperFragen.fromJson(Map<String, dynamic> json) {
    return HelperFragen(
      id: json["Frage"].split(". ")[0],
      frage: json["Frage"],
    );
  }
}

class Katalog {
  Katalog({
    required this.id,
    required this.countKatalog,
    required this.frageElement,
    this.hasLeading,
    this.color,
  });

  String id;
  String countKatalog;
  bool? hasLeading;
  Color? color;
  List<FrageElement> frageElement;

  factory Katalog.fromJson(Map<String, dynamic> json) => Katalog(
        id: json["id"],
        countKatalog: json["CountKatalog"],
        frageElement: List<FrageElement>.from(json["FrageElement"].map((x, str) => FrageElement.fromJson(x, str))),
      );
}

class FrageElement {
  FrageElement({
    this.id,
    required this.frage,
    required this.antwort,
    required this.count,
    required this.katalog,
    this.image,
    this.currentSelectedItem = 5,
    this.showAnswer = false,
    this.wasRight = false,
    this.checkColor = Colors.black,
  });
  int? id;
  String frage;
  String katalog;
  List<Antwort> antwort;
  var count;
  int? currentSelectedItem;
  String? image;
  bool showAnswer;
  bool wasRight;
  Color checkColor;

  factory FrageElement.fromJson(Map<String, dynamic> json, String katalog) => FrageElement(
        frage: json["Frage"],
        katalog: katalog,
        antwort: List<Antwort>.from(json["Antworten"].map((x) => Antwort.fromJson(x))),
        count: json["Count"],
        image: json["Image"],
      );

  factory FrageElement.fromJsonDB(Map<String, dynamic> json, List<Antwort> ant) =>
      FrageElement(frage: json["Frage"], id: json["id"], katalog: json["Katalog"], antwort: ant, count: json["Count"], image: json["Image"]);

  Map<String, Object?> toJasonDB() => {FragenFields.count: count, FragenFields.katalog: katalog, FragenFields.frage: frage, FragenFields.image: image};
}

class Antwort {
  Antwort({this.id, required this.type, required this.text, this.fragenID});
  int? id;
  bool type;
  String text;
  int? fragenID;

  factory Antwort.fromJson(Map<String, dynamic> json) => Antwort(
        type: json["type"],
        text: json["text"],
      );
  factory Antwort.fromJsonDB(Map<String, dynamic> json) => Antwort(
      type: json[AntwortenFields.type] == 1 ? true : false, text: json[AntwortenFields.antwort] as String, fragenID: json[AntwortenFields.fargenID] as int, id: json[AntwortenFields.id] as int);

  Map<String, Object?> toJasonDB(fkKey) => {AntwortenFields.type: type ? 1 : 0, AntwortenFields.antwort: text, AntwortenFields.fargenID: fkKey};
}

class KatalogDatabase {
  static final KatalogDatabase instance = KatalogDatabase._init();
  KatalogDatabase._init();
  static Database? _database;

  Future<Database?> get databsase async {
    if (_database != null) return _database!;
    _database = await _initDB("fragenkatalod.db");
    return _database;
  }

  Future<Database> _initDB(String file) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, file);
    return await openDatabase(path, version: 3, onCreate: _createDb);
  }

  Future _updatedb(Database db, int oldVersion, int newversion) async {
    const textType = "TEXT NULL";

    if (oldVersion < newversion) {
      // you can execute drop table and create table
      db.execute('''ALTER TABLE fragen ADD COLUMN ${FragenFields.katalog} $textType''');
    }
  }

  Future _createDb(Database db, int version) async {
    const idType = "INTEGER PRIMARY KEY";
    const idTypeAi = "INTEGER PRIMARY KEY AUTOINCREMENT";
    const textType = "TEXT NOT NULL";
    const textTypenull = "TEXT NULL";
    const countType = "INTEGER";
    const imageType = "TEXT NULL";
    const boolType = "BOOLEAN NOT NULL";
    const fkType = "FOREIGN KEY(${AntwortenFields.fargenID}) REFERENCES $tableFragen(${FragenFields.id})";

    await db.execute('''
    create table fragen (
      ${FragenFields.id} $idType,
      ${FragenFields.frage} $textType,
      ${FragenFields.count} $countType,
      ${FragenFields.image} $imageType,
      ${FragenFields.katalog} $textType
    )
      ''');

    await db.execute('''
    create table antworten (
      ${AntwortenFields.id} $idTypeAi,
      ${AntwortenFields.type} $boolType,
      ${AntwortenFields.antwort} $textType,
      ${AntwortenFields.fargenID} $countType,
$fkType
    )''');
  }

  Future clode() async {
    final db = await instance.databsase;
    db!.close();
  }

  Future updateFrageT2(List<HelperFragen> daten) async {
    final db = await instance.databsase;
    daten.forEach((element) async {
      int id = int.parse(element.id);
      await db!.rawUpdate('''update $tableFragen set ${FragenFields.frage} = ? where ${FragenFields.id} = ?''', [element.frage, (id)]);
    });
  }

  Future createData(List<FrageElement> daten) async {
    daten.forEach((element) async {
      int id = await createFrage(element);
      element.antwort.forEach(
        (x) async {
          await createAntwort(x, id);
        },
      );
    });
  }

  Future<int> createFrage(FrageElement element) async {
    final db = await instance.databsase;
    final id = await db!.insert(tableFragen, element.toJasonDB());
    // return element.copy(id: id);
    return id;
  }

  Future createAntwort(Antwort element, int fkID) async {
    final db = await instance.databsase;
    final id = await db!.insert(antwortenTable, element.toJasonDB(fkID));
    // return element.copy(id: id);
  }

  //Update wrong and Incomplete
  Future updateImagePathSee(List<FrageElement> daten) async {
    final db = await instance.databsase;
    daten.forEach((element) async {
      if (element.image == "") {
      } else {
        await db!.rawUpdate('''UPDATE $tableFragen SET ${FragenFields.image} = '${element.image}'  WHERE  ${FragenFields.frage} = '${element.frage}' ''');
      }
    });
  }

  Future<List<FrageElement>> getAllDataByKatalog(String str) async {
    final db = await instance.databsase;
    final fragen = await db!.rawQuery('''SELECT * FROM $tableFragen where ${FragenFields.katalog} = ? ''', [str]);
    final antworten = await db.query(antwortenTable);
    List<Antwort> ant = antworten.map((e) => Antwort.fromJsonDB(e)).toList();
    List<FrageElement> el = fragen.map((json) => FrageElement.fromJsonDB(json, matchedItems(json["id"] as int, ant))).toList();
    return el;
  }

  Future<List<FrageElement>> getAllFragen() async {
    final db = await instance.databsase;
    final fragen = await db!.query(tableFragen);
    final antworten = await db.query(antwortenTable);
    List<Antwort> ant = antworten.map((e) => Antwort.fromJsonDB(e)).toList();
    List<FrageElement> el = fragen.map((json) => FrageElement.fromJsonDB(json, matchedItems(json["id"] as int, ant))).toList();
    return el;
  }

  matchedItems(int id, List<Antwort> ant) {
    List<Antwort> rightAnswers = [];

    for (var element in ant) {
      if (element.fragenID == id) {
        rightAnswers.add(element);
      }
    }
    return rightAnswers;
  }

  Future deleteAll() async {
    final db = await instance.databsase;
    await db!.delete(tableFragen);
    await db.delete(antwortenTable);
  }

  Future<int> updateKorrCount(int id, int count) async {
    count++;
    final db = await instance.databsase;
    await db!.rawUpdate('''UPDATE $tableFragen set ${FragenFields.count} = ? where ${FragenFields.id} = ?''', [count, id]);
    return count;
  }

  Future<int> resetCount(int id, int count) async {
    // if (count == 0) {
    //   count = 0;
    // } else {
    //   count--;
    // }
    count = 0;
    final db = await instance.databsase;
    await db!.rawUpdate('''UPDATE $tableFragen set ${FragenFields.count} = ? where ${FragenFields.id} = ?''', [count, id]);
    return count;
  }
}

const String tableFragen = "fragen";
const String antwortenTable = "antworten";

class FragenFields {
  static const String id = "id";
  static const String frage = "Frage";
  static const String count = "Count";
  static const String image = "Image";
  static const String katalog = "Katalog";
}

class AntwortenFields {
  static const String id = "id";
  static const String antwort = "Antwort";
  static const String type = "Type";
  static const String fargenID = "ID_Frage";
}
