import 'package:equatable/equatable.dart';

class CircleEntity extends Equatable {
  final String id;
  final String name;             // e.g. "Grandma's Care Circle"
  final String inviteCode;       // 6-character unique code, e.g. "CARE99"
  final String adminUserId;      // Primary caregiver/admin
  final List<String> memberIds;  // IDs of all family members in this circle
  final DateTime createdAt;

  const CircleEntity({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.adminUserId,
    required this.memberIds,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, inviteCode, adminUserId, memberIds, createdAt];
}