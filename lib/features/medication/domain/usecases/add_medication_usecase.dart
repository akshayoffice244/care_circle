import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class AddMedicationUseCase {
  final MedicationRepository repository;
  AddMedicationUseCase(this.repository);

  Future<void> call(MedicationEntity medication) {
    return repository.addMedication(medication);
  }
}