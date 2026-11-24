import '../entities/medication_entity.dart';
import '../entities/medication_log_entity.dart';

abstract class MedicationRepository {
  /// Real-time stream of all medicines for a circle
  Stream<List<MedicationEntity>> streamMedications(String circleId);

  /// Add a new medication
  Future<void> addMedication(MedicationEntity medication);

  /// Update an existing medication
  Future<void> updateMedication(MedicationEntity medication);

  /// Delete a medication
  Future<void> deleteMedication(String medicationId);

  /// Mark medicine dose as Taken or Skipped & record adherence log
  Future<void> recordMedicationIntake({
    required MedicationEntity medication,
    required String status, // 'Taken' or 'Skipped'
    required String scheduledTime,
    required String userId,
    required String userName,
  });

  /// Stream medication adherence logs (history for doctor/family review)
  Stream<List<MedicationLogEntity>> streamMedicationLogs(String circleId);
}