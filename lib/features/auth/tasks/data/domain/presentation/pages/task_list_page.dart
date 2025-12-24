import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/search_bar.dart';
import 'add_task_bottom_sheet.dart';
import '../../../../../../../main.dart';

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
    final themeMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      body: Column(
        children: [
          // 1. Purple Header Section
          _buildPurpleHeader(context, ref, themeMode),

          // 2. Search Bar Section
          const TaskSearchBar(),

          // 3. The Dynamic List Section
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text("No tasks found",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  );
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

  Widget _buildPurpleHeader(
      BuildContext context, WidgetRef ref, ThemeMode currentTheme) {
    final isDark = currentTheme == ThemeMode.dark;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.grid_view_rounded, color: Colors.white),
              Row(
                children: [
                  // THEME TOGGLE BUTTON
                  IconButton(
                    onPressed: () {
                      ref.read(themeNotifierProvider.notifier).state =
                          isDark ? ThemeMode.light : ThemeMode.dark;
                    },
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                    ),
                  ),
                  // LOGOUT BUTTON
                  IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                  ),
                ],
              ),
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
