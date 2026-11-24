import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleTask(BuildContext context, TaskEntity task) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      context.read<TaskBloc>().add(
        ToggleTaskCompletionEvent(
          taskId: task.id,
          isCompleted: !task.isCompleted,
          userId: authState.user.id,
          userName: authState.user.displayName,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthenticatedState ? authState.user.id : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Care Tasks'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All Tasks'),
            Tab(text: 'Assigned to Me'),
          ],
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskLoadedState) {
            if (state.tasks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 70, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      const Text(
                        'No care tasks yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create daily responsibilities like vitals check, physical therapy, or meals.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Daily Task'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            final myTasks = state.tasks.where((t) => t.assignedToUserId == currentUserId).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(context, state.tasks),
                _buildTaskList(context, myTasks, emptyMessage: 'No tasks currently assigned to you!'),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<TaskEntity> tasks, {String? emptyMessage}) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          emptyMessage ?? 'No tasks found.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pending.isNotEmpty) ...[
          Text(
            'Pending Tasks (${pending.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          ...pending.map((task) => _taskTile(context, task)),
          const SizedBox(height: 16),
        ],
        if (completed.isNotEmpty) ...[
          Text(
            'Completed (${completed.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ...completed.map((task) => _taskTile(context, task)),
        ],
      ],
    );
  }

  Widget _taskTile(BuildContext context, TaskEntity task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Checkbox + Title + Action Buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: task.isCompleted,
                  activeColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (_) => _toggleTask(context, task),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (!task.isCompleted)
                IconButton(
                  icon: const Icon(Icons.campaign_rounded,
                      color: AppColors.accent, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Notify Family (Pending Task)',
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    final senderName = authState is AuthenticatedState
                        ? authState.user.displayName
                        : 'Family Member';

                    context.read<TaskBloc>().add(
                          NotifyPendingTaskEvent(
                            task: task,
                            senderName: senderName,
                          ),
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notified family circle about pending task "${task.title}"!',
                        ),
                        backgroundColor: AppColors.accent,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                visualDensity: VisualDensity.compact,
                tooltip: 'Delete Task',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Delete Task'),
                      content: Text('Delete task "${task.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error),
                          onPressed: () {
                            context
                                .read<TaskBloc>()
                                .add(DeleteTaskEvent(task.id));
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Task "${task.title}" deleted')),
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

          // Description (Indented)
          if (task.description.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 34, top: 4, bottom: 6),
              child: Text(
                task.description,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],

          const SizedBox(height: 6),

          // Bottom Row: Assignee Badge + Due Date (Spans full card width)
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Assignee Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        task.assignedToName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                // Due Date
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('MMM d, h:mm a').format(task.dueDate)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  }
