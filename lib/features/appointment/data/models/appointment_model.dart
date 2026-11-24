import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.circleId,
    required super.doctorName,
    required super.clinicOrHospital,
    required super.appointmentDateTime,
    super.notes,
    super.isCompleted,
    super.followUpDate,
    super.reminderToBookUpcoming,
  });

  factory AppointmentModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppointmentModel(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      clinicOrHospital: data['clinicOrHospital'] ?? '',
      appointmentDateTime: (data['appointmentDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      followUpDate: (data['followUpDate'] as Timestamp?)?.toDate(),
      reminderToBookUpcoming: data['reminderToBookUpcoming'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circleId': circleId,
      'doctorName': doctorName,
      'clinicOrHospital': clinicOrHospital,
      'appointmentDateTime': Timestamp.fromDate(appointmentDateTime),
      'notes': notes,
      'isCompleted': isCompleted,
      'followUpDate': followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
      'reminderToBookUpcoming': reminderToBookUpcoming,
    };
  }
}