import '../entities/circle_entity.dart';
import '../repositories/circle_repository.dart';

class CreateCircleUseCase {
  final CircleRepository repository;
  CreateCircleUseCase(this.repository);

  Future<CircleEntity> call({required String name, required String adminUserId}) {
    return repository.createCircle(name: name, adminUserId: adminUserId);
  }
}