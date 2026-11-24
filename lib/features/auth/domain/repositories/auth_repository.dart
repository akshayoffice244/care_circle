import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream that emits whenever the current user logs in or out
  Stream<UserEntity?> get authStateChanges;

  /// Get the current logged-in user profile
  Future<UserEntity?> getCurrentUser();

  /// Sign up with email, password, and display name
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Log in with email and password
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign out
  Future<void> signOut();

  /// Update the active circle ID of the user
  Future<void> updateUserActiveCircle({
    required String userId,
    required String circleId,
  });
}