import '../entities/circle_entity.dart';
import '../repositories/circle_repository.dart';

class StreamCircleUseCase {
  final CircleRepository repository;
  StreamCircleUseCase(this.repository);

  Stream<CircleEntity?> call(String circleId) {
    return repository.streamCircle(circleId);
  }
}