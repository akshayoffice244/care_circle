import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/circle_bloc.dart';
import '../bloc/circle_event.dart';
import '../bloc/circle_state.dart';

class CircleSetupScreen extends StatefulWidget {
  const CircleSetupScreen({super.key});

  @override
  State<CircleSetupScreen> createState() => _CircleSetupScreenState();
}

class _CircleSetupScreenState extends State<CircleSetupScreen> {
  final _createNameController = TextEditingController();
  final _joinCodeController = TextEditingController();

  void _showCreateDialog(String userId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Create a Care Circle'),
        content: TextField(
          controller: _createNameController,
          decoration: const InputDecoration(
            labelText: 'Circle Name',
            hintText: "e.g., Mom's Care Circle",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_createNameController.text.trim().isNotEmpty) {
                context.read<CircleBloc>().add(
                  CreateCircleRequestedEvent(
                    name: _createNameController.text.trim(),
                    adminUserId: userId,
                  ),
                );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(String userId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Join with Code'),
        content: TextField(
          controller: _joinCodeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: '6-Character Invite Code',
            hintText: 'e.g., AB12CD',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_joinCodeController.text.trim().isNotEmpty) {
                context.read<CircleBloc>().add(
                  JoinCircleRequestedEvent(
                    inviteCode: _joinCodeController.text.trim(),
                    userId: userId,
                  ),
                );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _createNameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthenticatedState ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Circle Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(SignOutRequestedEvent()),
          )
        ],
      ),
      body: BlocListener<CircleBloc, CircleState>(
        listener: (context, state) {
          if (state is CircleFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          } else if (state is CircleLoadedState) {
            // Circle joined or created! Refresh auth state
            context.read<AuthBloc>().add(CheckAuthStatusEvent());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.groups_outlined, size: 70, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Join or Create a Care Circle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'To coordinate care, connect with your family by creating a new care group or entering an existing invite code.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              // Option 1: Create
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create New Circle'),
                onPressed: user != null ? () => _showCreateDialog(user.id) : null,
              ),
              const SizedBox(height: 16),

              // Option 2: Join
              OutlinedButton.icon(
                icon: const Icon(Icons.login_rounded),
                label: const Text('Join Existing Circle with Code'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: user != null ? () => _showJoinDialog(user.id) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}