import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class AuthUserChangedEvent extends AuthEvent {
  final UserEntity? user;
  const AuthUserChangedEvent(this.user);
  @override
  List<Object?> get props => [user];
}

class SignInRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  const SignInRequestedEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class SignUpRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  const SignUpRequestedEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });
  @override
  List<Object?> get props => [email, password, displayName];
}

class SignOutRequestedEvent extends AuthEvent {}