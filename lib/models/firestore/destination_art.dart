import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationArt {
  String? id;
  String description;
  DocumentReference? image;
  String title;
  String uniqueKey;
  DocumentReference? reference;

  DestinationArt(this.description, this.image, this.title, this.uniqueKey);

  DestinationArt.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        description = map['description'],
        image = map['image'].isEmpty ? null : map['image'][0],
        title = map['title'],
        uniqueKey = map['uniqueKey'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'image': image,
      'title': title,
      'uniqueKey': uniqueKey,
    };
  }

  DestinationArt.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
