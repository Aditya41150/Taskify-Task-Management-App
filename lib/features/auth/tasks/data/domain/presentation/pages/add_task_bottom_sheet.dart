import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml
import 'package:task_management/features/auth/tasks/data/domain/entities/task.dart';
import 'package:task_management/features/auth/tasks/data/models/task_model.dart';
import 'package:task_management/features/auth/tasks/data/domain/presentation/providers/task_provider.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  final Task? taskToEdit;
  const AddTaskBottomSheet({super.key, this.taskToEdit});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  late TextEditingController _titleController;
  late Priority _selectedPriority;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.taskToEdit?.title ?? "");
    _selectedPriority = widget.taskToEdit?.priority ?? Priority.low;
    _selectedDate = widget.taskToEdit?.dueDate ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (_titleController.text.isEmpty) return;
    final taskData = TaskModel(
      id: widget.taskToEdit?.id ?? '',
      title: _titleController.text,
      dueDate: _selectedDate,
      priority: _selectedPriority,
      isCompleted: widget.taskToEdit?.isCompleted ?? false,
    );

    if (widget.taskToEdit != null) {
      ref
          .read(taskRepositoryProvider)
          .updateTask(widget.taskToEdit!.id, taskData);
    } else {
      ref.read(taskRepositoryProvider).addTask(taskData);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
                hintText: "Task Name", border: InputBorder.none),
            autofocus: true,
          ),
          const SizedBox(height: 20),
          // --- Priority Chips ---
          const Text("Priority", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: Priority.values
                .map((p) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(p.name.toUpperCase()),
                        selected: _selectedPriority == p,
                        onSelected: (_) =>
                            setState(() => _selectedPriority = p),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          // --- Date Picker Button ---
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
                "Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}"),
            onTap: _pickDate,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E72F2)),
              child: Text(
                  widget.taskToEdit == null ? "Add Task" : "Update Task",
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
