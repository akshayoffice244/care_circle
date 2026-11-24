import 'package:equatable/equatable.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_log_entity.dart';

abstract class MedicationState extends Equatable {
  const MedicationState();
  @override
  List<Object?> get props => [];
}

class MedicationInitialState extends MedicationState {}

class MedicationLoadingState extends MedicationState {}

class MedicationLoadedState extends MedicationState {
  final List<MedicationEntity> medications;
  final List<MedicationLogEntity> logs;

  const MedicationLoadedState({
    required this.medications,
    this.logs = const [],
  });

  @override
  List<Object?> get props => [medications, logs];
}

class MedicationErrorState extends MedicationState {
  final String message;
  const MedicationErrorState(this.message);
  @override
  List<Object?> get props => [message];
}