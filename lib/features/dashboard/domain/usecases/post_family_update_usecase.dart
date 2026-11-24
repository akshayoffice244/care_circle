import '../entities/family_update_entity.dart';
import '../repositories/dashboard_repository.dart';

class PostFamilyUpdateUseCase {
  final DashboardRepository repository;
  PostFamilyUpdateUseCase(this.repository);

  Future<void> call(FamilyUpdateEntity update) {
    return repository.postFamilyUpdate(update);
  }
}