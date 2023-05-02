import 'dart:async';
import 'hiveDb.dart' as db;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'Fragen.dart';

class CardMode extends StatefulWidget {
  Katalog katalog;
  CardMode(this.katalog, {Key? key}) : super(key: key);

  @override
  State<CardMode> createState() => _CardModeState(katalog);
}

class _CardModeState extends State<CardMode> {
  Katalog katalog;
  _CardModeState(this.katalog);
  String host = "https://.../fragenkatalog/app/pics/TPgHtDRwlac8yuYQjSwq7NB7v+v+/";
  Timer? timer;
  double fontSizeAntwort = 14;
  double fontSizeFrage = 16;

  static const keyFontziseNormalFont = "keyFontziseNormalFont";
  static const keyFrage = "KeyFrageFontSize";

  getfontSize() async {
    String change = await db.getData("chnageFontsize");
    if (change == "true") {
      fontSizeFrage = double.parse(await db.getData(keyFrage));
      fontSizeAntwort = double.parse(await db.getData(keyFontziseNormalFont));
      await db.setData("chnageFontsize", "false");
      setState(() {});
    }
  }

  static const countupDuration = Duration(seconds: 1);
  static const countdownDuration = Duration(minutes: 10);
  Duration duration = Duration();
  bool countDown = false;

  @override
  void initState() {
    getfontSize();
    super.initState();
    reset();
    katalog.frageElement.forEach((element) {
      element.antwort.shuffle();
    });
  }

  void reset() {
    if (countDown) {
      setState(() => duration = countdownDuration);
      startTimer();
    } else {
      setState(() => duration = Duration());
      startTimer();
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    const addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }

  late Size deviceSize;
  late double scaleY;
  bool checked = false;
  static const _kDuration = Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  //int? currentSelectedItem = null;
  final _controller = PageController();

  bool checkFrage(int ind, int pos) {
    setState(() {
      katalog.frageElement[pos].showAnswer = true;
    });
    var val = katalog.frageElement[pos].antwort[ind].type;
    if (val == true) {
      setState(() {
        katalog.frageElement[pos].wasRight == true;
        katalog.frageElement[pos].checkColor = Colors.green;
      });
      return true;
    } else {
      setState(() {
        katalog.frageElement[pos].checkColor = Colors.red;
      });
      return false;
    }
  }

  Future<int> updatecounter(bool val, int position) async {
    if (val == true) {
      return await KatalogDatabase.instance.updateKorrCount(katalog.frageElement[position].id!, katalog.frageElement[position].count);
    } else {
      return await KatalogDatabase.instance.resetCount(katalog.frageElement[position].id!, katalog.frageElement[position].count);
    }
  }

  getPercentColor(double val) {
    if (val > 0.65) return Colors.green;
    return Colors.red;
  }

  double getPercent(int val) {
    if (val == 0) return 0;
    double per = val / 3;
    if (per > 1.0) return 1;
    return per;
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    scaleY = deviceSize.height / 100;
    return Scaffold(
      appBar: CupertinoNavigationBar(
          middle: Text(katalog.id),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: const Icon(CupertinoIcons.back),
          )),
      body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Container(
              height: deviceSize.height,
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: PageView.builder(
                  controller: _controller,
                  itemCount: katalog.frageElement.length,
                  itemBuilder: (context, position) {
                    return ListView(children: [
                      Center(child: buildTime()),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: katalog.frageElement[position].frage.contains(RegExp("[1-400]."))
                            ? Text(
                                katalog.frageElement[position].frage,
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSizeFrage),
                              )
                            : Text(
                                katalog.frageElement[position].id.toString() + " " + katalog.frageElement[position].frage,
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSizeFrage),
                              ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      katalog.frageElement[position].image == null || katalog.frageElement[position].image == ""
                          ? Container()
                          : Image.network(host + katalog.frageElement[position].image!, width: 100, height: 100, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Container(padding: const EdgeInsets.fromLTRB(0, 0, 0, 10), child: const Text("Bild kann nicht geladen werden. Nummer und Frage notieren bzw Screenshot!"));
                            }),
                      PreferredSize(
                          preferredSize: const Size(double.infinity, 150),
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: katalog.frageElement[position].antwort.length,
                              itemBuilder: (context, index) {
                                return Column(children: [
                                  RadioListTile<int>(
                                      contentPadding: const EdgeInsets.all(1),
                                      value: index,
                                      onChanged: (ind) => setState(() => katalog.frageElement[position].currentSelectedItem = (ind!)),
                                      groupValue: katalog.frageElement[position].currentSelectedItem,
                                      title: katalog.frageElement[position].antwort[index].type == true && katalog.frageElement[position].showAnswer == true
                                          ? Text(katalog.frageElement[position].antwort[index].text,
                                              style: TextStyle(
                                                fontSize: fontSizeAntwort,
                                                color: katalog.frageElement[position].checkColor,
                                              ))
                                          : Text(
                                              katalog.frageElement[position].antwort[index].text,
                                              style: TextStyle(fontSize: fontSizeAntwort),
                                            )),
                                  index == katalog.frageElement[position].antwort.length - 1
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            //crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    try {
                                                      if (katalog.frageElement[position].currentSelectedItem == null) return;
                                                      var val = checkFrage(katalog.frageElement[position].currentSelectedItem!, position);
                                                      katalog.frageElement[position].count = await updatecounter(val, position);
                                                      setState(() {});
                                                    } catch (_) {}
                                                  },
                                                  child: const Text("Check")),
                                              const SizedBox(width: 30),
                                              Text((position + 1).toString() + "/" + katalog.frageElement.length.toString()),
                                              const SizedBox(width: 30),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    _controller.nextPage(duration: _kDuration, curve: _kCurve);
                                                  },
                                                  child: const Text("Next"))
                                            ],
                                          ))
                                      : Container(),
                                  // position == katalog.frageElement.length - 1 && index == katalog.frageElement[position].antwort.length - 1
                                  //    ? ElevatedButton(onPressed: () {}, child: const Text("Abgeben und Ergebnisse Speichern"))
                                  //    : Container(),
                                  index == katalog.frageElement[position].antwort.length - 1
                                      ? Container(
                                          padding: const EdgeInsets.fromLTRB(50, 5, 50, 5),
                                          child: LinearPercentIndicator(
                                            //value: katalog.frageElement[position].count / 3,
                                            progressColor: getPercentColor(getPercent(katalog.frageElement[position].count)),
                                            //nimation: true,
                                            percent: getPercent(katalog.frageElement[position].count),
                                          ))
                                      : Container(),
                                  index == katalog.frageElement[position].antwort.length - 1 ? Center(child: Text("Vom Katalog: " + katalog.frageElement[position].katalog)) : Container(),

                                  index == katalog.frageElement[position].antwort.length - 1
                                      ? const SizedBox(
                                          height: 60,
                                        )
                                      : Container(),
                                ]);
                              })),
                    ]);
                  }))),
    );
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Text(hours + ":" + minutes + ":" + seconds);
  }
}
