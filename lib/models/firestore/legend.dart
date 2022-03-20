import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g7trailapp/models/firestore/legend_item.dart';

class Legend {
  String? id;
  Map<String, dynamic> flMeta;
  List<LegendItem> items;
  DocumentReference? reference;

  Legend(this.flMeta, this.items);

  Legend.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        flMeta = map['_fl_meta_'],
        items = map["items"] == ""
            ? []
            : map["items"].map<LegendItem>((map) {
                return LegendItem.fromMap(map);
              }).toList();

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> mappedItems = [];

    for (var i in items) {
      mappedItems.add(i.toMap());
    }

    return {
      'id': id,
      '_fl_meta_': flMeta,
      'items': mappedItems,
    };
  }

  Legend.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
