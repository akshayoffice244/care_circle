import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/medication_entity.dart';
import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';
import '../bloc/medication_state.dart';
import 'add_medication_screen.dart';
import 'medication_history_screen.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});

  void _recordIntake(
      BuildContext context,
      MedicationEntity med,
      String status,
      String scheduledTime,
      ) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      context.read<MedicationBloc>().add(
        RecordMedicationIntakeEvent(
          medication: med,
          status: status,
          scheduledTime: scheduledTime,
          userId: authState.user.id,
          userName: authState.user.displayName,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${med.name} marked as $status!'),
          backgroundColor: status == 'Taken' ? AppColors.success : AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final circleId = authState is AuthenticatedState ? authState.user.activeCircleId ?? '' : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [

          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Medication History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedicationHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MedicationBloc, MedicationState>(
        builder: (context, state) {
          if (state is MedicationLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MedicationLoadedState) {
            if (state.medications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.medication_liquid_outlined, size: 70, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      const Text(
                        'No medications scheduled',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add medicines to keep track of daily doses and notify your family.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Medication'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.medications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final med = state.medications[index];
                return _medicationCard(context, med);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Med', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
          );
        },
      ),
    );
  }

  Widget _medicationCard(BuildContext context, MedicationEntity med) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: med.isTakenToday ? AppColors.success.withValues(alpha: 0.5) : AppColors.cardBorder,
          width: med.isTakenToday ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: med.isTakenToday ? AppColors.primaryLight : const Color(0xFFF1F5F9),
                child: Icon(
                  Icons.medication,
                  color: med.isTakenToday ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${med.dosage} ${med.instructions.isNotEmpty ? "• ${med.instructions}" : ""}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (med.isTakenToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Taken',
                        style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                tooltip: 'Delete Medication',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Delete Medication'),
                      content: Text('Delete ${med.name}? All scheduled alarms will be cancelled.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () {
                            context.read<MedicationBloc>().add(
                                  DeleteMedicationEvent(
                                    medicationId: med.id,
                                    medicationName: med.name,
                                    scheduleTimesCount: med.scheduleTimes.length,
                                  ),
                                );
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${med.name} deleted')),
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
          const SizedBox(height: 14),

          // Timings Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: med.scheduleTimes.map((time) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }).toList(),
          ),

          const Divider(height: 24),

          // Action Buttons: Mark Taken / Skip
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _recordIntake(
                  context,
                  med,
                  'Skipped',
                  med.scheduleTimes.isNotEmpty ? med.scheduleTimes.first : 'Today',
                ),
                child: const Text('Skip Dose', style: TextStyle(color: AppColors.textMuted)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: med.isTakenToday ? AppColors.success : AppColors.primary,
                  minimumSize: const Size(120, 40),
                ),
                icon: Icon(med.isTakenToday ? Icons.done_all : Icons.check, size: 18),
                label: Text(med.isTakenToday ? 'Completed' : 'Mark Taken'),
                onPressed: () => _recordIntake(
                  context,
                  med,
                  'Taken',
                  med.scheduleTimes.isNotEmpty ? med.scheduleTimes.first : 'Today',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}