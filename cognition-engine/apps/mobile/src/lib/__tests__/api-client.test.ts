import { apiClient } from '../api-client';

// Mock fetch globally
const mockFetch = jest.fn();
global.fetch = mockFetch;

describe('ApiClient', () => {
  beforeEach(() => {
    mockFetch.mockClear();
  });

  describe('health', () => {
    it('should return healthy status when API is available', async () => {
      const mockResponse = {
        status: 'healthy',
        version: '0.1.0',
        timestamp: '2024-01-01T00:00:00Z',
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await apiClient.health();

      expect(result).toEqual(mockResponse);
      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('/health'),
        expect.objectContaining({
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
          }),
        })
      );
    });

    it('should throw error when API returns error response', async () => {
      const mockError = {
        error: 'Internal Server Error',
        message: 'Something went wrong',
        status_code: 500,
      };

      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
        statusText: 'Internal Server Error',
        json: async () => mockError,
      });

      await expect(apiClient.health()).rejects.toThrow('Something went wrong');
    });

    it('should handle network errors', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'));

      await expect(apiClient.health()).rejects.toThrow('Network error');
    });
  });
});
