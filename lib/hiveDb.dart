import 'package:hive/hive.dart';

import 'package:path_provider/path_provider.dart' as path_provider;

// "Datenbank interface"
// wird in der Zukunft vermutlich auf SQLite umgestellt.
// nicht wirklich schön gelöst

Future initDatabase() async {
  final appDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
}

Future<void> setData(String key, String data) async {
  var box = await Hive.openBox('data');
  box.put(key, data);
  //print(box.get(key));
}

Future getData(String key) async {
  var box = await Hive.openBox('data');
  return box.get(key);
}
