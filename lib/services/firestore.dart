import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g7trailapp/services/utility.dart';

Future<List<DocumentSnapshot>> getContentByIds(List<String> ids, String path) async {
  // don't run if there aren't any ids or a path for the collection
  if (ids.length < 1 || path.isEmpty) return Future.value([]);

  CollectionReference collectionPath = FirebaseFirestore.instance.collection(path);
  List<DocumentSnapshot> batches = [];

  int lastBatchLength = -1;
  await Future.doWhile(() async {
    if (ids.length < 1) {
      return false;
    }

    // firestore limits batches to 10
    int limit = ids.length >= 9 ? 9 : ids.length - 1;
    List batch = limit >= 9 ? splice(ids, 0, limit) : ids;

    if (batch.length < 1 || batch.length == lastBatchLength) {
      return false;
    }

    lastBatchLength = batch.length;

    // add the batch request to a queue
    return await collectionPath.where('id', whereIn: batch).get().then((snapshot) {
      batches.addAll(snapshot.docs);
    }).then((_) {
      if (ids.length <= 1) {
        return false;
      }

      return true;
    });
  }).timeout(Duration(seconds: 20)).catchError((e) {
    print(e);
  }).whenComplete(
    () => Future.value(batches).then((content) => content),
  );

  return Future.value(batches).then((content) => content);
}
