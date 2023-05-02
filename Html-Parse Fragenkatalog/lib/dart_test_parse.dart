//import 'dart:html' as html;
import 'dart:io';

import 'package:dart_test_parse/dart_test_parse.dart' as dart_test_parse;

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import 'fragen.dart';

//Question Range = 7 to 374
main() async {
  //  Future<File> get_localFile() async {
  //    return File('ELWIS - Spezifische Fragen See.html');
  //  }

  // File xmlString = await get_localFile();
  // String str = await xmlString.readAsString();
  //See:
  final response = await http.Client().get(Uri.parse('https://www.elwis.de/DE/Sportschifffahrt/Sportbootfuehrerscheine/Fragenkatalog-See/Spezifische-Fragen-See/Spezifische-Fragen-See-node.html'));
  //Binnen:
  //final response =await http.Client().get(Uri.parse('https://www.elwis.de/DE/Sportschifffahrt/Sportbootfuehrerscheine/Fragenkatalog-Binnen/Spezifische-Fragen-Binnen/Spezifische-Fragen-Binnen-node.html'));

  if (response.statusCode == 200) {
    //local File:
    //var document = parse(str);

    // Website:
    var document = parse(response.body);
    var elements = document.getElementsByClassName("elwisOL-lowerLiteral");
    var ant = document.querySelectorAll("p");

    List<FrageImage> fragen = [];
    List<FrageElement> allElements = [];
    List<Antwort> antworten = [];
    int anz = 0;
    String zpath = "assets";

    Future<String> isbild(val) async {
      if (val.getElementsByTagName("img").isNotEmpty) {
        anz++;
        // print("BILD");

        var test = val.getElementsByTagName("img");
        // print(test[0].attributes);
        String alt = (test[0].attributes["src"]).toString();

        // print(alt);
        try {
          var res = await http.get(Uri.parse("https://www.elwis.de" + alt));
          String tempString = alt;

          tempString = tempString.split("/").last;
          tempString = tempString.split(".gif")[0];

          print("Strign: " + tempString);
          print(anz);
          String dir = val.getElementsByTagName("img")[0].attributes["title"].toString();
          print(dir);

          File('$zpath/$tempString.gif').writeAsBytes(res.bodyBytes);
          //print('$zpath/$tempString.gif');
          return tempString + ".gif";
        } catch (e) {
          throw UnimplementedError(e.toString());
        }
      } else {
        return "";
      }
    }

    for (int i = 0; i < ant.length; i++) {
      if (ant[i].text.contains(RegExp("[1-9999]."))) {
        if (ant[i].text.contains("Stand: 01")) continue;
        fragen.add(FrageImage(frage: ant[i].text, imagepath: await isbild(ant[i + 1])));
      }
    }

//alle Antworten:
    for (final element in elements) {
      for (int r = 0; r < 4; r++) {
        antworten.add(Antwort(type: r == 0 ? true : false, text: element.children[r].text));
      }
    }
    int y = 0;
    for (final val in fragen) {
      List<Antwort> temp = [];
      for (int u = 0; u < 4; u++) {
        temp.add(antworten[y + u]);
      }
      y = y + 4;
      allElements.add(FrageElement(frage: val.frage, antwort: temp, count: 0, image: val.imagepath));
    }

    print(anz.toString());
    print("anz.toString()");

    String objects = "[";
    allElements.forEach((element) {
      objects = objects + (katalogToJson(element)) + ",";
    });
    objects = objects + "]";

    File('assets/daten.json').writeAsString(objects);
  }
}
