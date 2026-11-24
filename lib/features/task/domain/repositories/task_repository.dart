import '../entities/task_entity.dart';

abstract class TaskRepository {
  /// Real-time stream of all daily tasks for a circle
  Stream<List<TaskEntity>> streamTasks(String circleId);

  /// Add a new daily task with an assignee
  Future<void> addTask(TaskEntity task);

  /// Update task details
  Future<void> updateTask(TaskEntity task);

  /// Delete a task
  Future<void> deleteTask(String taskId);

  /// Toggle task completion status
  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
    required String userId,
    required String userName,
  });

  /// Notify family members about a pending task
  Future<void> notifyFamilyAboutPendingTask({
    required TaskEntity task,
    required String senderName,
  });
}