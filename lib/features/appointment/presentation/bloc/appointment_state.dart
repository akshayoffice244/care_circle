import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();
  @override
  List<Object?> get props => [];
}

class AppointmentInitialState extends AppointmentState {}

class AppointmentLoadingState extends AppointmentState {}

class AppointmentLoadedState extends AppointmentState {
  final List<AppointmentEntity> appointments;
  const AppointmentLoadedState(this.appointments);
  @override
  List<Object?> get props => [appointments];
}

class AppointmentErrorState extends AppointmentState {
  final String message;
  const AppointmentErrorState(this.message);
  @override
  List<Object?> get props => [message];
}