import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'ListOfKatalos.dart';
import 'Fragen.dart';

import 'hiveDb.dart' as db;
import 'Einstellungen.dart';

class Front extends StatefulWidget {
  const Front({Key? key}) : super(key: key);

  @override
  State<Front> createState() => _FrontState();
}

class _FrontState extends State<Front> {
  List<Katalog> katalogs = [];
  int pageIndex = 0;
  init() async {
    var check = await db.getData("initialisiert");
    print(check);
    if (check == "" || check != "true") {
      const keyFontziseNormalFont = "keyFontziseNormalFont";
      const keyFrage = "KeyFrageFontSize";
      await db.setData(keyFontziseNormalFont, "14");
      await db.setData(keyFrage, "16");
      await db.setData("initialisiert", "true");
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  List<Widget> pagelist() {
    return [ListOfKatalos(), Einstellungen()];
  }

  List<BottomNavigationBarItem> navBarItems() {
    return [
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: 'Kataloge'),
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Einstellungen'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: pagelist()[pageIndex],
        bottomNavigationBar: BottomNavigationBar(
          //selectedItem,
          currentIndex: pageIndex,
          // fixedColor: textcolor,
          //backgroundColor: Colors.white, //Color(0xFF64747C),
          onTap: (value) {
            setState(() {
              pageIndex = value;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: navBarItems(),
        ));
  }
}
