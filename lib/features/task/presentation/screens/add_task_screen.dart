import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../circle/domain/entities/circle_member_entity.dart';
import '../../../circle/presentation/bloc/circle_bloc.dart';
import '../../../circle/presentation/bloc/circle_state.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  CircleMemberEntity? _selectedAssignee;

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
    if (_formKey.currentState!.validate() && _selectedAssignee != null) {
      final authState = context.read<AuthBloc>().state;
      final circleId = authState is AuthenticatedState ? authState.user.activeCircleId ?? '' : '';

      final fullDueDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final task = TaskEntity(
        id: '',
        circleId: circleId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedToUserId: _selectedAssignee!.userId,
        assignedToName: _selectedAssignee!.displayName,
        dueDate: fullDueDate,
      );

      // Save to Firebase (TaskBloc automatically schedules the single alarm for the circle)
      context.read<TaskBloc>().add(AddTaskEvent(task));

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleState = context.watch<CircleBloc>().state;
    final members = circleState is CircleLoadedState ? circleState.members : <CircleMemberEntity>[];

    // Pre-select first member if not set
    if (_selectedAssignee == null && members.isNotEmpty) {
      _selectedAssignee = members.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Daily Care Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g. Check Blood Pressure, 15 min Walk, Change Dressing',
                  prefixIcon: Icon(Icons.task_alt),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter task title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Instructions / Notes (Optional)',
                  hintText: 'e.g. Target systolic below 130 mmHg. Note down in journal.',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 20),

              // Assignee Dropdown
              const Text(
                'Assign To Family Member',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CircleMemberEntity>(
                isExpanded: true,
                value: _selectedAssignee,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: members.map((member) {
                  return DropdownMenuItem<CircleMemberEntity>(
                    value: member,
                    child: Text(
                      '${member.displayName} (${member.role})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedAssignee = val),
                validator: (val) => val == null ? 'Please assign to a member' : null,
              ),
              const SizedBox(height: 20),

              // Due Date & Time
              const Text(
                'Due Date & Time',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: _onSave,
                child: const Text('Assign Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}