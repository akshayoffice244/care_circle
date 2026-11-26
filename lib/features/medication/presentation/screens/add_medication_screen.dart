import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/medication_entity.dart';
import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  final List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (!_selectedTimes.contains(picked)) {
          _selectedTimes.add(picked);
        }
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate() && _selectedTimes.isNotEmpty) {
      final authState = context.read<AuthBloc>().state;
      final circleId = authState is AuthenticatedState ? authState.user.activeCircleId ?? '' : '';

      final formattedTimes = _selectedTimes.map((t) => t.format(context)).toList();

      final medication = MedicationEntity(
        id: '',
        circleId: circleId,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        instructions: _instructionsController.text.trim(),
        scheduleTimes: formattedTimes,
      );

      // Save to Firebase via BLoC (MedicationBloc automatically handles scheduling for the circle)
      context.read<MedicationBloc>().add(AddMedicationEvent(medication));

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  hintText: 'e.g. Metformin, Amlodipine',
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter medicine name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g. 500mg, 1 tablet, 5ml syrup',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter dosage' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions (Optional)',
                  hintText: 'e.g. After breakfast, with a glass of water',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 24),

              // Timings Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Timings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add_alarm),
                    label: const Text('Add Time'),
                    onPressed: _pickTime,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedTimes.map((time) {
                  return Chip(
                    backgroundColor: AppColors.primaryLight,
                    label: Text(time.format(context), style: const TextStyle(color: AppColors.primaryDark)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: _selectedTimes.length > 1
                        ? () {
                      setState(() {
                        _selectedTimes.remove(time);
                      });
                    }
                        : null,
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _onSave,
                child: const Text('Save & Set Reminders'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}