import 'package:equatable/equatable.dart';
import '../../domain/entities/circle_entity.dart';

abstract class CircleEvent extends Equatable {
  const CircleEvent();
  @override
  List<Object?> get props => [];
}

class LoadCircleEvent extends CircleEvent {
  final String circleId;
  const LoadCircleEvent(this.circleId);
  @override
  List<Object?> get props => [circleId];
}

class CircleUpdatedEvent extends CircleEvent {
  final CircleEntity? circle;
  const CircleUpdatedEvent(this.circle);
  @override
  List<Object?> get props => [circle];
}

class CreateCircleRequestedEvent extends CircleEvent {
  final String name;
  final String adminUserId;
  const CreateCircleRequestedEvent({required this.name, required this.adminUserId});
  @override
  List<Object?> get props => [name, adminUserId];
}

class JoinCircleRequestedEvent extends CircleEvent {
  final String inviteCode;
  final String userId;
  const JoinCircleRequestedEvent({required this.inviteCode, required this.userId});
  @override
  List<Object?> get props => [inviteCode, userId];
}

class LoadCircleMembersEvent extends CircleEvent {
  final List<String> memberIds;
  const LoadCircleMembersEvent(this.memberIds);
  @override
  List<Object?> get props => [memberIds];
}