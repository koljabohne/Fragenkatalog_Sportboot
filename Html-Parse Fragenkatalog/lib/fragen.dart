import 'dart:convert';

List<FrageElement> katalogFromJson(String str) => List<FrageElement>.from(json.decode(str).map((x) => FrageElement.fromJson(x)));
String katalogToJson(FrageElement data) => json.encode(data.toJson());

class FrageElement {
  FrageElement({
    required this.frage,
    required this.antwort,
    required this.count,
    this.image,
    //this.checkColor = Colors.black,
  });
  String frage;
  List<Antwort> antwort;
  int count;
  String? image;
  //Color checkColor;

  factory FrageElement.fromJson(Map<String, dynamic> json) => FrageElement(
        frage: json["Frage"],
        antwort: List<Antwort>.from(json["Antworten"].map((x) => Antwort.fromJson(x))),
        count: json["Count"],
        image: json["Image"],
      );

  Map<String, dynamic> toJson() => {
        "Frage": frage,
        "Count": count,
        "Image": image ?? "",
        "Antworten": List<dynamic>.from(antwort.map((x) => x.toJson())),
      };

  //factory FrageElement.fromJsonDB(Map<String, dynamic> json, List<Antwort> ant) => FrageElement(frage: json["Frage"], antwort: ant, count: json["Count"], image: json["Image"]);

}

class FrageImage {
  FrageImage({required this.frage, required this.imagepath});
  String frage;
  String imagepath;
}

class Antwort {
  Antwort({required this.type, required this.text});
  bool type;
  String text;

  factory Antwort.fromJson(Map<String, dynamic> json) => Antwort(
        type: json["type"],
        text: json["text"],
      );
  Map<String, dynamic> toJson() => {"type": type, "text": text};
}
