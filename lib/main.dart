import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

// Repositories
import 'features/appointment/data/repositories/appointment_repository_impl.dart';
import 'features/appointment/domain/repositories/appointment_repository.dart';
import 'features/appointment/domain/usecases/add_appointment_usecase.dart';
import 'features/appointment/domain/usecases/delete_appointment_usecase.dart';
import 'features/appointment/domain/usecases/mark_appointment_completed_usecase.dart';
import 'features/appointment/domain/usecases/set_follow_up_usecase.dart';
import 'features/appointment/domain/usecases/stream_appointments_usecase.dart';
import 'features/appointment/presentation/bloc/appointment_bloc.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

import 'features/circle/data/repositories/circle_repository_impl.dart';
import 'features/circle/domain/repositories/circle_repository.dart';
import 'features/circle/domain/usecases/create_circle_usecase.dart';
import 'features/circle/domain/usecases/get_circle_members_usecase.dart';
import 'features/circle/domain/usecases/join_circle_usecase.dart';
import 'features/circle/domain/usecases/stream_circle_usecase.dart';
import 'features/circle/presentation/bloc/circle_bloc.dart';

import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/post_family_update_usecase.dart';
import 'features/dashboard/domain/usecases/stream_family_updates_usecase.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'features/medication/data/repositories/medication_repository_impl.dart';
import 'features/medication/domain/repositories/medication_repository.dart';
import 'features/medication/domain/usecases/add_medication_usecase.dart';
import 'features/medication/domain/usecases/delete_medication_usecase.dart';
import 'features/medication/domain/usecases/record_medication_intake_usecase.dart';
import 'features/medication/domain/usecases/stream_medication_logs_usecase.dart';
import 'features/medication/domain/usecases/stream_medications_usecase.dart';
import 'features/medication/presentation/bloc/medication_bloc.dart';

import 'features/task/data/repositories/task_repository_impl.dart';
import 'features/task/domain/repositories/task_repository.dart';
import 'features/task/domain/usecases/add_task_usecase.dart';
import 'features/task/domain/usecases/delete_task_usecase.dart';
import 'features/task/domain/usecases/notify_pending_task_usecase.dart';
import 'features/task/domain/usecases/stream_tasks_usecase.dart';
import 'features/task/domain/usecases/toggle_task_completion_usecase.dart';
import 'features/task/presentation/bloc/task_bloc.dart';

// Presentation Root
import 'presentation/app_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Notifications
  await NotificationService().init();

  runApp(const CareCircleApp());
}

class CareCircleApp extends StatelessWidget {
  const CareCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Provide Repositories
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<CircleRepository>(
          create: (_) => CircleRepositoryImpl(),
        ),
        RepositoryProvider<MedicationRepository>(
          create: (_) => MedicationRepositoryImpl(),
        ),
        RepositoryProvider<AppointmentRepository>(
          create: (_) => AppointmentRepositoryImpl(),
        ),
        RepositoryProvider<TaskRepository>(
          create: (_) => TaskRepositoryImpl(),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (_) => DashboardRepositoryImpl(),
        ),
      ],
      // 2. Provide BLoCs
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              getCurrentUserUseCase:
              GetCurrentUserUseCase(context.read<AuthRepository>()),
              signInUseCase: SignInUseCase(context.read<AuthRepository>()),
              signUpUseCase: SignUpUseCase(context.read<AuthRepository>()),
              signOutUseCase: SignOutUseCase(context.read<AuthRepository>()),
            )..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<CircleBloc>(
            create: (context) => CircleBloc(
              createCircleUseCase:
              CreateCircleUseCase(context.read<CircleRepository>()),
              joinCircleUseCase:
              JoinCircleUseCase(context.read<CircleRepository>()),
              streamCircleUseCase:
              StreamCircleUseCase(context.read<CircleRepository>()),
              getCircleMembersUseCase:
              GetCircleMembersUseCase(context.read<CircleRepository>()),
            ),
          ),
          BlocProvider<MedicationBloc>(
            create: (context) => MedicationBloc(
              streamMedicationsUseCase: StreamMedicationsUseCase(
                  context.read<MedicationRepository>()),
              addMedicationUseCase:
              AddMedicationUseCase(context.read<MedicationRepository>()),
              recordMedicationIntakeUseCase: RecordMedicationIntakeUseCase(
                  context.read<MedicationRepository>()),
              streamMedicationLogsUseCase: StreamMedicationLogsUseCase(
                  context.read<MedicationRepository>()),
              deleteMedicationUseCase: DeleteMedicationUseCase(
                  context.read<MedicationRepository>()),
            ),
          ),
          BlocProvider<AppointmentBloc>(
            create: (context) => AppointmentBloc(
              streamAppointmentsUseCase: StreamAppointmentsUseCase(
                  context.read<AppointmentRepository>()),
              addAppointmentUseCase:
              AddAppointmentUseCase(context.read<AppointmentRepository>()),
              markAppointmentCompletedUseCase: MarkAppointmentCompletedUseCase(
                  context.read<AppointmentRepository>()),
              setFollowUpUseCase:
              SetFollowUpUseCase(context.read<AppointmentRepository>()),
              deleteAppointmentUseCase: DeleteAppointmentUseCase(
                  context.read<AppointmentRepository>()),
            ),
          ),
          BlocProvider<TaskBloc>(
            create: (context) => TaskBloc(
              streamTasksUseCase:
              StreamTasksUseCase(context.read<TaskRepository>()),
              addTaskUseCase:
              AddTaskUseCase(context.read<TaskRepository>()),
              toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase(
                  context.read<TaskRepository>()),
              deleteTaskUseCase: DeleteTaskUseCase(
                  context.read<TaskRepository>()),
              notifyPendingTaskUseCase: NotifyPendingTaskUseCase(
                  context.read<TaskRepository>()),
            ),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              streamFamilyUpdatesUseCase: StreamFamilyUpdatesUseCase(
                  context.read<DashboardRepository>()),
              postFamilyUpdateUseCase: PostFamilyUpdateUseCase(
                  context.read<DashboardRepository>()),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Care Circle',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AppRoot(),
        ),
      ),
    );
  }
}