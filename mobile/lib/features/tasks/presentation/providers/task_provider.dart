import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/task_models.dart';
import '../../data/task_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(apiClientProvider)),
);

class TaskFilters {
  final String? status;
  final String search;
  final int page;

  const TaskFilters({this.status, this.search = '', this.page = 1});

  TaskFilters copyWith({String? status, String? search, int? page, bool clearStatus = false}) =>
      TaskFilters(
        status: clearStatus ? null : (status ?? this.status),
        search: search ?? this.search,
        page: page ?? this.page,
      );
}

class TaskState {
  final List<Task> tasks;
  final Pagination? pagination;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final TaskFilters filters;

  const TaskState({
    this.tasks = const [],
    this.pagination,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.filters = const TaskFilters(),
  });

  TaskState copyWith({
    List<Task>? tasks,
    Pagination? pagination,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    TaskFilters? filters,
  }) =>
      TaskState(
        tasks: tasks ?? this.tasks,
        pagination: pagination ?? this.pagination,
        isLoading: isLoading ?? this.isLoading,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        error: error,
        filters: filters ?? this.filters,
      );
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repo;

  TaskNotifier(this._repo) : super(const TaskState());

  Future<void> loadTasks({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isRefreshing: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _repo.getTasks(
        page: state.filters.page,
        status: state.filters.status,
        search: state.filters.search,
      );
      state = state.copyWith(
        tasks: result.tasks,
        pagination: result.pagination,
        isLoading: false,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'Failed to load tasks',
      );
    }
  }

  Future<bool> createTask({
    required String title,
    String? description,
    String status = 'PENDING',
    String priority = 'MEDIUM',
    DateTime? dueDate,
  }) async {
    try {
      await _repo.createTask(
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
      );
      await loadTasks(refresh: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateTask(
    String id, {
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) async {
    try {
      await _repo.updateTask(id,
          title: title,
          description: description,
          status: status,
          priority: priority,
          dueDate: dueDate);
      await loadTasks(refresh: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _repo.deleteTask(id);
      await loadTasks(refresh: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleTask(String id) async {
    try {
      await _repo.toggleTask(id);
      await loadTasks(refresh: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  void setFilter({String? status, String? search, bool clearStatus = false}) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        status: status,
        search: search,
        page: 1,
        clearStatus: clearStatus,
      ),
    );
    loadTasks();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) => TaskNotifier(ref.watch(taskRepositoryProvider)),
);
