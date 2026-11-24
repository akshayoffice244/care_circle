import '../entities/medication_log_entity.dart';
import '../repositories/medication_repository.dart';

class StreamMedicationLogsUseCase {
  final MedicationRepository repository;
  StreamMedicationLogsUseCase(this.repository);

  Stream<List<MedicationLogEntity>> call(String circleId) {
    return repository.streamMedicationLogs(circleId);
  }
}