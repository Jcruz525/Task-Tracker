import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_preferences.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserPreferences> getPreferences() async {
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return UserPreferences.fromMap(doc.data() ?? {});
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    await _firestore.collection('users').doc(currentUser!.uid).set(preferences.toMap());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
