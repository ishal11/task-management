'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Task } from '@/types';
import { useCreateTask, useUpdateTask } from '@/hooks/useTasks';
import { X } from 'lucide-react';

const schema = z.object({
  title: z.string().min(1, 'Title is required'),
  description: z.string().optional(),
  status: z.enum(['PENDING', 'IN_PROGRESS', 'COMPLETED']),
  priority: z.enum(['LOW', 'MEDIUM', 'HIGH']),
  dueDate: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

interface Props {
  task?: Task | null;
  onClose: () => void;
}

export default function TaskModal({ task, onClose }: Props) {
  const createMutation = useCreateTask();
  const updateMutation = useUpdateTask();
  const isEdit = !!task;

  const { register, handleSubmit, reset, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { title: '', description: '', status: 'PENDING', priority: 'MEDIUM', dueDate: '' },
  });

  useEffect(() => {
    if (task) {
      reset({
        title: task.title,
        description: task.description || '',
        status: task.status,
        priority: task.priority,
        dueDate: task.dueDate ? task.dueDate.substring(0, 10) : '',
      });
    }
  }, [task, reset]);

  const onSubmit = async (data: FormData) => {
    const payload = { ...data, dueDate: data.dueDate || undefined };
    if (isEdit && task) {
      await updateMutation.mutateAsync({ id: task.id, data: payload });
    } else {
      await createMutation.mutateAsync(payload);
    }
    onClose();
  };

  const inputClass = "w-full px-3 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:border-indigo-500 placeholder-gray-500";
  const selectClass = "w-full px-3 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:border-indigo-500";

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-gray-900 border border-gray-800 rounded-2xl w-full max-w-md">
        <div className="flex items-center justify-between p-5 border-b border-gray-800">
          <h2 className="text-base font-semibold text-white">{isEdit ? 'Edit task' : 'New task'}</h2>
          <button onClick={onClose} className="text-gray-500 hover:text-white transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>
        <form onSubmit={handleSubmit(onSubmit)} className="p-5 space-y-4">
          <div>
            <label className="block text-xs text-gray-400 mb-1.5">Title *</label>
            <input {...register('title')} placeholder="Task title" className={inputClass} />
            {errors.title && <p className="text-red-400 text-xs mt-1">{errors.title.message}</p>}
          </div>
          <div>
            <label className="block text-xs text-gray-400 mb-1.5">Description</label>
            <textarea {...register('description')} placeholder="Optional description" rows={3} className={inputClass + ' resize-none'} />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs text-gray-400 mb-1.5">Status</label>
              <select {...register('status')} className={selectClass}>
                <option value="PENDING">Pending</option>
                <option value="IN_PROGRESS">In Progress</option>
                <option value="COMPLETED">Completed</option>
              </select>
            </div>
            <div>
              <label className="block text-xs text-gray-400 mb-1.5">Priority</label>
              <select {...register('priority')} className={selectClass}>
                <option value="LOW">Low</option>
                <option value="MEDIUM">Medium</option>
                <option value="HIGH">High</option>
              </select>
            </div>
          </div>
          <div>
            <label className="block text-xs text-gray-400 mb-1.5">Due date</label>
            <input type="date" {...register('dueDate')} className={selectClass} />
          </div>
          <div className="flex gap-3 pt-2">
            <button type="button" onClick={onClose} className="flex-1 py-2 border border-gray-700 text-gray-400 hover:text-white hover:border-gray-600 rounded-lg text-sm transition-colors">
              Cancel
            </button>
            <button type="submit" disabled={createMutation.isPending || updateMutation.isPending} className="flex-1 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white rounded-lg text-sm font-medium transition-colors">
              {isEdit ? 'Save changes' : 'Create task'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
