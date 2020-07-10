import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalRepo {
  static Firestore _firestore = Firestore.instance;
  static CollectionReference sellerRef = _firestore.collection('sellerInfo');
  Future<Map> fetchSellerInfo() async {
    try {
      QuerySnapshot doc = await sellerRef.getDocuments();
      return doc.documents[0].data;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
