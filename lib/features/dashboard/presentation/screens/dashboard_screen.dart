import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../appointment/presentation/bloc/appointment_bloc.dart';
import '../../../appointment/presentation/bloc/appointment_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../circle/presentation/bloc/circle_bloc.dart';
import '../../../circle/presentation/bloc/circle_state.dart';
import '../../../medication/presentation/bloc/medication_bloc.dart';
import '../../../medication/presentation/bloc/medication_state.dart';
import '../../../task/presentation/bloc/task_bloc.dart';
import '../../../task/presentation/bloc/task_state.dart';
import '../../domain/entities/family_update_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddNoteDialog(BuildContext context, String circleId, String authorName) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Post Family Note'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g. Grandma had a good afternoon walk and rested well.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.trim().isNotEmpty) {
                final update = FamilyUpdateEntity(
                  id: '',
                  circleId: circleId,
                  title: 'Family Note',
                  message: noteController.text.trim(),
                  authorName: authorName,
                  timestamp: DateTime.now(),
                  type: 'note',
                );
                context.read<DashboardBloc>().add(PostFamilyNoteEvent(update));
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final circleState = context.watch<CircleBloc>().state;
    final userName = authState is AuthenticatedState ? authState.user.displayName : 'Family';
    final circleName = circleState is CircleLoadedState ? circleState.circle.name : 'Care Circle';
    final circleId = authState is AuthenticatedState ? authState.user.activeCircleId ?? '' : '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(circleName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Welcome, $userName', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add_rounded, color: AppColors.primary),
            tooltip: 'Post Family Note',
            onPressed: () => _showAddNoteDialog(context, circleId, userName),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (circleId.isNotEmpty) {
            context.read<DashboardBloc>().add(
                  LoadDashboardUpdatesEvent(
                    circleId,
                    currentUserName: userName,
                  ),
                );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Daily Care Summary Cards
              const Text(
                "Today's Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildOverviewCards(context),
              const SizedBox(height: 24),

              // 2. Real-time Activity Feed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Family Activity Feed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Note'),
                    onPressed: () => _showAddNoteDialog(context, circleId, userName),
                  )
                ],
              ),
              const SizedBox(height: 8),
              _buildActivityFeed(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    final medState = context.watch<MedicationBloc>().state;
    final taskState = context.watch<TaskBloc>().state;
    final apptState = context.watch<AppointmentBloc>().state;

    // Med stats
    int totalMeds = 0;
    int takenMeds = 0;
    if (medState is MedicationLoadedState) {
      totalMeds = medState.medications.length;
      takenMeds = medState.medications.where((m) => m.isTakenToday).length;
    }

    // Task stats
    int pendingTasks = 0;
    if (taskState is TaskLoadedState) {
      pendingTasks = taskState.tasks.where((t) => !t.isCompleted).length;
    }

    // Appointment stats
    int upcomingAppts = 0;
    if (apptState is AppointmentLoadedState) {
      upcomingAppts = apptState.appointments.where((a) => !a.isCompleted).length;
    }

    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Meds Taken',
            value: '$takenMeds/$totalMeds',
            icon: Icons.medication,
            color: AppColors.primary,
            bgColor: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            title: 'Pending Tasks',
            value: '$pendingTasks',
            icon: Icons.check_circle_outline,
            color: AppColors.warning,
            bgColor: AppColors.accentLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            title: 'Visits',
            value: '$upcomingAppts',
            icon: Icons.calendar_today,
            color: AppColors.info,
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: bgColor,
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoadingState) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is DashboardLoadedState) {
          if (state.updates.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Column(
                children: [
                  Icon(Icons.notes, size: 40, color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text('No updates yet.', style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 4),
                  Text(
                    'Activities like taking medicine, completing tasks, or notes will show here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.updates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final update = state.updates[index];
              return _activityTile(update);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _activityTile(FamilyUpdateEntity update) {
    IconData icon;
    Color iconColor;

    switch (update.type) {
      case 'medication':
        icon = Icons.medication;
        iconColor = AppColors.primary;
        break;
      case 'appointment':
        icon = Icons.calendar_today;
        iconColor = AppColors.info;
        break;
      case 'task':
        if (update.title.contains('Pending') || update.title.contains('Reminder')) {
          icon = Icons.warning_amber_rounded;
          iconColor = AppColors.warning;
        } else {
          icon = Icons.check_circle;
          iconColor = AppColors.success;
        }
        break;
      default:
        icon = Icons.chat_bubble_outline;
        iconColor = AppColors.accent;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconColor.withValues(alpha: 0.1),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      update.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(update.timestamp),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  update.message,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'By ${update.authorName}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}