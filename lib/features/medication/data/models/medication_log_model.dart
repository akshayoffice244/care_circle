import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medication_log_entity.dart';

class MedicationLogModel extends MedicationLogEntity {
  const MedicationLogModel({
    required super.id,
    required super.medicationId,
    required super.medicationName,
    required super.circleId,
    required super.scheduledTime,
    required super.timestamp,
    required super.status,
    required super.recordedByUserId,
    required super.recordedByName,
  });

  factory MedicationLogModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MedicationLogModel(
      id: doc.id,
      medicationId: data['medicationId'] ?? '',
      medicationName: data['medicationName'] ?? '',
      circleId: data['circleId'] ?? '',
      scheduledTime: data['scheduledTime'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'Taken',
      recordedByUserId: data['recordedByUserId'] ?? '',
      recordedByName: data['recordedByName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicationId': medicationId,
      'medicationName': medicationName,
      'circleId': circleId,
      'scheduledTime': scheduledTime,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'recordedByUserId': recordedByUserId,
      'recordedByName': recordedByName,
    };
  }
}