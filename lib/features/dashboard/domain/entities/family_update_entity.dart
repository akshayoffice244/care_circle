import 'package:equatable/equatable.dart';

class FamilyUpdateEntity extends Equatable {
  final String id;
  final String circleId;
  final String title;            // e.g. "Medicine Taken", "Appointment Booked"
  final String message;          // e.g. "Alex gave Grandma Morning Blood Pressure pill"
  final String authorName;       // Name of person who triggered/wrote update
  final DateTime timestamp;
  final String type;             // 'medication', 'appointment', 'task', 'note'

  const FamilyUpdateEntity({
    required this.id,
    required this.circleId,
    required this.title,
    required this.message,
    required this.authorName,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [
    id,
    circleId,
    title,
    message,
    authorName,
    timestamp,
    type,
  ];
}