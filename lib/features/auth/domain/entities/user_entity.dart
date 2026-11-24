import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? activeCircleId;
  final String role; // e.g. 'Primary Caregiver', 'Family Member', 'Care Recipient'

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.activeCircleId,
    this.role = 'Family Member',
  });

  @override
  List<Object?> get props => [id, email, displayName, activeCircleId, role];
}