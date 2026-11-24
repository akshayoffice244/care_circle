import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.circleId,
    required super.title,
    super.description,
    required super.assignedToUserId,
    required super.assignedToName,
    required super.dueDate,
    super.isCompleted,
    super.completedAt,
    super.completedByName,
  });

  factory TaskModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskModel(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedToUserId: data['assignedToUserId'] ?? '',
      assignedToName: data['assignedToName'] ?? 'Unassigned',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      completedByName: data['completedByName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circleId': circleId,
      'title': title,
      'description': description,
      'assignedToUserId': assignedToUserId,
      'assignedToName': assignedToName,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'completedByName': completedByName,
    };
  }
}