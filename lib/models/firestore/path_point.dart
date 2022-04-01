import 'package:cloud_firestore/cloud_firestore.dart';

class Point {
  String? id;
  double latitude;
  double longitude;
  DocumentReference? reference;

  Point(this.latitude, this.longitude);

  Point.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        latitude = (map['latitude'] == "" || map['latitude'] == null) ? 0.0 : map['latitude'],
        longitude = (map['longitude'] == "" || map['longitude'] == null) ? 0.0 : map['longitude'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Point.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
