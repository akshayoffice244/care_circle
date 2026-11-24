import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class StreamTasksUseCase {
  final TaskRepository repository;
  StreamTasksUseCase(this.repository);

  Stream<List<TaskEntity>> call(String circleId) {
    return repository.streamTasks(circleId);
  }
}