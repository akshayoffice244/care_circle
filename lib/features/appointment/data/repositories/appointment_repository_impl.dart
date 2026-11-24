import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<AppointmentEntity>> streamAppointments(String circleId) {
    return _firestore
        .collection('appointments')
        .where('circleId', isEqualTo: circleId)
        .orderBy('appointmentDateTime')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => AppointmentModel.fromSnapshot(doc)).toList());
  }

  @override
  Future<void> addAppointment(AppointmentEntity appointment) async {
    final docRef = _firestore.collection('appointments').doc();
    final model = AppointmentModel(
      id: docRef.id,
      circleId: appointment.circleId,
      doctorName: appointment.doctorName,
      clinicOrHospital: appointment.clinicOrHospital,
      appointmentDateTime: appointment.appointmentDateTime,
      notes: appointment.notes,
      isCompleted: appointment.isCompleted,
      followUpDate: appointment.followUpDate,
      reminderToBookUpcoming: appointment.reminderToBookUpcoming,
    );
    await docRef.set(model.toMap());

    // Post to family activity feed
    await _firestore.collection('family_updates').add({
      'circleId': appointment.circleId,
      'title': 'New Appointment Scheduled',
      'message': 'Appointment with ${appointment.doctorName} at ${appointment.clinicOrHospital}.',
      'authorName': 'Care Circle',
      'timestamp': Timestamp.now(),
      'type': 'appointment',
    });
  }

  @override
  Future<void> updateAppointment(AppointmentEntity appointment) async {
    await _firestore
        .collection('appointments')
        .doc(appointment.id)
        .update((appointment as AppointmentModel).toMap());
  }

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).delete();
  }

  @override
  Future<void> markAppointmentCompleted(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'isCompleted': true,
    });
  }

  @override
  Future<void> setFollowUpReminder({
    required String appointmentId,
    required DateTime followUpDate,
  }) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'followUpDate': Timestamp.fromDate(followUpDate),
      'reminderToBookUpcoming': true,
    });
  }
}