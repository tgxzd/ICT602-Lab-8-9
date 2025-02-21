import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_info.dart';
import 'auth_service.dart';

class UserInfoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get user's information stream
  Stream<List<UserInfo>> getUserInfoStream() {
    final userId = _authService.currentUser?.uid;
    print('Current userId: $userId'); // Debug print

    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('user_info')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('Snapshot docs length: ${snapshot.docs.length}'); // Debug print
          final list = snapshot.docs
              .map((doc) {
                print('Document data: ${doc.data()}'); // Debug print
                return UserInfo.fromMap(doc.data(), doc.id);
              })
              .toList();
          print('Mapped list length: ${list.length}'); // Debug print
          return list;
        });
  }

  // Add new user information
  Future<void> addUserInfo(String course, String department) async {
    final userId = _authService.currentUser?.uid;
    print('Adding info for userId: $userId'); // Debug print

    if (userId == null) throw 'User not authenticated';

    try {
      final docRef = await _firestore.collection('user_info').add({
        'userId': userId,
        'course': course,
        'department': department,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Document added with ID: ${docRef.id}'); // Debug print
    } catch (e) {
      print('Error adding document: $e'); // Debug print
      throw 'Failed to add information: $e';
    }
  }

  // Update user information
  Future<void> updateUserInfo(String id, String course, String department) async {
    try {
      await _firestore.collection('user_info').doc(id).update({
        'course': course,
        'department': department,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Document updated: $id'); // Debug print
    } catch (e) {
      print('Error updating document: $e'); // Debug print
      throw 'Failed to update information: $e';
    }
  }

  // Delete user information
  Future<void> deleteUserInfo(String id) async {
    try {
      await _firestore.collection('user_info').doc(id).delete();
      print('Document deleted: $id'); // Debug print
    } catch (e) {
      print('Error deleting document: $e'); // Debug print
      throw 'Failed to delete information: $e';
    }
  }
} 