# TaskFlow — Task Management System

A full-stack task management application where users can register, log in, and manage their personal tasks. Built as a software engineering assessment covering a REST API backend, a web frontend, and a mobile app.

## Project Structure
```
task-management/
├── backend/    # REST API — Node.js, TypeScript, Express, Prisma, SQLite
├── frontend/   # Web app — Next.js, TypeScript, Tailwind CSS
└── mobile/     # Android app — Flutter, Riverpod, Dio
```

## Quick Start

### 1. Backend (required first)
```bash
cd backend
npm install
# Copy .env.example to .env and fill in values
npx prisma db push
npx prisma generate
npm run dev
# Runs on http://localhost:5000
```

### 2. Frontend
```bash
cd frontend
npm install
# Create .env.local with NEXT_PUBLIC_API_URL=http://localhost:5000
npm run dev
# Runs on http://localhost:3000
```

### 3. Mobile
```bash
cd mobile
flutter pub get
# Update lib/core/network/api_client.dart with your machine's local IP
flutter run
```

## Features

- JWT authentication with access and refresh tokens
- Password hashing with bcrypt
- Full task CRUD — create, view, edit, delete, toggle status
- Task filtering by status and priority, search by title
- Pagination on all task list endpoints
- Responsive web UI
- Native Android app with secure token storage
- Automatic token refresh on expiry
