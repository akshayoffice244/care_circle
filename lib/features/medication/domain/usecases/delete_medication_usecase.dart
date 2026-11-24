import '../repositories/medication_repository.dart';

class DeleteMedicationUseCase {
  final MedicationRepository repository;
  DeleteMedicationUseCase(this.repository);

  Future<void> call(String medicationId) {
    return repository.deleteMedication(medicationId);
  }
}
