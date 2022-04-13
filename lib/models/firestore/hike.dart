import 'package:cloud_firestore/cloud_firestore.dart';

class Hike {
  String? id;
  String data;
  Duration duration;
  DateTime date;
  DocumentReference? reference;

  Hike(this.data, this.duration, this.date);

  Hike.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['data'] != null),
        assert(map['duration'] != null),
        assert(map['date'] != null),
        id = map['id'],
        data = map['data'],
        duration = Duration(seconds: map['duration']),
        date = map['date'].toDate();

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'duration': duration.inSeconds,
      'date': date,
    };
  }

  Hike.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
