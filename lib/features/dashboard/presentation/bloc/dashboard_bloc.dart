import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/post_family_update_usecase.dart';
import '../../domain/usecases/stream_family_updates_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final StreamFamilyUpdatesUseCase streamFamilyUpdatesUseCase;
  final PostFamilyUpdateUseCase postFamilyUpdateUseCase;

  StreamSubscription? _updatesSubscription;
  String? _currentUserName;
  bool _hasInitialLoaded = false;
  DateTime? _lastAlertTimestamp;

  DashboardBloc({
    required this.streamFamilyUpdatesUseCase,
    required this.postFamilyUpdateUseCase,
  }) : super(DashboardInitialState()) {
    on<LoadDashboardUpdatesEvent>(_onLoadUpdates);
    on<DashboardUpdatesUpdatedEvent>(_onUpdatesUpdated);
    on<PostFamilyNoteEvent>(_onPostFamilyNote);
  }

  void _onLoadUpdates(
      LoadDashboardUpdatesEvent event, Emitter<DashboardState> emit) {
    emit(DashboardLoadingState());
    _currentUserName = event.currentUserName;
    _hasInitialLoaded = false;
    _updatesSubscription?.cancel();
    _updatesSubscription =
        streamFamilyUpdatesUseCase(event.circleId).listen((updates) {
          add(DashboardUpdatesUpdatedEvent(updates));
        });
  }

  Future<void> _onUpdatesUpdated(
      DashboardUpdatesUpdatedEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoadedState(event.updates));

    // Prevent alerting for historical messages when the app first opens
    if (!_hasInitialLoaded) {
      _hasInitialLoaded = true;
      if (event.updates.isNotEmpty) {
        _lastAlertTimestamp = event.updates.first.timestamp;
      }
      return;
    }

    // When a new update arrives in real-time from another family member
    if (event.updates.isNotEmpty) {
      final latest = event.updates.first;

      if (_lastAlertTimestamp == null || latest.timestamp.isAfter(_lastAlertTimestamp!)) {
        _lastAlertTimestamp = latest.timestamp;

        final isAuthoredByMe = _currentUserName != null &&
            _currentUserName!.trim().isNotEmpty &&
            latest.authorName.trim().toLowerCase() == _currentUserName!.trim().toLowerCase();

        // Ring and vibrate ONLY on the other family members' phones!
        if (!isAuthoredByMe) {
          await NotificationService().showNotification(
            id: latest.id.hashCode,
            title: latest.title,
            body: latest.message,
          );
        }
      }
    }
  }

  Future<void> _onPostFamilyNote(
      PostFamilyNoteEvent event, Emitter<DashboardState> emit) async {
    try {
      await postFamilyUpdateUseCase(event.update);
    } catch (e) {
      emit(DashboardErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _updatesSubscription?.cancel();
    return super.close();
  }
}