import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medication_entity.dart';

class MedicationModel extends MedicationEntity {
  const MedicationModel({
    required super.id,
    required super.circleId,
    required super.name,
    required super.dosage,
    super.instructions,
    required super.scheduleTimes,
    super.isTakenToday,
    super.lastTakenAt,
    super.lastTakenByName,
  });

  factory MedicationModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MedicationModel(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      instructions: data['instructions'] ?? '',
      scheduleTimes: List<String>.from(data['scheduleTimes'] ?? []),
      isTakenToday: data['isTakenToday'] ?? false,
      lastTakenAt: (data['lastTakenAt'] as Timestamp?)?.toDate(),
      lastTakenByName: data['lastTakenByName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circleId': circleId,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'scheduleTimes': scheduleTimes,
      'isTakenToday': isTakenToday,
      'lastTakenAt': lastTakenAt != null ? Timestamp.fromDate(lastTakenAt!) : null,
      'lastTakenByName': lastTakenByName,
    };
  }
}