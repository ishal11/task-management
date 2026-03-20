class Task {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final String userId;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.userId,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: json['status'] as String,
        priority: json['priority'] as String,
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
        userId: json['userId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class TasksResponse {
  final List<Task> tasks;
  final Pagination pagination;

  const TasksResponse({required this.tasks, required this.pagination});

  factory TasksResponse.fromJson(Map<String, dynamic> json) => TasksResponse(
        tasks: (json['tasks'] as List).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList(),
        pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      );
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json['total'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        totalPages: json['totalPages'] as int,
      );
}
