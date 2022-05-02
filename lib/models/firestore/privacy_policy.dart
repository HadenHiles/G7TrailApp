import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacyPolicy {
  String? id;
  Map<String, dynamic> flMeta;
  int order;
  String? text;
  String? label;
  DocumentReference? reference;

  PrivacyPolicy(this.flMeta, this.order, this.text, this.label);

  PrivacyPolicy.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        flMeta = map['_fl_meta_'],
        order = map['order'],
        text = map['text'],
        label = map['label'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      '_fl_meta_': flMeta,
      'order': order,
      'text': text,
      'label': label,
    };
  }

  PrivacyPolicy.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
