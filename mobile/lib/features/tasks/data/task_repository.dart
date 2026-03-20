import '../../../core/network/api_client.dart';
import 'task_models.dart';

class TaskRepository {
  final ApiClient _client;
  TaskRepository(this._client);

  Future<TasksResponse> getTasks({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    final response = await _client.dio.get('/tasks', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return TasksResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Task> createTask({
    required String title,
    String? description,
    String status = 'PENDING',
    String priority = 'MEDIUM',
    DateTime? dueDate,
  }) async {
    final response = await _client.dio.post('/tasks', data: {
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'status': status,
      'priority': priority,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    });
    return Task.fromJson((response.data as Map<String, dynamic>)['task'] as Map<String, dynamic>);
  }

  Future<Task> updateTask(
    String id, {
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) async {
    final response = await _client.dio.patch('/tasks/$id', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    });
    return Task.fromJson((response.data as Map<String, dynamic>)['task'] as Map<String, dynamic>);
  }

  Future<void> deleteTask(String id) async {
    await _client.dio.delete('/tasks/$id');
  }

  Future<Task> toggleTask(String id) async {
    final response = await _client.dio.patch('/tasks/$id/toggle');
    return Task.fromJson((response.data as Map<String, dynamic>)['task'] as Map<String, dynamic>);
  }
}
