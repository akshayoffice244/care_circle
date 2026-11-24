import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_colors.dart';
import '../features/appointment/presentation/bloc/appointment_bloc.dart';
import '../features/appointment/presentation/bloc/appointment_event.dart';
import '../features/appointment/presentation/screens/appointment_list_screen.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/circle/presentation/screens/family_members_screen.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_event.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/medication/presentation/bloc/medication_bloc.dart';
import '../features/medication/presentation/bloc/medication_event.dart';
import '../features/medication/presentation/screens/medication_list_screen.dart';
import '../features/task/presentation/bloc/task_bloc.dart';
import '../features/task/presentation/bloc/task_event.dart';
import '../features/task/presentation/screens/task_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAllCircleData();
  }

  void _loadAllCircleData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      final circleId = authState.user.activeCircleId;
      if (circleId != null && circleId.isNotEmpty) {
        context.read<MedicationBloc>().add(LoadMedicationsEvent(circleId));
        context.read<AppointmentBloc>().add(LoadAppointmentsEvent(circleId));
        context.read<TaskBloc>().add(LoadTasksEvent(circleId));
        context.read<DashboardBloc>().add(
              LoadDashboardUpdatesEvent(
                circleId,
                currentUserName: authState.user.displayName,
              ),
            );
      }
    }
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    MedicationListScreen(),
    AppointmentListScreen(),
    TaskListScreen(),
    FamilyMembersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication, color: AppColors.primary),
            label: 'Meds',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
            label: 'Visits',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle, color: AppColors.primary),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppColors.primary),
            label: 'Family',
          ),
        ],
      ),
    );
  }
}