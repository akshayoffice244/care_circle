import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _setReminder = true;
  bool _reminderToBookUpcoming = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      final circleId = authState is AuthenticatedState ? authState.user.activeCircleId ?? '' : '';

      final fullDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final appointment = AppointmentEntity(
        id: '',
        circleId: circleId,
        doctorName: _doctorController.text.trim(),
        clinicOrHospital: _locationController.text.trim(),
        appointmentDateTime: fullDateTime,
        notes: _notesController.text.trim(),
        reminderToBookUpcoming: _reminderToBookUpcoming,
      );

      // Save to Firebase
      context.read<AppointmentBloc>().add(AddAppointmentEvent(appointment));

      // Trigger notification alert & schedule appointment alarm
      if (_setReminder) {
        // 1. Instant confirmation
        NotificationService().showNotification(
          id: appointment.doctorName.hashCode,
          title: 'Doctor Appointment Scheduled 🩺',
          body: 'Visit with ${appointment.doctorName} on ${DateFormat("MMM d, h:mm a").format(fullDateTime)}',
        );

        // 2. Scheduled alarm for the actual date & time of the visit!
        NotificationService().scheduleAppointmentReminder(
          id: appointment.doctorName.hashCode,
          doctorName: appointment.doctorName,
          clinic: appointment.clinicOrHospital,
          appointmentDateTime: fullDateTime,
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Doctor Visit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name & Specialty',
                  hintText: 'e.g. Dr. Sarah Adams (Cardiologist)',
                  prefixIcon: Icon(Icons.person_pin_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter doctor name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Clinic / Hospital Location',
                  hintText: 'e.g. City Care Hospital, Room 302',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter clinic location' : null,
              ),
              const SizedBox(height: 16),

              // Date & Time Selectors
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                      onPressed: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(_selectedTime.format(context)),
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Preparation / Notes (Optional)',
                  hintText: 'e.g. Fast for 8 hours, bring recent blood test reports',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Switch 1: Notification Reminder
              SwitchListTile(
                title: const Text('Set Appointment Reminder'),
                subtitle: const Text('Notify the family before the visit'),
                value: _setReminder,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _setReminder = val),
              ),

              // Switch 2: Reminder to Book Follow-up
              SwitchListTile(
                title: const Text('Add Upcoming Booking Reminder'),
                subtitle: const Text('Flag circle to book follow-up checkups'),
                value: _reminderToBookUpcoming,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _reminderToBookUpcoming = val),
              ),

              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _onSave,
                child: const Text('Confirm Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}