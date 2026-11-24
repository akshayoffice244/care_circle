import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  StreamSubscription? _authSubscription;

  AuthBloc({
    required this.getCurrentUserUseCase,
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<AuthUserChangedEvent>(_onAuthUserChanged);
    on<SignInRequestedEvent>(_onSignInRequested);
    on<SignUpRequestedEvent>(_onSignUpRequested);
    on<SignOutRequestedEvent>(_onSignOutRequested);

    // Listen to real-time auth changes
    _authSubscription = getCurrentUserUseCase.authStateChanges.listen((user) {
      add(AuthUserChangedEvent(user));
    });
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(UnauthenticatedState());
    }
  }

  void _onAuthUserChanged(
      AuthUserChangedEvent event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthenticatedState(event.user!));
    } else {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onSignInRequested(
      SignInRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await signInUseCase(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthFailureState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignUpRequested(
      SignUpRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await signUpUseCase(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthFailureState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignOutRequested(
      SignOutRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    await signOutUseCase();
    emit(UnauthenticatedState());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}