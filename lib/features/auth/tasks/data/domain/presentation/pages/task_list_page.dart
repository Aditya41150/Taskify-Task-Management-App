import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/search_bar.dart'; // Ensure your Search Bar widget is imported
import 'add_task_bottom_sheet.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  bool isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  String getHeader(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return "Today";
    if (isSameDay(date, now.add(const Duration(days: 1)))) return "Tomorrow";
    return DateFormat('EEEE, d MMM').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);

    return Scaffold(
      body: Column(
        children: [
          // 1. Purple Header Section (Title + Icons) [cite: 2025-12-19]
          _buildPurpleHeader(context),

          // 2. Search Bar Section [cite: 2025-12-19]
          const TaskSearchBar(),

          // 3. The Dynamic List Section [cite: 2025-12-19]
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(child: Text("No tasks found"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final bool showHeader = index == 0 ||
                        !isSameDay(tasks[index - 1].dueDate, task.dueDate);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                            child: Text(
                              getHeader(task.dueDate),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7E72F2)),
                            ),
                          ),
                        TaskTile(task: task),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const AddTaskBottomSheet(),
        ),
        backgroundColor: const Color(0xFF7E72F2),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPurpleHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 25),
      decoration: const BoxDecoration(
        color: Color(0xFF7E72F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.grid_view_rounded, color: Colors.white),
              Icon(Icons.person_outline, color: Colors.white),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            "My Tasks",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
