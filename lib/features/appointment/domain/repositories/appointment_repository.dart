import '../entities/appointment_entity.dart';

abstract class AppointmentRepository {
  /// Real-time stream of all appointments for a circle
  Stream<List<AppointmentEntity>> streamAppointments(String circleId);

  /// Add a new doctor appointment
  Future<void> addAppointment(AppointmentEntity appointment);

  /// Update an appointment
  Future<void> updateAppointment(AppointmentEntity appointment);

  /// Delete an appointment
  Future<void> deleteAppointment(String appointmentId);

  /// Mark an appointment as completed
  Future<void> markAppointmentCompleted(String appointmentId);

  /// Set a follow-up appointment reminder date
  Future<void> setFollowUpReminder({
    required String appointmentId,
    required DateTime followUpDate,
  });
}