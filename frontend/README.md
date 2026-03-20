# TaskFlow — Web Frontend

Responsive web application built with Next.js App Router and TypeScript. Connects to the TaskFlow backend API.

## Stack

- **Framework** — Next.js 16 with App Router
- **Language** — TypeScript
- **Styling** — Tailwind CSS
- **HTTP** — Axios with request/response interceptors
- **Server state** — TanStack React Query
- **Client state** — Zustand with localStorage persistence
- **Forms** — React Hook Form + Zod validation
- **Notifications** — react-hot-toast

## Setup
```bash
npm install
```

Create `.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:5000
```
```bash
npm run dev
# Runs on http://localhost:3000
```

## Pages

- `/auth/login` — Login page
- `/auth/register` — Registration page
- `/dashboard` — Main task dashboard (protected)

## Key Details

- Access token stored in Zustand, persisted to localStorage
- Axios interceptor automatically refreshes expired access tokens and retries the original request
- React Query caches task data and refetches on mutation
- Dashboard supports filtering by status, filtering by priority, and searching by title
- All CRUD operations show toast notifications on success or failure
- Fully responsive — works on mobile and desktop screens
