import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationAudio {
  String? id;
  DocumentReference? file;
  String textToSpeech;
  String title;
  String uniqueKey;
  DocumentReference? reference;

  DestinationAudio(this.file, this.textToSpeech, this.title, this.uniqueKey);

  DestinationAudio.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        file = map['file'].isEmpty ? null : map['file'][0],
        textToSpeech = map['textToSpeech'],
        title = map['title'],
        uniqueKey = map['uniqueKey'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file': file,
      'textToSpeech': textToSpeech,
      'title': title,
      'uniqueKey': uniqueKey,
    };
  }

  DestinationAudio.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
