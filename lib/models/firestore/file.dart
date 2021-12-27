import 'package:cloud_firestore/cloud_firestore.dart';

class File {
  String? id;
  Map<String, dynamic> flMeta;
  String contentType;
  String file;
  DocumentReference folderId;
  List<dynamic> sizes;
  String type;
  DocumentReference? reference;

  File(this.flMeta, this.contentType, this.file, this.folderId, this.sizes, this.type);

  File.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        flMeta = map['_fl_meta_'],
        contentType = map['contentType'],
        file = map['file'],
        folderId = map['folderId'],
        sizes = map['sizes'],
        type = map['type'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      '_fl_meta_': flMeta,
      'contentType': contentType,
      'file': file,
      'folderId': folderId,
      'sizes': sizes,
      'type': type,
    };
  }

  File.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
