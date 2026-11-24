import 'package:equatable/equatable.dart';
import '../../domain/entities/circle_entity.dart';
import '../../domain/entities/circle_member_entity.dart';

abstract class CircleState extends Equatable {
  const CircleState();
  @override
  List<Object?> get props => [];
}

class CircleInitialState extends CircleState {}

class CircleLoadingState extends CircleState {}

class CircleLoadedState extends CircleState {
  final CircleEntity circle;
  final List<CircleMemberEntity> members;
  const CircleLoadedState({required this.circle, this.members = const []});
  @override
  List<Object?> get props => [circle, members];
}

class NoCircleJoinedState extends CircleState {}

class CircleOperationSuccessState extends CircleState {
  final String message;
  const CircleOperationSuccessState(this.message);
  @override
  List<Object?> get props => [message];
}

class CircleFailureState extends CircleState {
  final String message;
  const CircleFailureState(this.message);
  @override
  List<Object?> get props => [message];
}