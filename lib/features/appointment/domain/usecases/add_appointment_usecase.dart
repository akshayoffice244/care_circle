import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class AddAppointmentUseCase {
  final AppointmentRepository repository;
  AddAppointmentUseCase(this.repository);

  Future<void> call(AppointmentEntity appointment) {
    return repository.addAppointment(appointment);
  }
}