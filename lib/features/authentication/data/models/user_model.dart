import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.studentId,
    super.department,
    super.role,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return UserModel(
      id: data['uid'] as String? ?? document.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      studentId: data['studentId'] as String?,
      department: data['department'] as String?,
      role: data['role'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'studentId': studentId,
      'department': department,
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
