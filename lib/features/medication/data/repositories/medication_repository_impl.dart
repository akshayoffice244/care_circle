import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_log_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../models/medication_log_model.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final FirebaseFirestore _firestore;

  MedicationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<MedicationEntity>> streamMedications(String circleId) {
    return _firestore
        .collection('medications')
        .where('circleId', isEqualTo: circleId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MedicationModel.fromSnapshot(doc)).toList());
  }

  @override
  Future<void> addMedication(MedicationEntity medication) async {
    final docRef = _firestore.collection('medications').doc();
    final model = MedicationModel(
      id: docRef.id,
      circleId: medication.circleId,
      name: medication.name,
      dosage: medication.dosage,
      instructions: medication.instructions,
      scheduleTimes: medication.scheduleTimes,
      isTakenToday: false,
    );
    await docRef.set(model.toMap());
  }

  @override
  Future<void> updateMedication(MedicationEntity medication) async {
    await _firestore
        .collection('medications')
        .doc(medication.id)
        .update((medication as MedicationModel).toMap());
  }

  @override
  Future<void> deleteMedication(String medicationId) async {
    await _firestore.collection('medications').doc(medicationId).delete();
  }

  @override
  Future<void> recordMedicationIntake({
    required MedicationEntity medication,
    required String status,
    required String scheduledTime,
    required String userId,
    required String userName,
  }) async {
    final now = DateTime.now();

    // 1. Update medication state
    await _firestore.collection('medications').doc(medication.id).update({
      'isTakenToday': status == 'Taken',
      'lastTakenAt': Timestamp.fromDate(now),
      'lastTakenByName': userName,
    });

    // 2. Add an adherence history log
    final logRef = _firestore.collection('medication_logs').doc();
    final logModel = MedicationLogModel(
      id: logRef.id,
      medicationId: medication.id,
      medicationName: medication.name,
      circleId: medication.circleId,
      scheduledTime: scheduledTime,
      timestamp: now,
      status: status,
      recordedByUserId: userId,
      recordedByName: userName,
    );
    await logRef.set(logModel.toMap());

    // 3. Post to family updates feed automatically
    await _firestore.collection('family_updates').add({
      'circleId': medication.circleId,
      'title': 'Medication $status',
      'message': '$userName marked ${medication.name} (${medication.dosage}) as $status for $scheduledTime.',
      'authorName': userName,
      'timestamp': Timestamp.fromDate(now),
      'type': 'medication',
    });
  }

  @override
  Stream<List<MedicationLogEntity>> streamMedicationLogs(String circleId) {
    return _firestore
        .collection('medication_logs')
        .where('circleId', isEqualTo: circleId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MedicationLogModel.fromSnapshot(doc)).toList());
  }
}