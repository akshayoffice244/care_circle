import 'package:equatable/equatable.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_log_entity.dart';

abstract class MedicationEvent extends Equatable {
  const MedicationEvent();
  @override
  List<Object?> get props => [];
}

class LoadMedicationsEvent extends MedicationEvent {
  final String circleId;
  const LoadMedicationsEvent(this.circleId);
  @override
  List<Object?> get props => [circleId];
}

class MedicationsUpdatedEvent extends MedicationEvent {
  final List<MedicationEntity> medications;
  const MedicationsUpdatedEvent(this.medications);
  @override
  List<Object?> get props => [medications];
}

class AddMedicationEvent extends MedicationEvent {
  final MedicationEntity medication;
  const AddMedicationEvent(this.medication);
  @override
  List<Object?> get props => [medication];
}

class RecordMedicationIntakeEvent extends MedicationEvent {
  final MedicationEntity medication;
  final String status; // 'Taken' or 'Skipped'
  final String scheduledTime;
  final String userId;
  final String userName;

  const RecordMedicationIntakeEvent({
    required this.medication,
    required this.status,
    required this.scheduledTime,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [medication, status, scheduledTime, userId, userName];
}

class LoadMedicationLogsEvent extends MedicationEvent {
  final String circleId;
  const LoadMedicationLogsEvent(this.circleId);
  @override
  List<Object?> get props => [circleId];
}

class MedicationLogsUpdatedEvent extends MedicationEvent {
  final List<MedicationLogEntity> logs;
  const MedicationLogsUpdatedEvent(this.logs);
  @override
  List<Object?> get props => [logs];
}

class DeleteMedicationEvent extends MedicationEvent {
  final String medicationId;
  final String medicationName;
  final int scheduleTimesCount;

  const DeleteMedicationEvent({
    required this.medicationId,
    required this.medicationName,
    this.scheduleTimesCount = 1,
  });

  @override
  List<Object?> get props => [medicationId, medicationName, scheduleTimesCount];
}
