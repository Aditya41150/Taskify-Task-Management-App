import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/features/auth/tasks/data/domain/entities/task.dart';
import 'package:task_management/features/auth/tasks/data/domain/presentation/providers/task_provider.dart';
import '../pages/add_task_bottom_sheet.dart';

class TaskTile extends ConsumerWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: UniqueKey(), // Essential for smooth list updates on Moto G84
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // RIGHT SWIPE: Open Update Sheet
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTaskBottomSheet(taskToEdit: task),
          );
          return false; // Prevents the item from being removed
        } else {
          // LEFT SWIPE: Allow Delete
          return true;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          ref.read(taskRepositoryProvider).deleteTask(task.id);
        }
      },
      // Background for Right Swipe (Edit)
      background: _buildSwipeBg(
        icon: Icons.edit,
        color: Colors.blueAccent,
        alignment: Alignment.centerLeft,
      ),
      // Background for Left Swipe (Delete)
      secondaryBackground: _buildSwipeBg(
        icon: Icons.delete,
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: IconButton(
            icon: Icon(
              task.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: const Color(0xFF7E72F2),
              size: 28,
            ),
            onPressed: () => ref
                .read(taskRepositoryProvider)
                .toggleTaskStatus(task.id, !task.isCompleted),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? Colors.grey
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          // RESTORES THE PRIORITY TAGS
          trailing: _buildPriorityTag(task.priority),
        ),
      ),
    );
  }

  // Helper to build the priority chips on the main screen
  Widget _buildPriorityTag(Priority p) {
    Color color = p == Priority.high
        ? Colors.orange
        : (p == Priority.medium ? Colors.blue : Colors.green);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        p.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper to build the swipe backgrounds
  Widget _buildSwipeBg(
      {required IconData icon,
      required Color color,
      required Alignment alignment}) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
