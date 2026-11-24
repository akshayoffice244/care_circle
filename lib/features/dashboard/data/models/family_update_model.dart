import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/family_update_entity.dart';

class FamilyUpdateModel extends FamilyUpdateEntity {
  const FamilyUpdateModel({
    required super.id,
    required super.circleId,
    required super.title,
    required super.message,
    required super.authorName,
    required super.timestamp,
    required super.type,
  });

  factory FamilyUpdateModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FamilyUpdateModel(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      authorName: data['authorName'] ?? 'Family Member',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'note',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circleId': circleId,
      'title': title,
      'message': message,
      'authorName': authorName,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
    };
  }
}