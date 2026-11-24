import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/add_medication_usecase.dart';
import '../../domain/usecases/delete_medication_usecase.dart';
import '../../domain/usecases/record_medication_intake_usecase.dart';
import '../../domain/usecases/stream_medication_logs_usecase.dart';
import '../../domain/usecases/stream_medications_usecase.dart';
import 'medication_event.dart';
import 'medication_state.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final StreamMedicationsUseCase streamMedicationsUseCase;
  final AddMedicationUseCase addMedicationUseCase;
  final RecordMedicationIntakeUseCase recordMedicationIntakeUseCase;
  final StreamMedicationLogsUseCase streamMedicationLogsUseCase;
  final DeleteMedicationUseCase deleteMedicationUseCase;

  StreamSubscription? _medsSubscription;
  StreamSubscription? _logsSubscription;

  MedicationBloc({
    required this.streamMedicationsUseCase,
    required this.addMedicationUseCase,
    required this.recordMedicationIntakeUseCase,
    required this.streamMedicationLogsUseCase,
    required this.deleteMedicationUseCase,
  }) : super(MedicationInitialState()) {
    on<LoadMedicationsEvent>(_onLoadMedications);
    on<MedicationsUpdatedEvent>(_onMedicationsUpdated);
    on<AddMedicationEvent>(_onAddMedication);
    on<RecordMedicationIntakeEvent>(_onRecordMedicationIntake);
    on<LoadMedicationLogsEvent>(_onLoadMedicationLogs);
    on<MedicationLogsUpdatedEvent>(_onMedicationLogsUpdated);
    on<DeleteMedicationEvent>(_onDeleteMedication);
  }

  void _onLoadMedications(
      LoadMedicationsEvent event, Emitter<MedicationState> emit) {
    emit(MedicationLoadingState());
    _medsSubscription?.cancel();
    _medsSubscription = streamMedicationsUseCase(event.circleId).listen((meds) {
      add(MedicationsUpdatedEvent(meds));
    });

    add(LoadMedicationLogsEvent(event.circleId));
  }

  Map<String, int>? _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      if (parts.length > 1) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      return {'hour': hour, 'minute': minute};
    } catch (_) {
      return null;
    }
  }

  Future<void> _onMedicationsUpdated(
      MedicationsUpdatedEvent event, Emitter<MedicationState> emit) async {
    final currentLogs = state is MedicationLoadedState
        ? (state as MedicationLoadedState).logs
        : const [];
    emit(MedicationLoadedState(
      medications: event.medications,
      logs: currentLogs.cast(),
    ));

    // Automatically sync alarms across all family member devices in the circle
    for (final med in event.medications) {
      if (!med.isTakenToday) {
        for (int i = 0; i < med.scheduleTimes.length; i++) {
          final timeStr = med.scheduleTimes[i];
          final parsed = _parseTimeString(timeStr);
          if (parsed != null) {
            await NotificationService().scheduleDailyMedicationReminder(
              id: (med.id.hashCode.abs() % 100000) + i,
              medicineName: med.name,
              dosage: med.dosage,
              hour: parsed['hour']!,
              minute: parsed['minute']!,
            );
          }
        }
      }
    }
  }

  Future<void> _onAddMedication(
      AddMedicationEvent event, Emitter<MedicationState> emit) async {
    try {
      await addMedicationUseCase(event.medication);
    } catch (e) {
      emit(MedicationErrorState(e.toString()));
    }
  }

  Future<void> _onRecordMedicationIntake(
      RecordMedicationIntakeEvent event, Emitter<MedicationState> emit) async {
    try {
      await recordMedicationIntakeUseCase(
        medication: event.medication,
        status: event.status,
        scheduledTime: event.scheduledTime,
        userId: event.userId,
        userName: event.userName,
      );
    } catch (e) {
      emit(MedicationErrorState(e.toString()));
    }
  }

  void _onLoadMedicationLogs(
      LoadMedicationLogsEvent event, Emitter<MedicationState> emit) {
    _logsSubscription?.cancel();
    _logsSubscription =
        streamMedicationLogsUseCase(event.circleId).listen((logs) {
          add(MedicationLogsUpdatedEvent(logs));
        });
  }

  void _onMedicationLogsUpdated(
      MedicationLogsUpdatedEvent event, Emitter<MedicationState> emit) {
    if (state is MedicationLoadedState) {
      final currentMeds = (state as MedicationLoadedState).medications;
      emit(MedicationLoadedState(medications: currentMeds, logs: event.logs));
    }
  }

  Future<void> _onDeleteMedication(
      DeleteMedicationEvent event, Emitter<MedicationState> emit) async {
    try {
      await deleteMedicationUseCase(event.medicationId);
      for (int i = 0; i < event.scheduleTimesCount; i++) {
        await NotificationService().cancelNotification(event.medicationName.hashCode + i);
      }
    } catch (e) {
      emit(MedicationErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _medsSubscription?.cancel();
    _logsSubscription?.cancel();
    return super.close();
  }
}