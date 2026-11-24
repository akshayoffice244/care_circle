import '../entities/circle_member_entity.dart';
import '../repositories/circle_repository.dart';

class GetCircleMembersUseCase {
  final CircleRepository repository;
  GetCircleMembersUseCase(this.repository);

  Future<List<CircleMemberEntity>> call(List<String> memberIds) {
    return repository.getCircleMembers(memberIds);
  }
}