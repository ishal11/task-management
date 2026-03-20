# TaskFlow — Task Management System

Full-stack task management app built with Node.js, Next.js, and Flutter.

## Structure
```
task-management/
├── backend/    # Node.js + TypeScript + Express + Prisma + SQLite
├── frontend/   # Next.js + TypeScript + Tailwind
└── mobile/     # Flutter (Android)
```

## Setup

### Backend
```bash
cd backend
npm install
# create .env with these values:
# DATABASE_URL="file:./prisma/dev.db"
# JWT_ACCESS_SECRET=your_secret_here
# JWT_REFRESH_SECRET=your_refresh_secret_here
# JWT_ACCESS_EXPIRES_IN=15m
# JWT_REFRESH_EXPIRES_IN=7d
# PORT=5000
# CLIENT_URL=http://localhost:3000
# NODE_ENV=development
npx prisma db push
npx prisma generate
npm run dev
```

### Frontend
```bash
cd frontend
npm install
# create .env.local with:
# NEXT_PUBLIC_API_URL=http://localhost:5000
npm run dev
```

### Mobile
```bash
cd mobile
flutter pub get
# Update lib/core/network/api_client.dart
# Change baseUrl to your machine's local IP:
# static const baseUrl = 'http://YOUR_IP:5000';
flutter run
```

## API Endpoints

### Auth
- POST /auth/register
- POST /auth/login
- POST /auth/refresh
- POST /auth/logout

### Tasks
- GET /tasks — list with pagination, filter, search
- POST /tasks — create
- GET /tasks/:id
- PATCH /tasks/:id — update
- DELETE /tasks/:id
- PATCH /tasks/:id/toggle — cycle status
