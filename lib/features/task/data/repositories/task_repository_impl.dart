import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<TaskEntity>> streamTasks(String circleId) {
    return _firestore
        .collection('tasks')
        .where('circleId', isEqualTo: circleId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TaskModel.fromSnapshot(doc)).toList());
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final docRef = _firestore.collection('tasks').doc();
    final model = TaskModel(
      id: docRef.id,
      circleId: task.circleId,
      title: task.title,
      description: task.description,
      assignedToUserId: task.assignedToUserId,
      assignedToName: task.assignedToName,
      dueDate: task.dueDate,
      isCompleted: false,
    );
    await docRef.set(model.toMap());

    // Post to family updates feed
    await _firestore.collection('family_updates').add({
      'circleId': task.circleId,
      'title': 'New Task Assigned',
      'message': 'Task "${task.title}" assigned to ${task.assignedToName}.',
      'authorName': 'Care Circle',
      'timestamp': Timestamp.now(),
      'type': 'task',
    });
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await _firestore
        .collection('tasks')
        .doc(task.id)
        .update((task as TaskModel).toMap());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  @override
  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
    required String userId,
    required String userName,
  }) async {
    final now = DateTime.now();
    final taskDoc = await _firestore.collection('tasks').doc(taskId).get();
    final taskTitle = taskDoc.data()?['title'] ?? 'daily care task';
    final circleId = taskDoc.data()?['circleId'] ?? '';

    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? Timestamp.fromDate(now) : null,
      'completedByName': isCompleted ? userName : null,
    });

    if (isCompleted && circleId.isNotEmpty) {
      await _firestore.collection('family_updates').add({
        'circleId': circleId,
        'title': 'Task Completed ✅',
        'message': '$userName completed "$taskTitle"!',
        'authorName': userName,
        'timestamp': Timestamp.fromDate(now),
        'type': 'task',
      });
    }
  }

  @override
  Future<void> notifyFamilyAboutPendingTask({
    required TaskEntity task,
    required String senderName,
  }) async {
    final now = DateTime.now();
    await _firestore.collection('family_updates').add({
      'circleId': task.circleId,
      'title': 'Pending Task Reminder ⚠️',
      'message': '$senderName reminded that "${task.title}" is pending for ${task.assignedToName}!',
      'authorName': senderName,
      'timestamp': Timestamp.fromDate(now),
      'type': 'task',
    });
  }
}