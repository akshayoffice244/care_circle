import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();
  @override
  List<Object?> get props => [];
}

class LoadAppointmentsEvent extends AppointmentEvent {
  final String circleId;
  const LoadAppointmentsEvent(this.circleId);
  @override
  List<Object?> get props => [circleId];
}

class AppointmentsUpdatedEvent extends AppointmentEvent {
  final List<AppointmentEntity> appointments;
  const AppointmentsUpdatedEvent(this.appointments);
  @override
  List<Object?> get props => [appointments];
}

class AddAppointmentEvent extends AppointmentEvent {
  final AppointmentEntity appointment;
  const AddAppointmentEvent(this.appointment);
  @override
  List<Object?> get props => [appointment];
}

class MarkAppointmentCompletedEvent extends AppointmentEvent {
  final String appointmentId;
  const MarkAppointmentCompletedEvent(this.appointmentId);
  @override
  List<Object?> get props => [appointmentId];
}

class SetFollowUpReminderEvent extends AppointmentEvent {
  final String appointmentId;
  final DateTime followUpDate;
  const SetFollowUpReminderEvent({
    required this.appointmentId,
    required this.followUpDate,
  });
  @override
  List<Object?> get props => [appointmentId, followUpDate];
}

class DeleteAppointmentEvent extends AppointmentEvent {
  final String appointmentId;
  final String doctorName;
  const DeleteAppointmentEvent({
    required this.appointmentId,
    required this.doctorName,
  });

  @override
  List<Object?> get props => [appointmentId, doctorName];
}
