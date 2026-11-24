import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class StreamMedicationsUseCase {
  final MedicationRepository repository;
  StreamMedicationsUseCase(this.repository);

  Stream<List<MedicationEntity>> call(String circleId) {
    return repository.streamMedications(circleId);
  }
}