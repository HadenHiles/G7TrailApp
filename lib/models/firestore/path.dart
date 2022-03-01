import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g7trailapp/models/firestore/path_point.dart';

class Path {
  String? id;
  Map<String, dynamic> flMeta;
  String title;
  List<Point> points;
  Color hexColor;
  bool enabled;
  DocumentReference? reference;

  Path(this.flMeta, this.title, this.points, this.hexColor, this.enabled);

  Path.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        flMeta = map['_fl_meta_'],
        title = map['title'],
        points = map['points'] == ""
            ? []
            : map['points'].map<Point>((map) {
                return Point.fromMap(map);
              }).toList(),
        hexColor = Color(int.parse(("0xff" + map['hexColor']).toString())),
        enabled = map['enabled'];

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> mappedPoints = [];

    for (var p in points) {
      mappedPoints.add(p.toMap());
    }

    return {
      'id': id,
      '_fl_meta_': flMeta,
      'title': title,
      'points': mappedPoints,
      'hexColor': hexColor.value.toRadixString(16),
      'enabled': enabled,
    };
  }

  Path.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
