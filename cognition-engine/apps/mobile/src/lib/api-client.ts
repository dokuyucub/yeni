/**
 * API client with auth support.
 *
 * Provides typed HTTP requests to the FastAPI backend.
 * Automatically injects auth headers and handles token refresh.
 */

import type { HealthResponse, ApiError, UserMeResponse } from '@cognition-engine/shared';
import { env } from '@/config/env';
import { getAccessToken, refreshSession } from './supabase';

/**
 * Generate a unique request ID for tracing.
 */
function generateRequestId(): string {
  return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
}

/**
 * Custom error class for API errors.
 */
export class ApiRequestError extends Error {
  public readonly statusCode: number;
  public readonly requestId?: string;
  public readonly code?: string;

  constructor(message: string, statusCode: number, requestId?: string, code?: string) {
    super(message);
    this.name = 'ApiRequestError';
    this.statusCode = statusCode;
    this.requestId = requestId;
    this.code = code;
  }
}

/**
 * Request options for API calls.
 */
interface RequestOptions extends Omit<RequestInit, 'body'> {
  body?: unknown;
  requiresAuth?: boolean;
  retry401?: boolean;
}

/**
 * API client class.
 */
class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl.replace(/\/$/, ''); // Remove trailing slash
  }

  /**
   * Make an HTTP request to the API.
   */
  private async request<T>(
    endpoint: string,
    options: RequestOptions = {}
  ): Promise<T> {
    const {
      body,
      requiresAuth = false,
      retry401 = true,
      ...fetchOptions
    } = options;

    const url = `${this.baseUrl}${endpoint}`;
    const requestId = generateRequestId();

    // Build headers
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      'X-Request-Id': requestId,
      ...fetchOptions.headers,
    };

    // Add auth header if required
    if (requiresAuth) {
      const accessToken = await getAccessToken();
      if (accessToken) {
        (headers as Record<string, string>)['Authorization'] = `Bearer ${accessToken}`;
      }
    }

    // Make the request
    const response = await fetch(url, {
      ...fetchOptions,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    // Handle 401 with token refresh
    if (response.status === 401 && requiresAuth && retry401) {
      console.log('Received 401, attempting token refresh...');
      const { session, error } = await refreshSession();

      if (!error && session) {
        // Retry the request with new token
        return this.request<T>(endpoint, {
          ...options,
          retry401: false, // Don't retry again
          headers: {
            ...headers,
            Authorization: `Bearer ${session.access_token}`,
          },
        });
      }

      // Refresh failed, throw auth error
      throw new ApiRequestError(
        'Session expired. Please sign in again.',
        401,
        requestId,
        'SESSION_EXPIRED'
      );
    }

    // Handle other errors
    if (!response.ok) {
      let errorData: ApiError | null = null;
      try {
        errorData = await response.json();
      } catch {
        // Response is not JSON
      }

      throw new ApiRequestError(
        errorData?.message ?? response.statusText ?? 'Request failed',
        response.status,
        requestId,
        errorData?.error
      );
    }

    // Parse response
    return response.json();
  }

  /**
   * GET request.
   */
  async get<T>(endpoint: string, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'GET' });
  }

  /**
   * POST request.
   */
  async post<T>(endpoint: string, body?: unknown, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'POST', body });
  }

  /**
   * PUT request.
   */
  async put<T>(endpoint: string, body?: unknown, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'PUT', body });
  }

  /**
   * PATCH request.
   */
  async patch<T>(endpoint: string, body?: unknown, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'PATCH', body });
  }

  /**
   * DELETE request.
   */
  async delete<T>(endpoint: string, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'DELETE' });
  }

  // ============================================================
  // API Endpoints
  // ============================================================

  /**
   * Health check (public endpoint).
   */
  async health(): Promise<HealthResponse> {
    return this.get<HealthResponse>('/health');
  }

  /**
   * Get current user info (protected endpoint).
   */
  async me(): Promise<UserMeResponse> {
    return this.get<UserMeResponse>('/users/me', { requiresAuth: true });
  }
}

/**
 * Singleton API client instance.
 */
export const apiClient = new ApiClient(env.EXPO_PUBLIC_API_URL);
