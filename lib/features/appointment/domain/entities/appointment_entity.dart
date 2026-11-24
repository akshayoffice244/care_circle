import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String circleId;
  final String doctorName;          // e.g. "Dr. Sarah Adams (Cardiologist)"
  final String clinicOrHospital;    // e.g. "City Care Hospital, Room 204"
  final DateTime appointmentDateTime;
  final String notes;               // e.g. "Bring previous blood test reports"
  final bool isCompleted;
  final DateTime? followUpDate;     // Follow-up appointment reminder
  final bool reminderToBookUpcoming;// Reminder to book next appointment

  const AppointmentEntity({
    required this.id,
    required this.circleId,
    required this.doctorName,
    required this.clinicOrHospital,
    required this.appointmentDateTime,
    this.notes = '',
    this.isCompleted = false,
    this.followUpDate,
    this.reminderToBookUpcoming = false,
  });

  @override
  List<Object?> get props => [
    id,
    circleId,
    doctorName,
    clinicOrHospital,
    appointmentDateTime,
    notes,
    isCompleted,
    followUpDate,
    reminderToBookUpcoming,
  ];
}