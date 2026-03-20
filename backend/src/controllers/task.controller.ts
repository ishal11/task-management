import { Response } from 'express';
import prisma from '../utils/prisma';
import { AuthRequest, TaskStatus, Priority } from '../types';

export const getTasks = async (req: AuthRequest, res: Response): Promise<void> => {
  const {
    page = '1',
    limit = '10',
    status,
    search,
    priority,
    sortBy = 'createdAt',
    sortOrder = 'desc',
  } = req.query;

  const pageNum = Math.max(1, parseInt(page as string));
  const limitNum = Math.min(50, Math.max(1, parseInt(limit as string)));
  const skip = (pageNum - 1) * limitNum;

  const where: Record<string, unknown> = { userId: req.userId };

  if (status) where.status = status as TaskStatus;
  if (priority) where.priority = priority as Priority;
  if (search) where.title = { contains: search as string };

  const allowedSortFields = ['createdAt', 'updatedAt', 'dueDate', 'priority', 'title'];
  const sortField = allowedSortFields.includes(sortBy as string) ? (sortBy as string) : 'createdAt';

  const [tasks, total] = await Promise.all([
    prisma.task.findMany({
      where,
      skip,
      take: limitNum,
      orderBy: { [sortField]: sortOrder === 'asc' ? 'asc' : 'desc' },
    }),
    prisma.task.count({ where }),
  ]);

  res.json({
    tasks,
    pagination: {
      total,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(total / limitNum),
    },
  });
};

export const getTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const task = await prisma.task.findFirst({
    where: { id: req.params.id, userId: req.userId },
  });

  if (!task) {
    res.status(404).json({ message: 'Task not found' });
    return;
  }

  res.json({ task });
};

export const createTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const { title, description, status, priority, dueDate } = req.body;

  const task = await prisma.task.create({
    data: {
      title,
      description,
      status: status || 'PENDING',
      priority: priority || 'MEDIUM',
      dueDate: dueDate ? new Date(dueDate) : null,
      userId: req.userId as string,
    },
  });

  res.status(201).json({ task });
};

export const updateTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const existing = await prisma.task.findFirst({
    where: { id: req.params.id, userId: req.userId },
  });

  if (!existing) {
    res.status(404).json({ message: 'Task not found' });
    return;
  }

  const { title, description, status, priority, dueDate } = req.body;

  const task = await prisma.task.update({
    where: { id: req.params.id },
    data: {
      ...(title !== undefined && { title }),
      ...(description !== undefined && { description }),
      ...(status !== undefined && { status }),
      ...(priority !== undefined && { priority }),
      ...(dueDate !== undefined && { dueDate: dueDate ? new Date(dueDate) : null }),
    },
  });

  res.json({ task });
};

export const deleteTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const existing = await prisma.task.findFirst({
    where: { id: req.params.id, userId: req.userId },
  });

  if (!existing) {
    res.status(404).json({ message: 'Task not found' });
    return;
  }

  await prisma.task.delete({ where: { id: req.params.id } });
  res.json({ message: 'Task deleted successfully' });
};

export const toggleTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const existing = await prisma.task.findFirst({
    where: { id: req.params.id, userId: req.userId },
  });

  if (!existing) {
    res.status(404).json({ message: 'Task not found' });
    return;
  }

  const nextStatus: Record<string, TaskStatus> = {
    PENDING: 'IN_PROGRESS',
    IN_PROGRESS: 'COMPLETED',
    COMPLETED: 'PENDING',
  };

  const task = await prisma.task.update({
    where: { id: req.params.id },
    data: { status: nextStatus[existing.status] },
  });

  res.json({ task });
};
