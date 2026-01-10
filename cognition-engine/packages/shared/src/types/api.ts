/**
 * API types for request/response contracts.
 * These must match the Pydantic models in the FastAPI backend.
 */

/**
 * Health check response from /health endpoint.
 */
export interface HealthResponse {
  status: 'healthy' | 'degraded' | 'unhealthy';
  version: string;
  timestamp: string;
}

/**
 * Standard API error response.
 */
export interface ApiError {
  error: string;
  message: string;
  status_code: number;
  request_id?: string;
}

/**
 * Paginated response wrapper.
 */
export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  page_size: number;
  has_more: boolean;
}

/**
 * Generic API response wrapper for mutations.
 */
export interface ApiResponse<T> {
  data: T;
  message?: string;
}
