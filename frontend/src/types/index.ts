export type TaskStatus = 'PENDING' | 'IN_PROGRESS' | 'COMPLETED';
export type Priority = 'LOW' | 'MEDIUM' | 'HIGH';

export interface Task {
  id: string;
  title: string;
  description?: string;
  status: TaskStatus;
  priority: Priority;
  dueDate?: string;
  userId: string;
  createdAt: string;
  updatedAt: string;
}

export interface Pagination {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface TasksResponse {
  tasks: Task[];
  pagination: Pagination;
}

export interface User {
  id: string;
  name: string;
  email: string;
}
