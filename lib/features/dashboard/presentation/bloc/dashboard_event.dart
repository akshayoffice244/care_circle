import 'package:equatable/equatable.dart';
import '../../domain/entities/family_update_entity.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboardUpdatesEvent extends DashboardEvent {
  final String circleId;
  final String? currentUserName;
  const LoadDashboardUpdatesEvent(this.circleId, {this.currentUserName});
  @override
  List<Object?> get props => [circleId, currentUserName];
}

class DashboardUpdatesUpdatedEvent extends DashboardEvent {
  final List<FamilyUpdateEntity> updates;
  const DashboardUpdatesUpdatedEvent(this.updates);
  @override
  List<Object?> get props => [updates];
}

class PostFamilyNoteEvent extends DashboardEvent {
  final FamilyUpdateEntity update;
  const PostFamilyNoteEvent(this.update);
  @override
  List<Object?> get props => [update];
}