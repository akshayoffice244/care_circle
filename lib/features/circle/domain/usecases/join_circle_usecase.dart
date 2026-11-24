import '../entities/circle_entity.dart';
import '../repositories/circle_repository.dart';

class JoinCircleUseCase {
  final CircleRepository repository;
  JoinCircleUseCase(this.repository);

  Future<CircleEntity> call({required String inviteCode, required String userId}) {
    return repository.joinCircle(inviteCode: inviteCode, userId: userId);
  }
}