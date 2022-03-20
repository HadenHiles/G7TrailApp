import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class LegendItem {
  String? id;
  DocumentReference? image;
  String? imageURL;
  String title;
  Color color;
  String uniqueKey;
  DocumentReference? reference;

  LegendItem(this.image, this.title, this.color, this.uniqueKey);

  LegendItem.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        image = map['marker'].isEmpty ? null : map['marker'][0],
        title = map['title'],
        color = Color(int.parse(("0xff" + map['color'].substring(map['color'].length - 6)).toString())),
        uniqueKey = map['uniqueKey'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marker': image,
      'title': title,
      'color': "#" + color.value.toRadixString(16),
      'uniqueKey': uniqueKey,
    };
  }

  LegendItem.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
