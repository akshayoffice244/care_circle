import 'package:equatable/equatable.dart';

class MedicationLogEntity extends Equatable {
  final String id;
  final String medicationId;
  final String medicationName;
  final String circleId;
  final String scheduledTime; // e.g. "08:00 AM"
  final DateTime timestamp;
  final String status;        // 'Taken', 'Skipped'
  final String recordedByUserId;
  final String recordedByName;

  const MedicationLogEntity({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.circleId,
    required this.scheduledTime,
    required this.timestamp,
    required this.status,
    required this.recordedByUserId,
    required this.recordedByName,
  });

  @override
  List<Object?> get props => [
    id,
    medicationId,
    medicationName,
    circleId,
    scheduledTime,
    timestamp,
    status,
    recordedByUserId,
    recordedByName,
  ];
}