import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseClient {
  final FirebaseFirestore firestore;

  FirebaseClient({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;
  Future<dynamic> setData({
    required String collectionName,
    dynamic body,
  }) async {
    CollectionReference collection = firestore.collection(collectionName);

    try {
      await collection.doc().set(body);
      return 'Success';
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getData({required String collectionName}) async {
    CollectionReference collection = firestore.collection(collectionName);
    return collection.get();
  }

  Future<List<Map<String, dynamic>>> getSubCollection({
    required String parentCollection,
    required String parentDocId,
    required String subCollection,
  }) async {
    final CollectionReference<Map<String, dynamic>> subCol = firestore
        .collection(parentCollection)
        .doc(parentDocId)
        .collection(subCollection);
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await subCol
        .get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  Future<dynamic> getDoc({
    required String collectionName,
    required String docId,
  }) async {
    CollectionReference collection = firestore.collection(collectionName);
    DocumentSnapshot<Object?> documentSnapshot = await collection
        .doc(docId)
        .get();

    if (documentSnapshot.exists) {
      return documentSnapshot.data();
    } else {
      return null;
    }
  }
}
