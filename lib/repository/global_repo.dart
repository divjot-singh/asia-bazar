import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalRepo {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference sellerRef = _firestore.collection('sellerInfo');
  Future<Map> fetchSellerInfo() async {
    try {
      QuerySnapshot doc = await sellerRef.get();
      return doc.docs[0].data();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
