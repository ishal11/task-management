import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/task_models.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (task.status) {
      case 'COMPLETED': return const Color(0xFF4ADE80);
      case 'IN_PROGRESS': return const Color(0xFF60A5FA);
      default: return const Color(0xFF94A3B8);
    }
  }

  Color _priorityColor() {
    switch (task.priority) {
      case 'HIGH': return const Color(0xFFF87171);
      case 'LOW': return const Color(0xFF94A3B8);
      default: return const Color(0xFFFBBF24);
    }
  }

  IconData _statusIcon() {
    switch (task.status) {
      case 'COMPLETED': return Icons.check_circle_rounded;
      case 'IN_PROGRESS': return Icons.timelapse_rounded;
      default: return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Icon(_statusIcon(), color: _statusColor(), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: task.status == 'COMPLETED'
                          ? const Color(0xFF64748B)
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: task.status == 'COMPLETED'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _Chip(label: task.priority, color: _priorityColor()),
                      _Chip(label: task.status.replaceAll('_', ' '), color: _statusColor()),
                      if (task.dueDate != null)
                        _Chip(
                          label: DateFormat('MMM d, yyyy').format(task.dueDate!),
                          color: const Color(0xFF94A3B8),
                          icon: Icons.calendar_today,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF64748B)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
