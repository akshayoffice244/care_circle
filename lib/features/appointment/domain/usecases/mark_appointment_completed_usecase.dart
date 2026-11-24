import '../repositories/appointment_repository.dart';

class MarkAppointmentCompletedUseCase {
  final AppointmentRepository repository;
  MarkAppointmentCompletedUseCase(this.repository);

  Future<void> call(String appointmentId) {
    return repository.markAppointmentCompleted(appointmentId);
  }
}