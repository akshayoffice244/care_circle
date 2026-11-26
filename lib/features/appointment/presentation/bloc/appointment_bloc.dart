import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/add_appointment_usecase.dart';
import '../../domain/usecases/delete_appointment_usecase.dart';
import '../../domain/usecases/mark_appointment_completed_usecase.dart';
import '../../domain/usecases/set_follow_up_usecase.dart';
import '../../domain/usecases/stream_appointments_usecase.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final StreamAppointmentsUseCase streamAppointmentsUseCase;
  final AddAppointmentUseCase addAppointmentUseCase;
  final MarkAppointmentCompletedUseCase markAppointmentCompletedUseCase;
  final SetFollowUpUseCase setFollowUpUseCase;
  final DeleteAppointmentUseCase deleteAppointmentUseCase;

  StreamSubscription? _appointmentsSubscription;

  AppointmentBloc({
    required this.streamAppointmentsUseCase,
    required this.addAppointmentUseCase,
    required this.markAppointmentCompletedUseCase,
    required this.setFollowUpUseCase,
    required this.deleteAppointmentUseCase,
  }) : super(AppointmentInitialState()) {
    on<LoadAppointmentsEvent>(_onLoadAppointments);
    on<AppointmentsUpdatedEvent>(_onAppointmentsUpdated);
    on<AddAppointmentEvent>(_onAddAppointment);
    on<MarkAppointmentCompletedEvent>(_onMarkCompleted);
    on<SetFollowUpReminderEvent>(_onSetFollowUp);
    on<DeleteAppointmentEvent>(_onDeleteAppointment);
  }

  void _onLoadAppointments(
      LoadAppointmentsEvent event, Emitter<AppointmentState> emit) {
    emit(AppointmentLoadingState());
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription =
        streamAppointmentsUseCase(event.circleId).listen((appointments) {
          add(AppointmentsUpdatedEvent(appointments));
        });
  }

  Future<void> _onAppointmentsUpdated(
      AppointmentsUpdatedEvent event, Emitter<AppointmentState> emit) async {
    emit(AppointmentLoadedState(event.appointments));

    // Automatically sync upcoming appointment alarms on this device
    for (final appt in event.appointments) {
      if (!appt.isCompleted && appt.appointmentDateTime.isAfter(DateTime.now())) {
        await NotificationService().cancelNotification(appt.doctorName.hashCode);
        await NotificationService().scheduleAppointmentReminder(
          id: appt.id.hashCode,
          doctorName: appt.doctorName,
          clinic: appt.clinicOrHospital,
          appointmentDateTime: appt.appointmentDateTime,
        );
      }
    }
  }

  Future<void> _onAddAppointment(
      AddAppointmentEvent event, Emitter<AppointmentState> emit) async {
    try {
      await addAppointmentUseCase(event.appointment);
    } catch (e) {
      emit(AppointmentErrorState(e.toString()));
    }
  }

  Future<void> _onMarkCompleted(
      MarkAppointmentCompletedEvent event, Emitter<AppointmentState> emit) async {
    try {
      await markAppointmentCompletedUseCase(event.appointmentId);
    } catch (e) {
      emit(AppointmentErrorState(e.toString()));
    }
  }

  Future<void> _onSetFollowUp(
      SetFollowUpReminderEvent event, Emitter<AppointmentState> emit) async {
    try {
      await setFollowUpUseCase(
        appointmentId: event.appointmentId,
        followUpDate: event.followUpDate,
      );
    } catch (e) {
      emit(AppointmentErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteAppointment(
      DeleteAppointmentEvent event, Emitter<AppointmentState> emit) async {
    try {
      await deleteAppointmentUseCase(event.appointmentId);
      await NotificationService().cancelNotification(event.appointmentId.hashCode);
      await NotificationService().cancelNotification(event.doctorName.hashCode);
      await NotificationService().cancelNotification((event.appointmentId + '_followup').hashCode);
    } catch (e) {
      emit(AppointmentErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _appointmentsSubscription?.cancel();
    return super.close();
  }
}