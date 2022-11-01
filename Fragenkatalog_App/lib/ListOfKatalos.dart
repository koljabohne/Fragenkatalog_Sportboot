import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'Fragen.dart';
import 'hiveDb.dart' as db;
import 'CardMode.dart';

class ListOfKatalos extends StatefulWidget {
  ListOfKatalos({Key? key}) : super(key: key);

  @override
  State<ListOfKatalos> createState() => _ListOfKatalosState();
}

class _ListOfKatalosState extends State<ListOfKatalos> {
  List<Katalog> katalogs = [];
  int pageIndex = 0;

  Future deleteAll() async {
    //print(await KatalogDatabase.instance.getAllData());
    await KatalogDatabase.instance.deleteAll();
    print(await KatalogDatabase.instance.getAllFragen());
    await db.setData("DataExists", "false");
  }

  String path = "habh";
  List<FrageElement> see = [];
  List<FrageElement> binnen = [];
  List<FrageElement> basis = [];
  int laenge = 0;
  bool loading = false;

  Future checkOnUpdate() async {
    var set = await db.getData("DataExists");
    if (set == "true") {
      //see = await KatalogDatabase.instance.getAllFragen();
      //  print(see.length);
      //  print(see[0].katalog);

      //Update path From FragenSeee:
      String fragenSee = await DefaultAssetBundle.of(context).loadString('$path/see.json');
      String fragenBinnen = await DefaultAssetBundle.of(context).loadString('$path/binnen.json');
      List<FrageElement> qSea = katalogFromJson(fragenSee, "See");
      qSea.addAll(katalogFromJson(fragenBinnen, "Binnen"));
      await KatalogDatabase.instance.updateImagePathSee(qSea);

      see = await KatalogDatabase.instance.getAllDataByKatalog("See");
      binnen = await KatalogDatabase.instance.getAllDataByKatalog("Binnen");
      basis = await KatalogDatabase.instance.getAllDataByKatalog("Basisfragen");
      getFragen();
    } else {
      setState(() {
        loading = true;
      });
      //Basisfragen , See, Binnen
      String fragenSee = await DefaultAssetBundle.of(context).loadString('$path/see.json');
      String fragenBinnen = await DefaultAssetBundle.of(context).loadString('$path/binnen.json');
      String fragenBasis = await DefaultAssetBundle.of(context).loadString('$path/basis.json');
      String fragenTeil2 = await DefaultAssetBundle.of(context).loadString('$path/name.json');

      List<HelperFragen> help = fragenFromJson(fragenTeil2);
      List<FrageElement> tempBasis = katalogFromJson(fragenBasis, "Basisfragen");
      List<FrageElement> tempBinnen = katalogFromJson(fragenBinnen, "Binnen");
      List<FrageElement> qSea = katalogFromJson(fragenSee, "See");

      print("Listen erstellt");
      await KatalogDatabase.instance.createData(tempBasis);
      await KatalogDatabase.instance.createData(tempBinnen);
      await KatalogDatabase.instance.updateFrageT2(help);
      await KatalogDatabase.instance.createData(qSea);

      await db.setData("DataExists", "true");
      print("Sind in DB");
      see = await KatalogDatabase.instance.getAllDataByKatalog("See");
      binnen = await KatalogDatabase.instance.getAllDataByKatalog("Binnen");
      basis = await KatalogDatabase.instance.getAllDataByKatalog("Basisfragen");
      //see = await KatalogDatabase.instance.getAllFragen();
      print(see.length);
      print(see[0].katalog);
      getFragen();
    }
  }

  refresh() {
    katalogs.removeRange(0, katalogs.length);
    setState(() {});
    checkOnUpdate();
  }

  Future getFragen() async {
    basis;
    see;
    binnen;

    var xMAl = [];
    xMAl.addAll(basis);
    xMAl.addAll(see);
    xMAl.addAll(binnen);
    laenge = xMAl.length;
    xMAl.shuffle();

    List<FrageElement> nullMal = [];
    List<FrageElement> einMal = [];
    List<FrageElement> zweiMal = [];
    List<FrageElement> dreiMal = [];
    List<FrageElement> vierMal = [];
    List<FrageElement> fuenfMal = [];

    for (var element in xMAl) {
      if (element.count == 0) {
        nullMal.add(element);
      }
      if (element.count == 1) {
        einMal.add(element);
      }

      if (element.count == 2) {
        zweiMal.add(element);
      }
      if (element.count == 3) {
        dreiMal.add(element);
      }
      if (element.count == 4) {
        vierMal.add(element);
      }
      if (element.count >= 5) {
        fuenfMal.add(element);
      }
    }

    setState(() {
      katalogs.add(Katalog(id: "Basisfragen", countKatalog: "0", frageElement: basis));
      katalogs.add(Katalog(id: "Fragen Binnen", countKatalog: "0", frageElement: binnen));
      katalogs.add(Katalog(id: "Fragen See", countKatalog: "0", frageElement: see));
      katalogs.add(Katalog(id: "0-mal", countKatalog: "0", frageElement: nullMal, hasLeading: true, color: Colors.red));
      katalogs.add(Katalog(id: "1-mal", countKatalog: "0", frageElement: einMal, hasLeading: true, color: Colors.orange));
      katalogs.add(Katalog(id: "2-mal", countKatalog: "0", frageElement: zweiMal, hasLeading: true, color: Colors.green[900]));
      katalogs.add(Katalog(id: "3-mal", countKatalog: "0", frageElement: dreiMal, hasLeading: true, color: Colors.green[700]));
      katalogs.add(Katalog(id: "4-mal", countKatalog: "0", frageElement: vierMal, hasLeading: true, color: Colors.green[500]));
      katalogs.add(Katalog(id: "5-mal", countKatalog: "0", frageElement: fuenfMal, hasLeading: true, color: Colors.green[200]));
      loading = false;
    });
  }

  Future teste() async {
    String fragenTeil2 = await DefaultAssetBundle.of(context).loadString('$path/name.json');
    List<HelperFragen> help = fragenFromJson(fragenTeil2);
  }

  @override
  void initState() {
    super.initState();
    //deleteAll();
    //teste();
    checkOnUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CupertinoNavigationBar(
          middle: Text("Kataloge"),
        ),
        body: loading == false
            ? ListView.builder(
                itemCount: katalogs.length,
                itemBuilder: (context, index) {
                  return (ListTile(
                    leading: katalogs[index].hasLeading == true ? Icon(CupertinoIcons.circle_filled, color: katalogs[index].color) : const Icon(CupertinoIcons.book_circle),
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(builder: (context) => CardMode(katalogs[index]))).then((value) {
                        refresh();
                      });
                    },
                    title: Text(katalogs[index].id),
                    trailing: Icon(CupertinoIcons.chevron_forward),
                    subtitle: Text(katalogs[index].frageElement.length.toString() + "/" + laenge.toString()),
                  ));
                })
            : const Center(child: CupertinoActivityIndicator()));
  }
}

class _TourListFirst extends StatelessWidget {
  final Katalog kat;

  const _TourListFirst({
    required this.kat,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => CardMode(kat)));
        },
        child: Card(
          child: Text(kat.id, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ));
  }
}

class _TourList extends StatelessWidget {
  final List<Katalog> kat;

  const _TourList({
    required this.kat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
            itemCount: kat.length,
            itemBuilder: (context, index) {
              return (ListTile(
                title: Text("data" + kat[index].id),
              ));
            }));
  }
}
