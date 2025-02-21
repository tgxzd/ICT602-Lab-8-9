import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  final String id;
  final String userId;
  final String course;
  final String department;
  final DateTime createdAt;

  UserInfo({
    required this.id,
    required this.userId,
    required this.course,
    required this.department,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'course': course,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserInfo.fromMap(Map<String, dynamic> map, String docId) {
    // Debug print
    print('Converting document to UserInfo: $map');
    
    final timestamp = map['createdAt'] as Timestamp?;
    final createdAt = timestamp?.toDate() ?? DateTime.now();

    return UserInfo(
      id: docId,
      userId: map['userId'] ?? '',
      course: map['course'] ?? '',
      department: map['department'] ?? '',
      createdAt: createdAt,
    );
  }
} 