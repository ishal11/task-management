import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(taskProvider.notifier).loadTasks());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openForm({task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskFormSheet(task: task),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete task', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure?', style: TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await ref.read(taskProvider.notifier).deleteTask(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Task deleted' : 'Failed to delete'),
          backgroundColor: ok ? const Color(0xFF4ADE80).withOpacity(0.9) : Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout, size: 18, color: Color(0xFF94A3B8)),
              label: Text(user?.name.split(' ').first ?? '',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF64748B)),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    ref.read(taskProvider.notifier).setFilter(search: '');
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (v) => ref.read(taskProvider.notifier).setFilter(search: v),
                        onChanged: (v) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => ref.read(taskProvider.notifier).setFilter(search: _searchCtrl.text),
                      icon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1).withOpacity(0.15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [null, 'PENDING', 'IN_PROGRESS', 'COMPLETED'].map((s) {
                      final isSelected = _selectedStatus == s;
                      final label = s == null ? 'All' : s.replaceAll('_', ' ');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(label, style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                          )),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedStatus = s);
                            ref.read(taskProvider.notifier).setFilter(
                              status: s,
                              clearStatus: s == null,
                            );
                          },
                          backgroundColor: const Color(0xFF0F172A),
                          selectedColor: const Color(0xFF6366F1),
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF334155),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(taskProvider.notifier).loadTasks(refresh: true),
              color: const Color(0xFF6366F1),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                  : state.error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Color(0xFF94A3B8), size: 48),
                              const SizedBox(height: 12),
                              Text(state.error!, style: const TextStyle(color: Color(0xFF94A3B8))),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => ref.read(taskProvider.notifier).loadTasks(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : state.tasks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_box_outlined,
                                      color: Color(0xFF334155), size: 64),
                                  const SizedBox(height: 16),
                                  const Text('No tasks yet',
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => _openForm(),
                                    child: const Text('Create your first task'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.tasks.length,
                              itemBuilder: (_, i) {
                                final task = state.tasks[i];
                                return TaskCard(
                                  task: task,
                                  onToggle: () async {
                                    await ref.read(taskProvider.notifier).toggleTask(task.id);
                                  },
                                  onEdit: () => _openForm(task: task),
                                  onDelete: () => _confirmDelete(task.id),
                                );
                              },
                            ),
            ),
          ),
          if (state.pagination != null && state.pagination!.totalPages > 1)
            Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${state.pagination!.page} of ${state.pagination!.totalPages}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: state.pagination!.page > 1
                            ? () {
                                ref.read(taskProvider.notifier).state =
                                    ref.read(taskProvider).copyWith(
                                          filters: ref.read(taskProvider).filters.copyWith(
                                                page: state.pagination!.page - 1,
                                              ),
                                        );
                                ref.read(taskProvider.notifier).loadTasks();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left, color: Color(0xFF94A3B8)),
                      ),
                      IconButton(
                        onPressed: state.pagination!.page < state.pagination!.totalPages
                            ? () {
                                ref.read(taskProvider.notifier).state =
                                    ref.read(taskProvider).copyWith(
                                          filters: ref.read(taskProvider).filters.copyWith(
                                                page: state.pagination!.page + 1,
                                              ),
                                        );
                                ref.read(taskProvider.notifier).loadTasks();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
