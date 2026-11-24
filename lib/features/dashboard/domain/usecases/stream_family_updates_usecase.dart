import '../entities/family_update_entity.dart';
import '../repositories/dashboard_repository.dart';

class StreamFamilyUpdatesUseCase {
  final DashboardRepository repository;
  StreamFamilyUpdatesUseCase(this.repository);

  Stream<List<FamilyUpdateEntity>> call(String circleId) {
    return repository.streamFamilyUpdates(circleId);
  }
}