import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_app/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up User
  Future<UserModel> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception("UID is null after signup");

      final userModel = UserModel(uid: uid, name: name, email: email);

      //  Save user data
      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      //Create call token data
      await _firestore.collection('call_tokens').doc(uid).set({
        'user_id': uid,
        'call_id': "call_${uid.substring(0, 6)}", // simple unique call ID
        'token': "dummy_token_$uid", // can be replaced with real token later
      });

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  // Sign In User
  Future<UserModel> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception("UID is null after login");

      final snapshot = await _firestore.collection('users').doc(uid).get();

      if (!snapshot.exists) throw Exception("User data not found in Firestore");

      return UserModel.fromMap(snapshot.data()!);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Sign out failed: $e");
    }
  }
}
