import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/circle/presentation/bloc/circle_bloc.dart';
import '../features/circle/presentation/bloc/circle_event.dart';
import '../features/circle/presentation/screens/circle_setup_screen.dart';
import 'main_navigation_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          final circleId = state.user.activeCircleId;
          if (circleId != null && circleId.isNotEmpty) {
            context.read<CircleBloc>().add(LoadCircleEvent(circleId));
          }
        }
      },
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthenticatedState) {
          final circleId = state.user.activeCircleId;
          if (circleId == null || circleId.isEmpty) {
            return const CircleSetupScreen();
          }
          return const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}