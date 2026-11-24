import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/circle_entity.dart';

class CircleModel extends CircleEntity {
  const CircleModel({
    required super.id,
    required super.name,
    required super.inviteCode,
    required super.adminUserId,
    required super.memberIds,
    required super.createdAt,
  });

  factory CircleModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CircleModel(
      id: doc.id,
      name: data['name'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      adminUserId: data['adminUserId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'adminUserId': adminUserId,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}