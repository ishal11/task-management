import { Router } from 'express';
import { body, query } from 'express-validator';
import { validate } from '../middleware/validate';
import { authenticate } from '../middleware/auth';
import { getTasks, getTask, createTask, updateTask, deleteTask, toggleTask } from '../controllers/task.controller';

const router = Router();

router.use(authenticate);

router.get(
  '/',
  [
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 50 }),
    query('status').optional().isIn(['PENDING', 'IN_PROGRESS', 'COMPLETED']),
    query('priority').optional().isIn(['LOW', 'MEDIUM', 'HIGH']),
    validate,
  ],
  getTasks
);

router.post(
  '/',
  [
    body('title').trim().notEmpty().withMessage('Title is required'),
    body('description').optional().trim(),
    body('status').optional().isIn(['PENDING', 'IN_PROGRESS', 'COMPLETED']),
    body('priority').optional().isIn(['LOW', 'MEDIUM', 'HIGH']),
    body('dueDate').optional().isISO8601().withMessage('Invalid date format'),
    validate,
  ],
  createTask
);

router.get('/:id', getTask);
router.patch(
  '/:id',
  [
    body('title').optional().trim().notEmpty(),
    body('status').optional().isIn(['PENDING', 'IN_PROGRESS', 'COMPLETED']),
    body('priority').optional().isIn(['LOW', 'MEDIUM', 'HIGH']),
    body('dueDate').optional().isISO8601(),
    validate,
  ],
  updateTask
);
router.delete('/:id', deleteTask);
router.patch('/:id/toggle', toggleTask);

export default router;
