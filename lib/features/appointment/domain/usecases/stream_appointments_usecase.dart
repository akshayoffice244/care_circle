import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class StreamAppointmentsUseCase {
  final AppointmentRepository repository;
  StreamAppointmentsUseCase(this.repository);

  Stream<List<AppointmentEntity>> call(String circleId) {
    return repository.streamAppointments(circleId);
  }
}