import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/circle_entity.dart';
import '../../domain/entities/circle_member_entity.dart';
import '../../domain/repositories/circle_repository.dart';
import '../models/circle_member_model.dart';
import '../models/circle_model.dart';

class CircleRepositoryImpl implements CircleRepository {
  final FirebaseFirestore _firestore;

  CircleRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  @override
  Future<CircleEntity> createCircle({
    required String name,
    required String adminUserId,
  }) async {
    final circleRef = _firestore.collection('circles').doc();
    final inviteCode = _generateInviteCode();

    final circle = CircleModel(
      id: circleRef.id,
      name: name,
      inviteCode: inviteCode,
      adminUserId: adminUserId,
      memberIds: [adminUserId],
      createdAt: DateTime.now(),
    );

    await circleRef.set(circle.toMap());

    // Link user to this active circle
    await _firestore.collection('users').doc(adminUserId).update({
      'activeCircleId': circleRef.id,
      'role': 'Primary Caregiver',
    });

    return circle;
  }

  @override
  Future<CircleEntity> joinCircle({
    required String inviteCode,
    required String userId,
  }) async {
    final query = await _firestore
        .collection('circles')
        .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid invite code. Circle not found.');
    }

    final doc = query.docs.first;
    final circle = CircleModel.fromSnapshot(doc);

    if (!circle.memberIds.contains(userId)) {
      await doc.reference.update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    }

    await _firestore.collection('users').doc(userId).update({
      'activeCircleId': doc.id,
    });

    return circle;
  }

  @override
  Stream<CircleEntity?> streamCircle(String circleId) {
    if (circleId.isEmpty) return Stream.value(null);
    return _firestore
        .collection('circles')
        .doc(circleId)
        .snapshots()
        .map((doc) => doc.exists ? CircleModel.fromSnapshot(doc) : null);
  }

  @override
  Future<List<CircleMemberEntity>> getCircleMembers(List<String> memberIds) async {
    if (memberIds.isEmpty) return [];

    final members = <CircleMemberEntity>[];
    for (final id in memberIds) {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        members.add(CircleMemberModel.fromSnapshot(doc));
      }
    }
    return members;
  }
}