export interface User {
  id: string;
  email: string;
  name: string;
  role: 'user' | 'admin';
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}

export interface AuthState {
  user: User | null;
  token: string | null;
  refreshToken: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
}

export interface Message {
  id: string;
  content: string;
  role: 'user' | 'assistant';
  conversationId: string;
  userId: string;
  createdAt: string;
  metadata?: {
    model?: string;
    tokens?: number;
    cost?: number;
  };
}

export interface Conversation {
  id: string;
  title: string;
  userId: string;
  createdAt: string;
  updatedAt: string;
  messages: Message[];
  metadata?: {
    totalTokens?: number;
    totalCost?: number;
  };
}

export interface PromptTemplate {
  id: string;
  name: string;
  description: string;
  content: string;
  category: string;
  isPublic: boolean;
  userId: string;
  createdAt: string;
  updatedAt: string;
  tags: string[];
}

export interface ChatState {
  conversations: Conversation[];
  currentConversation: Conversation | null;
  messages: Message[];
  isLoading: boolean;
  isTyping: boolean;
  error: string | null;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  name: string;
}

export interface ChatRequest {
  message: string;
  conversationId?: string;
  model?: string;
  temperature?: number;
  maxTokens?: number;
}

export interface ChatResponse {
  message: Message;
  conversation: Conversation;
}

export interface FileUpload {
  id: string;
  name: string;
  size: number;
  type: string;
  url: string;
  uploadedAt: string;
  userId: string;
}

export interface Settings {
  theme: 'light' | 'dark' | 'system';
  language: string;
  notifications: boolean;
  autoSave: boolean;
  model: string;
  temperature: number;
  maxTokens: number;
}

export interface Metrics {
  totalConversations: number;
  totalMessages: number;
  totalTokens: number;
  totalCost: number;
  activeUsers: number;
  averageResponseTime: number;
  errorRate: number;
}

export interface HealthCheck {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  services: {
    database: 'healthy' | 'unhealthy';
    ai: 'healthy' | 'unhealthy';
    storage: 'healthy' | 'unhealthy';
  };
}
