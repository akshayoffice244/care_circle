import 'package:equatable/equatable.dart';

class CircleMemberEntity extends Equatable {
  final String userId;
  final String displayName;
  final String email;
  final String role; // 'Admin', 'Primary Caregiver', 'Family Member'

  const CircleMemberEntity({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, displayName, email, role];
}