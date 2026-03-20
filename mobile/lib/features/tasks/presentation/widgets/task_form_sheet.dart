import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/task_models.dart';
import '../providers/task_provider.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  final Task? task;
  const TaskFormSheet({super.key, this.task});

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _status;
  late String _priority;
  DateTime? _dueDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? 'PENDING';
    _priority = widget.task?.priority ?? 'MEDIUM';
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    bool ok;
    if (widget.task != null) {
      ok = await ref.read(taskProvider.notifier).updateTask(
            widget.task!.id,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            status: _status,
            priority: _priority,
            dueDate: _dueDate,
          );
    } else {
      ok = await ref.read(taskProvider.notifier).createTask(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            status: _status,
            priority: _priority,
            dueDate: _dueDate,
          );
    }

    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.task != null ? 'Task updated' : 'Task created'),
          backgroundColor: const Color(0xFF4ADE80).withOpacity(0.9),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save task'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.task != null ? 'Edit task' : 'New task',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Status', _status, ['PENDING', 'IN_PROGRESS', 'COMPLETED'],
                      (v) => setState(() => _status = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown('Priority', _priority, ['LOW', 'MEDIUM', 'HIGH'],
                      (v) => setState(() => _priority = v!))),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        _dueDate != null
                            ? DateFormat('MMM d, yyyy').format(_dueDate!)
                            : 'Due date (optional)',
                        style: TextStyle(
                          color: _dueDate != null ? Colors.white : const Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.task != null ? 'Save changes' : 'Create task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: const Color(0xFF1E293B),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o.replaceAll('_', ' ')))).toList(),
      onChanged: onChanged,
    );
  }
}
