import 'dart:ui';

import 'package:flutter/material.dart';
import 'hiveDb.dart' as db;
import 'package:flutter/cupertino.dart';
import 'Fragen.dart';

class Einstellungen extends StatefulWidget {
  Einstellungen({Key? key}) : super(key: key);

  @override
  State<Einstellungen> createState() => _EinstellungenState();
}

class _EinstellungenState extends State<Einstellungen> {
  static const keyFontziseNormalFont = "keyFontziseNormalFont";
  static const keyFrage = "KeyFrageFontSize";
  double fontSizeAntwort = 15;
  double fontSizeFrage = 17;

  getfontSize() async {
    try {
      print((await db.getData(keyFrage)));
      print((await db.getData(keyFontziseNormalFont)));
      fontSizeFrage = double.parse(await db.getData(keyFrage));
      fontSizeAntwort = double.parse(await db.getData(keyFontziseNormalFont));
      // await db.setData("chnageFontsize", "false");
      setState(() {});
    } catch (e) {
      throw UnimplementedError(e.toString());
    }
  }

  resetDB() {
    showDialog<String>(context: context, builder: (BuildContext context) => ErrorHandler());
  }

  @override
  void initState() {
    getfontSize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Schriftgröße Antworten:"),
        Slider(
          value: fontSizeAntwort,
          min: 10,
          max: 20,
          divisions: 10,
          label: '${fontSizeAntwort.round()}',
          onChanged: (value) async {
            setState(() {
              fontSizeAntwort = value;
            });
            await db.setData(keyFontziseNormalFont, value.toString());
            await db.setData("chnageFontsize", "true");
          },
        ),
        const Text("Schriftgröße Frage:"),
        Slider(
          value: fontSizeFrage,
          min: 13,
          max: 25,
          divisions: 12,
          label: '${fontSizeFrage.round()}',
          onChanged: (value) async {
            setState(() {
              fontSizeFrage = value;
            });
            await db.setData(keyFrage, value.toString());
            await db.setData("chnageFontsize", "true");
          },
        ),
        SizedBox(
          height: 30,
        ),
        CupertinoButton(
          onPressed: () async {
            await resetDB();
          },
          child: const Text("Datenbank zurücksetzen"),
          //  color: CupertinoColors.activeBlue,
        )
      ],
    ))
        /*
        //backgroundColor: CupertinoColors.white,
        appBar: CupertinoNavigationBar(
          leading: GestureDetector(
            onTap: () {},
            child: Icon(CupertinoIcons.settings),
          ),
          middle: Text('Einstellungen'),
        ),
        body: Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ListView(children: [
              SizedBox(
                height: 20,
              ),
              ListTile(
                tileColor: Colors.white,
                leading: const Icon(CupertinoIcons.person),
                title: const Text('Shuffle'),
                trailing: CupertinoSwitch(value: shuffel, onChanged: (value)  {
                shuffel = !shuffel;
                } 
              ),),
              const ListTile(
                tileColor: Colors.white,
                leading: Icon(CupertinoIcons.car_detailed),
                title: Text('Fahrzeuge'),
                trailing: Icon(CupertinoIcons.right_chevron, color: CupertinoColors.systemGrey),
              ),
             
            ]))*/
        );
  }
}

class ErrorHandler extends StatefulWidget {
  @override
  _ErrorHandler createState() => _ErrorHandler();
}

class _ErrorHandler extends State<ErrorHandler> {
  Future resetDB() async {
    await KatalogDatabase.instance.deleteAll();
    await db.setData("DataExists", "false");

    Navigator.pop(context);
  }

  @override
  void initState() {
    //checkConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Benachrichtigung'),
      content: const Text("Wirklich löschen"),
      actions: <Widget>[
        CupertinoDialogAction(
            child: const Text("Abbrechen"),
            onPressed: () {
              Navigator.pop(context);
            }),
        CupertinoDialogAction(
            child: const Text(
              "Löschen",
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
            onPressed: () {
              resetDB();
            }),
      ],
    );
  }
}
