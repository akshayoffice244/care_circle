import '../repositories/task_repository.dart';

class ToggleTaskCompletionUseCase {
  final TaskRepository repository;
  ToggleTaskCompletionUseCase(this.repository);

  Future<void> call({
    required String taskId,
    required bool isCompleted,
    required String userId,
    required String userName,
  }) {
    return repository.toggleTaskCompletion(
      taskId: taskId,
      isCompleted: isCompleted,
      userId: userId,
      userName: userName,
    );
  }
}