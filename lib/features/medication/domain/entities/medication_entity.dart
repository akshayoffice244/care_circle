import 'package:equatable/equatable.dart';

class MedicationEntity extends Equatable {
  final String id;
  final String circleId;
  final String name;                 // e.g., "Metformin"
  final String dosage;               // e.g., "500 mg", "1 tablet"
  final String instructions;         // e.g., "Take after breakfast"
  final List<String> scheduleTimes;  // e.g., ["08:00 AM", "08:00 PM"]
  final bool isTakenToday;
  final DateTime? lastTakenAt;
  final String? lastTakenByName;

  const MedicationEntity({
    required this.id,
    required this.circleId,
    required this.name,
    required this.dosage,
    this.instructions = '',
    required this.scheduleTimes,
    this.isTakenToday = false,
    this.lastTakenAt,
    this.lastTakenByName,
  });

  @override
  List<Object?> get props => [
    id,
    circleId,
    name,
    dosage,
    instructions,
    scheduleTimes,
    isTakenToday,
    lastTakenAt,
    lastTakenByName,
  ];
}