import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String circleId;
  final String title;               // e.g. "Blood pressure check"
  final String description;         // e.g. "Log systolic and diastolic values"
  final String assignedToUserId;    // Assigned family member's user ID
  final String assignedToName;      // Name of assigned member
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completedByName;

  const TaskEntity({
    required this.id,
    required this.circleId,
    required this.title,
    this.description = '',
    required this.assignedToUserId,
    required this.assignedToName,
    required this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.completedByName,
  });

  @override
  List<Object?> get props => [
    id,
    circleId,
    title,
    description,
    assignedToUserId,
    assignedToName,
    dueDate,
    isCompleted,
    completedAt,
    completedByName,
  ];
}