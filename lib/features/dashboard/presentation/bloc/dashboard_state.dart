import 'package:equatable/equatable.dart';
import '../../domain/entities/family_update_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {}

class DashboardLoadingState extends DashboardState {}

class DashboardLoadedState extends DashboardState {
  final List<FamilyUpdateEntity> updates;
  const DashboardLoadedState(this.updates);
  @override
  List<Object?> get props => [updates];
}

class DashboardErrorState extends DashboardState {
  final String message;
  const DashboardErrorState(this.message);
  @override
  List<Object?> get props => [message];
}