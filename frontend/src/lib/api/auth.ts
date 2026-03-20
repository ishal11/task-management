import api from '@/lib/axios';
import { User } from '@/types';

export const authApi = {
  register: (data: { name: string; email: string; password: string }) =>
    api.post<{ user: User; accessToken: string; refreshToken: string }>('/auth/register', data).then((r) => r.data),

  login: (data: { email: string; password: string }) =>
    api.post<{ user: User; accessToken: string; refreshToken: string }>('/auth/login', data).then((r) => r.data),

  logout: (refreshToken: string) =>
    api.post('/auth/logout', { refreshToken }),

  me: () =>
    api.get<{ user: User }>('/auth/me').then((r) => r.data.user),
};
