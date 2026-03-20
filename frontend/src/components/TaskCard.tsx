'use client';

import { Task } from '@/types';
import { useDeleteTask, useToggleTask } from '@/hooks/useTasks';
import { format } from 'date-fns';
import { Trash2, Pencil, Calendar, Circle, CheckCircle2, Timer } from 'lucide-react';

const statusConfig = {
  PENDING: { label: 'Pending', icon: Circle, color: 'text-gray-400', bg: 'bg-gray-800' },
  IN_PROGRESS: { label: 'In Progress', icon: Timer, color: 'text-blue-400', bg: 'bg-blue-950' },
  COMPLETED: { label: 'Completed', icon: CheckCircle2, color: 'text-green-400', bg: 'bg-green-950' },
};

const priorityConfig = {
  LOW: { label: 'Low', color: 'text-slate-400 bg-slate-800' },
  MEDIUM: { label: 'Medium', color: 'text-amber-400 bg-amber-950' },
  HIGH: { label: 'High', color: 'text-red-400 bg-red-950' },
};

interface Props {
  task: Task;
  onEdit: (task: Task) => void;
}

export default function TaskCard({ task, onEdit }: Props) {
  const deleteMutation = useDeleteTask();
  const toggleMutation = useToggleTask();

  const status = statusConfig[task.status];
  const priority = priorityConfig[task.priority];
  const StatusIcon = status.icon;

  return (
    <div className="bg-gray-900 border border-gray-800 rounded-xl p-4 hover:border-gray-700 transition-colors group">
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-start gap-3 flex-1 min-w-0">
          <button
            onClick={() => toggleMutation.mutate(task.id)}
            className={`mt-0.5 shrink-0 ${status.color} hover:opacity-70 transition-opacity`}
          >
            <StatusIcon className="w-5 h-5" />
          </button>
          <div className="flex-1 min-w-0">
            <p className={`text-sm font-medium truncate ${task.status === 'COMPLETED' ? 'line-through text-gray-500' : 'text-white'}`}>
              {task.title}
            </p>
            {task.description && (
              <p className="text-xs text-gray-500 mt-1 line-clamp-2">{task.description}</p>
            )}
            <div className="flex items-center gap-2 mt-2 flex-wrap">
              <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${priority.color}`}>
                {priority.label}
              </span>
              <span className={`text-xs px-2 py-0.5 rounded-full ${status.bg} ${status.color}`}>
                {status.label}
              </span>
              {task.dueDate && (
                <span className="flex items-center gap-1 text-xs text-gray-500">
                  <Calendar className="w-3 h-3" />
                  {format(new Date(task.dueDate), 'MMM d, yyyy')}
                </span>
              )}
            </div>
          </div>
        </div>
        <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity shrink-0">
          <button
            onClick={() => onEdit(task)}
            className="p-1.5 text-gray-500 hover:text-white hover:bg-gray-800 rounded-lg transition-colors"
          >
            <Pencil className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={() => deleteMutation.mutate(task.id)}
            disabled={deleteMutation.isPending}
            className="p-1.5 text-gray-500 hover:text-red-400 hover:bg-red-950 rounded-lg transition-colors"
          >
            <Trash2 className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>
    </div>
  );
}
