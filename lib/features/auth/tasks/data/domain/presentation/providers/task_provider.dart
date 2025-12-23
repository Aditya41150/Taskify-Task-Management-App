import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/features/auth/tasks/data/domain/entities/task.dart';
import 'package:task_management/features/auth/tasks/data/repositories/task_repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

final taskRepositoryProvider =
    Provider<TaskRepositoryImpl>((ref) => TaskRepositoryImpl());
final taskStreamProvider = StreamProvider<List<Task>>(
    (ref) => ref.watch(taskRepositoryProvider).getTasks());
final searchProvider = StateProvider<String>((ref) => "");

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(taskStreamProvider);
  final searchQuery = ref.watch(searchProvider).toLowerCase();

  return tasksAsync.whenData((tasks) {
    // 1. Filter [cite: 2025-12-19]
    final filtered = tasks
        .where((t) => t.title.toLowerCase().contains(searchQuery))
        .toList();

    // 2. Sort by Date, Completion, then Priority [cite: 2025-12-19]
    filtered.sort((a, b) {
      int dateComp = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day)
          .compareTo(DateTime(b.dueDate.year, b.dueDate.month, b.dueDate.day));
      if (dateComp != 0) return dateComp;
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return a.priority.index.compareTo(b.priority.index);
    });
    return filtered;
  });
});
