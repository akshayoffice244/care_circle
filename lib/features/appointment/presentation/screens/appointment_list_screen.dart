import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';
import 'add_appointment_screen.dart';

class AppointmentListScreen extends StatelessWidget {
  const AppointmentListScreen({super.key});

  void _showSetFollowUpDialog(BuildContext context, AppointmentEntity appt) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((pickedDate) {
      if (pickedDate != null) {
        context.read<AppointmentBloc>().add(
          SetFollowUpReminderEvent(
            appointmentId: appt.id,
            followUpDate: pickedDate,
          ),
        );

        // Schedule follow-up alarm for 09:00 AM on that date!
        final followUpDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 9, 0);
        NotificationService().scheduleAppointmentReminder(
          id: (appt.id + '_followup').hashCode,
          doctorName: '${appt.doctorName} (Follow-up Due)',
          clinic: 'Reminder to book next appointment',
          appointmentDateTime: followUpDateTime,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Follow-up reminder set for ${DateFormat('MMM d, yyyy').format(pickedDate)}!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Appointments')),
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AppointmentLoadedState) {
            if (state.appointments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 70,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No appointments scheduled',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Keep track of doctor visits, clinical notes, and follow-up reminders.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Schedule Appointment'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddAppointmentScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            final upcoming = state.appointments
                .where((a) => !a.isCompleted)
                .toList();
            final completed = state.appointments
                .where((a) => a.isCompleted)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Upcoming Appointments
                if (upcoming.isNotEmpty) ...[
                  const Text(
                    'Upcoming Visits',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...upcoming.map(
                    (appt) => _appointmentCard(context, appt, isUpcoming: true),
                  ),
                  const SizedBox(height: 20),
                ],

                // Past / Completed Appointments
                if (completed.isNotEmpty) ...[
                  const Text(
                    'Past Appointments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...completed.map(
                    (appt) =>
                        _appointmentCard(context, appt, isUpcoming: false),
                  ),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Visit', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAppointmentScreen()),
          );
        },
      ),
    );
  }

  Widget _appointmentCard(
    BuildContext context,
    AppointmentEntity appt, {
    required bool isUpcoming,
  }) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appt.reminderToBookUpcoming
              ? AppColors.warning
              : AppColors.cardBorder,
          width: appt.reminderToBookUpcoming ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Follow-Up / Booking Reminder Banner
          if (appt.reminderToBookUpcoming && appt.followUpDate != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm_on, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Follow-up due: ${dateFormat.format(appt.followUpDate!)} — Remember to book!',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isUpcoming
                    ? const Color(0xFFEFF6FF)
                    : const Color(0xFFF1F5F9),
                child: Icon(
                  Icons.medical_services_outlined,
                  color: isUpcoming ? AppColors.info : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            appt.doctorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          tooltip: 'Delete Appointment',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogCtx) => AlertDialog(
                                title: const Text('Delete Appointment'),
                                content: Text('Delete appointment with ${appt.doctorName}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogCtx),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                    onPressed: () {
                                      context.read<AppointmentBloc>().add(
                                            DeleteAppointmentEvent(
                                              appointmentId: appt.id,
                                              doctorName: appt.doctorName,
                                            ),
                                          );
                                      Navigator.pop(dialogCtx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Appointment with ${appt.doctorName} deleted')),
                                      );
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            appt.clinicOrHospital,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dateFormat.format(appt.appointmentDateTime)} at ${timeFormat.format(appt.appointmentDateTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (appt.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Note: ${appt.notes}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (isUpcoming) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month, size: 16),
                  label: const Text(
                    'Set Follow-up',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _showSetFollowUpDialog(context, appt),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(100, 36),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text(
                    'Mark Done',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    context.read<AppointmentBloc>().add(
                      MarkAppointmentCompletedEvent(appt.id),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
