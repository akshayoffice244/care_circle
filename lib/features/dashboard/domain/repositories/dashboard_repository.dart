import '../entities/family_update_entity.dart';

abstract class DashboardRepository {
  /// Real-time stream of family activity feed (recent updates)
  Stream<List<FamilyUpdateEntity>> streamFamilyUpdates(String circleId);

  /// Post a new update or note to the family circle
  Future<void> postFamilyUpdate(FamilyUpdateEntity update);
}