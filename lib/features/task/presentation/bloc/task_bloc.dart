import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/notify_pending_task_usecase.dart';
import '../../domain/usecases/stream_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_completion_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final StreamTasksUseCase streamTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final ToggleTaskCompletionUseCase toggleTaskCompletionUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final NotifyPendingTaskUseCase notifyPendingTaskUseCase;

  StreamSubscription? _tasksSubscription;

  TaskBloc({
    required this.streamTasksUseCase,
    required this.addTaskUseCase,
    required this.toggleTaskCompletionUseCase,
    required this.deleteTaskUseCase,
    required this.notifyPendingTaskUseCase,
  }) : super(TaskInitialState()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<TasksUpdatedEvent>(_onTasksUpdated);
    on<AddTaskEvent>(_onAddTask);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<NotifyPendingTaskEvent>(_onNotifyPendingTask);
  }

  void _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) {
    emit(TaskLoadingState());
    _tasksSubscription?.cancel();
    _tasksSubscription = streamTasksUseCase(event.circleId).listen((tasks) {
      add(TasksUpdatedEvent(tasks));
    });
  }

  Future<void> _onTasksUpdated(
      TasksUpdatedEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadedState(event.tasks));

    // Automatically sync task alarms for pending tasks on this device
    for (final task in event.tasks) {
      if (!task.isCompleted && task.dueDate.isAfter(DateTime.now())) {
        await NotificationService().scheduleTaskReminder(
          id: task.id.hashCode,
          taskTitle: task.title,
          assigneeName: task.assignedToName,
          dueDateTime: task.dueDate,
        );
      }
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await addTaskUseCase(event.task);
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
      ToggleTaskCompletionEvent event, Emitter<TaskState> emit) async {
    try {
      await toggleTaskCompletionUseCase(
        taskId: event.taskId,
        isCompleted: event.isCompleted,
        userId: event.userId,
        userName: event.userName,
      );
      if (event.isCompleted) {
        await NotificationService().cancelNotification(event.taskId.hashCode);
      }
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
      DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await deleteTaskUseCase(event.taskId);
      await NotificationService().cancelNotification(event.taskId.hashCode);
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onNotifyPendingTask(
      NotifyPendingTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await notifyPendingTaskUseCase(
        task: event.task,
        senderName: event.senderName,
      );
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}