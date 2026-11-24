import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_circle_usecase.dart';
import '../../domain/usecases/get_circle_members_usecase.dart';
import '../../domain/usecases/join_circle_usecase.dart';
import '../../domain/usecases/stream_circle_usecase.dart';
import 'circle_event.dart';
import 'circle_state.dart';

class CircleBloc extends Bloc<CircleEvent, CircleState> {
  final CreateCircleUseCase createCircleUseCase;
  final JoinCircleUseCase joinCircleUseCase;
  final StreamCircleUseCase streamCircleUseCase;
  final GetCircleMembersUseCase getCircleMembersUseCase;
  StreamSubscription? _circleSubscription;

  CircleBloc({
    required this.createCircleUseCase,
    required this.joinCircleUseCase,
    required this.streamCircleUseCase,
    required this.getCircleMembersUseCase,
  }) : super(CircleInitialState()) {
    on<LoadCircleEvent>(_onLoadCircle);
    on<CircleUpdatedEvent>(_onCircleUpdated);
    on<CreateCircleRequestedEvent>(_onCreateCircle);
    on<JoinCircleRequestedEvent>(_onJoinCircle);
    on<LoadCircleMembersEvent>(_onLoadCircleMembers);
  }

  void _onLoadCircle(LoadCircleEvent event, Emitter<CircleState> emit) {
    if (event.circleId.isEmpty) {
      emit(NoCircleJoinedState());
      return;
    }

    emit(CircleLoadingState());
    _circleSubscription?.cancel();
    _circleSubscription = streamCircleUseCase(event.circleId).listen((circle) {
      add(CircleUpdatedEvent(circle));
    });
  }

  Future<void> _onCircleUpdated(
      CircleUpdatedEvent event, Emitter<CircleState> emit) async {
    if (event.circle == null) {
      emit(NoCircleJoinedState());
    } else {
      final members = await getCircleMembersUseCase(event.circle!.memberIds);
      emit(CircleLoadedState(circle: event.circle!, members: members));
    }
  }

  Future<void> _onCreateCircle(
      CreateCircleRequestedEvent event, Emitter<CircleState> emit) async {
    emit(CircleLoadingState());
    try {
      final circle = await createCircleUseCase(
        name: event.name,
        adminUserId: event.adminUserId,
      );
      emit(CircleLoadedState(circle: circle));
      emit(const CircleOperationSuccessState('Circle created successfully!'));
    } catch (e) {
      emit(CircleFailureState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onJoinCircle(
      JoinCircleRequestedEvent event, Emitter<CircleState> emit) async {
    emit(CircleLoadingState());
    try {
      final circle = await joinCircleUseCase(
        inviteCode: event.inviteCode,
        userId: event.userId,
      );
      emit(CircleLoadedState(circle: circle));
      emit(const CircleOperationSuccessState('Joined circle successfully!'));
    } catch (e) {
      emit(CircleFailureState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadCircleMembers(
      LoadCircleMembersEvent event, Emitter<CircleState> emit) async {
    if (state is CircleLoadedState) {
      final currentState = state as CircleLoadedState;
      final members = await getCircleMembersUseCase(event.memberIds);
      emit(CircleLoadedState(circle: currentState.circle, members: members));
    }
  }

  @override
  Future<void> close() {
    _circleSubscription?.cancel();
    return super.close();
  }
}