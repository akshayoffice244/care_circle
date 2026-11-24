import '../entities/circle_entity.dart';
import '../entities/circle_member_entity.dart';

abstract class CircleRepository {
  /// Create a new family care circle with a random 6-character code
  Future<CircleEntity> createCircle({
    required String name,
    required String adminUserId,
  });

  /// Join an existing circle using its 6-character invite code
  Future<CircleEntity> joinCircle({
    required String inviteCode,
    required String userId,
  });

  /// Real-time stream of the current active circle
  Stream<CircleEntity?> streamCircle(String circleId);

  /// Fetch all member profiles within a circle
  Future<List<CircleMemberEntity>> getCircleMembers(List<String> memberIds);
}