import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationImage {
  String? id;
  String description;
  DocumentReference? image;
  String title;
  String uniqueKey;
  DocumentReference? reference;

  DestinationImage(this.description, this.image, this.title, this.uniqueKey);

  DestinationImage.fromMap(Map<String, dynamic> map, {this.reference})
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

  DestinationImage.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
