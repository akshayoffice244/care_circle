import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/family_update_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/family_update_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final FirebaseFirestore _firestore;

  DashboardRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<FamilyUpdateEntity>> streamFamilyUpdates(String circleId) {
    return _firestore
        .collection('family_updates')
        .where('circleId', isEqualTo: circleId)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => FamilyUpdateModel.fromSnapshot(doc)).toList());
  }

  @override
  Future<void> postFamilyUpdate(FamilyUpdateEntity update) async {
    final docRef = _firestore.collection('family_updates').doc();
    final model = FamilyUpdateModel(
      id: docRef.id,
      circleId: update.circleId,
      title: update.title,
      message: update.message,
      authorName: update.authorName,
      timestamp: update.timestamp,
      type: update.type,
    );
    await docRef.set(model.toMap());
  }
}