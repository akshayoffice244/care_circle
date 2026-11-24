import '../repositories/appointment_repository.dart';

class SetFollowUpUseCase {
  final AppointmentRepository repository;
  SetFollowUpUseCase(this.repository);

  Future<void> call({
    required String appointmentId,
    required DateTime followUpDate,
  }) {
    return repository.setFollowUpReminder(
      appointmentId: appointmentId,
      followUpDate: followUpDate,
    );
  }
}