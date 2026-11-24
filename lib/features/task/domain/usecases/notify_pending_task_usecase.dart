import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class NotifyPendingTaskUseCase {
  final TaskRepository repository;
  NotifyPendingTaskUseCase(this.repository);

  Future<void> call({
    required TaskEntity task,
    required String senderName,
  }) {
    return repository.notifyFamilyAboutPendingTask(
      task: task,
      senderName: senderName,
    );
  }
}
