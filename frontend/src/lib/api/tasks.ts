import api from '@/lib/axios';
import { Task, TasksResponse } from '@/types';

export interface TaskFilters {
  page?: number;
  limit?: number;
  status?: string;
  priority?: string;
  search?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface TaskPayload {
  title: string;
  description?: string;
  status?: string;
  priority?: string;
  dueDate?: string;
}

export const taskApi = {
  getAll: (filters: TaskFilters = {}) =>
    api.get<TasksResponse>('/tasks', { params: filters }).then((r) => r.data),

  getOne: (id: string) =>
    api.get<{ task: Task }>(`/tasks/${id}`).then((r) => r.data.task),

  create: (data: TaskPayload) =>
    api.post<{ task: Task }>('/tasks', data).then((r) => r.data.task),

  update: (id: string, data: Partial<TaskPayload>) =>
    api.patch<{ task: Task }>(`/tasks/${id}`, data).then((r) => r.data.task),

  delete: (id: string) =>
    api.delete(`/tasks/${id}`).then((r) => r.data),

  toggle: (id: string) =>
    api.patch<{ task: Task }>(`/tasks/${id}/toggle`).then((r) => r.data.task),
};
