import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/circle_member_entity.dart';

class CircleMemberModel extends CircleMemberEntity {
  const CircleMemberModel({
    required super.userId,
    required super.displayName,
    required super.email,
    required super.role,
  });

  factory CircleMemberModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CircleMemberModel(
      userId: doc.id,
      displayName: data['displayName'] ?? 'Family Member',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Family Member',
    );
  }
}