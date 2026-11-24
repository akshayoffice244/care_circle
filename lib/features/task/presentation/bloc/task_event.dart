import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final String circleId;
  const LoadTasksEvent(this.circleId);
  @override
  List<Object?> get props => [circleId];
}

class TasksUpdatedEvent extends TaskEvent {
  final List<TaskEntity> tasks;
  const TasksUpdatedEvent(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class AddTaskEvent extends TaskEvent {
  final TaskEntity task;
  const AddTaskEvent(this.task);
  @override
  List<Object?> get props => [task];
}

class ToggleTaskCompletionEvent extends TaskEvent {
  final String taskId;
  final bool isCompleted;
  final String userId;
  final String userName;

  const ToggleTaskCompletionEvent({
    required this.taskId,
    required this.isCompleted,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [taskId, isCompleted, userId, userName];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  const DeleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class NotifyPendingTaskEvent extends TaskEvent {
  final TaskEntity task;
  final String senderName;

  const NotifyPendingTaskEvent({
    required this.task,
    required this.senderName,
  });

  @override
  List<Object?> get props => [task, senderName];
}

