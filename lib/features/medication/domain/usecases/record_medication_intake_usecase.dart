import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class RecordMedicationIntakeUseCase {
  final MedicationRepository repository;
  RecordMedicationIntakeUseCase(this.repository);

  Future<void> call({
    required MedicationEntity medication,
    required String status,
    required String scheduledTime,
    required String userId,
    required String userName,
  }) {
    return repository.recordMedicationIntake(
      medication: medication,
      status: status,
      scheduledTime: scheduledTime,
      userId: userId,
      userName: userName,
    );
  }
}