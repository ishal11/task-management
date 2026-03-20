import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { taskApi, TaskFilters, TaskPayload } from '@/lib/api/tasks';
import toast from 'react-hot-toast';

export const useTasks = (filters: TaskFilters) =>
  useQuery({
    queryKey: ['tasks', filters],
    queryFn: () => taskApi.getAll(filters),
  });

export const useCreateTask = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: TaskPayload) => taskApi.create(data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['tasks'] }); toast.success('Task created'); },
    onError: () => toast.error('Failed to create task'),
  });
};

export const useUpdateTask = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<TaskPayload> }) => taskApi.update(id, data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['tasks'] }); toast.success('Task updated'); },
    onError: () => toast.error('Failed to update task'),
  });
};

export const useDeleteTask = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => taskApi.delete(id),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['tasks'] }); toast.success('Task deleted'); },
    onError: () => toast.error('Failed to delete task'),
  });
};

export const useToggleTask = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => taskApi.toggle(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['tasks'] }),
    onError: () => toast.error('Failed to update task status'),
  });
};
