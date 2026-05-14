import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { ApiResponse } from '@/types';

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001',
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor to add auth token
    this.client.interceptors.request.use(
      (config) => {
        const token = this.getToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor to handle token refresh
    this.client.interceptors.response.use(
      (response) => response,
      async (error) => {
        const originalRequest = error.config;

        if (error.response?.status === 401 && !originalRequest._retry) {
          originalRequest._retry = true;

          try {
            const refreshToken = this.getRefreshToken();
            if (refreshToken) {
              const response = await this.refreshToken(refreshToken);
              this.setToken(response.data.token);
              this.setRefreshToken(response.data.refreshToken);
              
              // Retry the original request
              originalRequest.headers.Authorization = `Bearer ${response.data.token}`;
              return this.client(originalRequest);
            }
          } catch (refreshError) {
            // Refresh failed, redirect to login
            this.clearTokens();
            window.location.href = '/login';
            return Promise.reject(refreshError);
          }
        }

        return Promise.reject(error);
      }
    );
  }

  private getToken(): string | null {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('token');
    }
    return null;
  }

  private getRefreshToken(): string | null {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('refreshToken');
    }
    return null;
  }

  private setToken(token: string): void {
    if (typeof window !== 'undefined') {
      localStorage.setItem('token', token);
    }
  }

  private setRefreshToken(refreshToken: string): void {
    if (typeof window !== 'undefined') {
      localStorage.setItem('refreshToken', refreshToken);
    }
  }

  private clearTokens(): void {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('token');
      localStorage.removeItem('refreshToken');
    }
  }

  private async refreshToken(refreshToken: string): Promise<AxiosResponse> {
    return this.client.post('/auth/refresh', { refreshToken });
  }

  // Auth endpoints
  async login(email: string, password: string): Promise<ApiResponse> {
    const response = await this.client.post('/auth/login', { email, password });
    return response.data;
  }

  async register(email: string, password: string, name: string): Promise<ApiResponse> {
    const response = await this.client.post('/auth/register', { email, password, name });
    return response.data;
  }

  async logout(): Promise<ApiResponse> {
    const response = await this.client.post('/auth/logout');
    this.clearTokens();
    return response.data;
  }

  async getCurrentUser(): Promise<ApiResponse> {
    const response = await this.client.get('/auth/me');
    return response.data;
  }

  // Chat endpoints
  async sendMessage(message: string, conversationId?: string): Promise<ApiResponse> {
    const response = await this.client.post('/chat/message', { message, conversationId });
    return response.data;
  }

  async getConversations(): Promise<ApiResponse> {
    const response = await this.client.get('/chat/conversations');
    return response.data;
  }

  async getConversation(id: string): Promise<ApiResponse> {
    const response = await this.client.get(`/chat/conversations/${id}`);
    return response.data;
  }

  async deleteConversation(id: string): Promise<ApiResponse> {
    const response = await this.client.delete(`/chat/conversations/${id}`);
    return response.data;
  }

  async updateConversationTitle(id: string, title: string): Promise<ApiResponse> {
    const response = await this.client.patch(`/chat/conversations/${id}`, { title });
    return response.data;
  }

  // Prompt endpoints
  async getPrompts(): Promise<ApiResponse> {
    const response = await this.client.get('/prompts');
    return response.data;
  }

  async createPrompt(prompt: any): Promise<ApiResponse> {
    const response = await this.client.post('/prompts', prompt);
    return response.data;
  }

  async updatePrompt(id: string, prompt: any): Promise<ApiResponse> {
    const response = await this.client.put(`/prompts/${id}`, prompt);
    return response.data;
  }

  async deletePrompt(id: string): Promise<ApiResponse> {
    const response = await this.client.delete(`/prompts/${id}`);
    return response.data;
  }

  // File upload endpoints
  async uploadFile(file: File): Promise<ApiResponse> {
    const formData = new FormData();
    formData.append('file', file);

    const response = await this.client.post('/files/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  }

  async getFiles(): Promise<ApiResponse> {
    const response = await this.client.get('/files');
    return response.data;
  }

  async deleteFile(id: string): Promise<ApiResponse> {
    const response = await this.client.delete(`/files/${id}`);
    return response.data;
  }

  // Metrics endpoints
  async getMetrics(): Promise<ApiResponse> {
    const response = await this.client.get('/metrics');
    return response.data;
  }

  // Health check
  async healthCheck(): Promise<ApiResponse> {
    const response = await this.client.get('/health');
    return response.data;
  }
}

export const apiClient = new ApiClient();
