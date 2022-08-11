import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g7trailapp/models/firestore/path_point.dart';

class Landmark {
  String? id;
  Map<String, dynamic> flMeta;
  String title;
  List<Point> points;
  DocumentReference? icon;
  String? iconURL;
  bool enabled;
  DocumentReference? reference;

  Landmark(this.flMeta, this.title, this.points, this.enabled);

  Landmark.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        flMeta = map['_fl_meta_'],
        title = map['title'],
        points = map['points'] == ""
            ? []
            : map['points'].map<Point>((map) {
                return Point.fromMap(map);
              }).toList(),
        icon = map['icon'].isEmpty ? null : map['icon'][0],
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
      'icon': icon,
      'enabled': enabled,
    };
  }

  Landmark.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
