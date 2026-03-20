# TaskFlow — Backend API

REST API built with Node.js, TypeScript, Express, and Prisma ORM. Uses SQLite for the database.

## Stack

- **Runtime** — Node.js with TypeScript
- **Framework** — Express
- **Database** — SQLite via Prisma ORM
- **Auth** — JWT (access + refresh tokens), bcrypt password hashing
- **Validation** — express-validator
- **Security** — helmet, cors, express-rate-limit

## Setup
```bash
npm install
```

Create a `.env` file:
```env
DATABASE_URL="file:./prisma/dev.db"
JWT_ACCESS_SECRET=your_access_secret_here
JWT_REFRESH_SECRET=your_refresh_secret_here
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
PORT=5000
CLIENT_URL=http://localhost:3000
NODE_ENV=development
```
```bash
npx prisma db push
npx prisma generate
npm run dev
```

## API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /auth/register | Register a new user |
| POST | /auth/login | Login and receive tokens |
| POST | /auth/refresh | Get new access token using refresh token |
| POST | /auth/logout | Invalidate refresh token |
| GET | /auth/me | Get current logged in user |

### Tasks (all protected)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /tasks | List tasks — supports ?page, ?limit, ?status, ?priority, ?search |
| POST | /tasks | Create a new task |
| GET | /tasks/:id | Get a single task |
| PATCH | /tasks/:id | Update a task |
| DELETE | /tasks/:id | Delete a task |
| PATCH | /tasks/:id/toggle | Cycle task status: PENDING → IN_PROGRESS → COMPLETED |

## Data Models

**User** — id, name, email, passwordHash, createdAt, updatedAt

**Task** — id, title, description, status (PENDING/IN_PROGRESS/COMPLETED), priority (LOW/MEDIUM/HIGH), dueDate, userId, createdAt, updatedAt

**RefreshToken** — id, token, userId, expiresAt
