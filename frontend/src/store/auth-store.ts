import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { AuthState, User } from '@/types';
import { apiClient } from '@/lib/api';

interface AuthStore extends Omit<AuthState, 'refreshToken'> {
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, name: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<void>;
  setUser: (user: User | null) => void;
  setTokens: (token: string, refreshToken: string) => void;
  clearAuth: () => void;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      refreshToken: null,
      isLoading: false,
      isAuthenticated: false,

      login: async (email: string, password: string) => {
        set({ isLoading: true });
        try {
          const response = await apiClient.login(email, password);
          if (response.success && response.data) {
            const { user, token, refreshToken } = response.data;
            set({
              user,
              token,
              refreshToken,
              isAuthenticated: true,
              isLoading: false,
            });
          } else {
            throw new Error(response.error || 'Login failed');
          }
        } catch (error) {
          set({ isLoading: false });
          throw error;
        }
      },

      register: async (email: string, password: string, name: string) => {
        set({ isLoading: true });
        try {
          const response = await apiClient.register(email, password, name);
          if (response.success && response.data) {
            const { user, token, refreshToken } = response.data;
            set({
              user,
              token,
              refreshToken,
              isAuthenticated: true,
              isLoading: false,
            });
          } else {
            throw new Error(response.error || 'Registration failed');
          }
        } catch (error) {
          set({ isLoading: false });
          throw error;
        }
      },

      logout: async () => {
        try {
          await apiClient.logout();
        } catch (error) {
          // Continue with logout even if API call fails
          console.error('Logout API call failed:', error);
        } finally {
          set({
            user: null,
            token: null,
            refreshToken: null,
            isAuthenticated: false,
            isLoading: false,
          });
        }
      },

      refreshToken: async () => {
        const { refreshToken } = get();
        if (!refreshToken) {
          throw new Error('No refresh token available');
        }

        try {
          const response = await apiClient.refreshToken(refreshToken);
          if (response.success && response.data) {
            const { token, refreshToken: newRefreshToken } = response.data;
            set({
              token,
              refreshToken: newRefreshToken,
            });
          } else {
            throw new Error('Token refresh failed');
          }
        } catch (error) {
          // Clear auth state on refresh failure
          set({
            user: null,
            token: null,
            refreshToken: null,
            isAuthenticated: false,
          });
          throw error;
        }
      },

      setUser: (user: User | null) => {
        set({ user });
      },

      setTokens: (token: string, refreshToken: string) => {
        set({ token, refreshToken, isAuthenticated: true });
      },

      clearAuth: () => {
        set({
          user: null,
          token: null,
          refreshToken: null,
          isAuthenticated: false,
        });
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        refreshToken: state.refreshToken,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
