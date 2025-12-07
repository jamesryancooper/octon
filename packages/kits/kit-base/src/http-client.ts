/**
 * Shared HTTP client utilities for Harmony Kits.
 *
 * Provides standardized HTTP client infrastructure that all kit HTTP runners
 * can use to ensure consistent behavior, error handling, and observability.
 *
 * ## Usage
 *
 * ```typescript
 * import { createKitHttpClient, type KitHttpClientOptions } from '@harmony/kit-base';
 *
 * const client = createKitHttpClient({
 *   baseUrl: 'http://localhost:8080',
 *   kitName: 'guardkit',
 *   headers: { 'X-API-Key': 'secret' },
 *   timeoutMs: 30000,
 * });
 *
 * const result = await client.post('/check', { content: 'Hello' });
 * ```
 */

import { UpstreamProviderError, InputValidationError, type KitErrorJSON } from "./errors.js";

// ============================================================================
// Types
// ============================================================================

/**
 * Configuration options for the kit HTTP client.
 */
export interface KitHttpClientOptions {
  /** Base URL of the service (e.g., 'http://localhost:8080') */
  baseUrl: string;

  /** Kit name for error context */
  kitName: string;

  /** Custom fetch implementation (defaults to globalThis.fetch) */
  fetchImpl?: typeof fetch;

  /** Request timeout in milliseconds */
  timeoutMs?: number;

  /** Custom headers to include with every request */
  headers?: Record<string, string>;

  /** Enable request/response logging (for debugging) */
  debug?: boolean;
}

/**
 * HTTP client instance returned by createKitHttpClient.
 */
export interface KitHttpClient {
  /** Make a GET request */
  get<T = unknown>(path: string, options?: RequestOptions): Promise<KitHttpResponse<T>>;

  /** Make a POST request */
  post<T = unknown>(path: string, body: unknown, options?: RequestOptions): Promise<KitHttpResponse<T>>;

  /** Make a PUT request */
  put<T = unknown>(path: string, body: unknown, options?: RequestOptions): Promise<KitHttpResponse<T>>;

  /** Make a DELETE request */
  delete<T = unknown>(path: string, options?: RequestOptions): Promise<KitHttpResponse<T>>;

  /** Make a raw request (for non-standard methods) */
  request<T = unknown>(method: string, path: string, options?: RequestOptions): Promise<KitHttpResponse<T>>;

  /** The base URL this client is configured with */
  readonly baseUrl: string;

  /** The kit name this client is configured with */
  readonly kitName: string;
}

/**
 * Options for individual requests.
 */
export interface RequestOptions {
  /** Request body (for POST, PUT, etc.) */
  body?: unknown;

  /** Additional headers for this request */
  headers?: Record<string, string>;

  /** Override timeout for this request */
  timeoutMs?: number;

  /** Query parameters */
  params?: Record<string, string | number | boolean>;
}

/**
 * Standardized HTTP response wrapper.
 */
export interface KitHttpResponse<T = unknown> {
  /** Response data (parsed JSON) */
  data: T;

  /** HTTP status code */
  status: number;

  /** Response headers */
  headers: Headers;

  /** Whether the request was successful (2xx) */
  ok: boolean;
}

/**
 * Error response from a kit HTTP service.
 */
export interface KitHttpErrorResponse {
  success: false;
  error: {
    code: string;
    exitCode: number;
    message: string;
    details?: unknown;
    suggestedAction?: string;
  };
  _kit?: {
    name: string;
    version: string;
  };
}

// ============================================================================
// Implementation
// ============================================================================

/**
 * Ensure fetch is available.
 */
function ensureFetch(override?: typeof fetch): typeof fetch {
  const impl = override ?? globalThis.fetch;
  if (!impl) {
    throw new InputValidationError(
      "Kit HTTP client requires a fetch implementation (Node 18+ or polyfill).",
      { context: { requirement: "fetch" } }
    );
  }
  return impl;
}

/**
 * Build URL with query parameters.
 */
function buildUrl(base: string, path: string, params?: Record<string, string | number | boolean>): string {
  const url = new URL(path, base);
  if (params) {
    for (const [key, value] of Object.entries(params)) {
      url.searchParams.append(key, String(value));
    }
  }
  return url.toString();
}

/**
 * Check if response body looks like a kit error response.
 */
function isKitErrorResponse(body: unknown): body is KitHttpErrorResponse {
  return (
    typeof body === "object" &&
    body !== null &&
    "success" in body &&
    (body as Record<string, unknown>).success === false &&
    "error" in body
  );
}

/**
 * Create an HTTP client for kit services.
 *
 * The client provides a consistent interface for making HTTP requests to kit
 * services, with built-in error handling that converts HTTP errors to typed
 * KitErrors.
 *
 * @param options - Client configuration
 * @returns HTTP client instance
 *
 * @example
 * ```typescript
 * const client = createKitHttpClient({
 *   baseUrl: 'http://localhost:8080',
 *   kitName: 'guardkit',
 * });
 *
 * // POST request
 * const result = await client.post('/check', { content: 'Hello world' });
 *
 * // GET request with query params
 * const status = await client.get('/status', { params: { period: 'monthly' } });
 * ```
 */
export function createKitHttpClient(options: KitHttpClientOptions): KitHttpClient {
  const fetchImpl = ensureFetch(options.fetchImpl);
  const baseUrl = options.baseUrl.replace(/\/$/, "");
  const defaultHeaders: Record<string, string> = {
    "Content-Type": "application/json",
    ...options.headers,
  };

  async function makeRequest<T>(
    method: string,
    path: string,
    requestOptions?: RequestOptions
  ): Promise<KitHttpResponse<T>> {
    const url = buildUrl(baseUrl, path, requestOptions?.params);
    const headers = { ...defaultHeaders, ...requestOptions?.headers };
    const timeoutMs = requestOptions?.timeoutMs ?? options.timeoutMs;

    const fetchOptions: RequestInit = {
      method,
      headers,
    };

    if (requestOptions?.body) {
      fetchOptions.body = JSON.stringify(requestOptions.body);
    }

    if (timeoutMs) {
      fetchOptions.signal = AbortSignal.timeout(timeoutMs);
    }

    if (options.debug) {
      console.debug(`[${options.kitName}] HTTP ${method} ${url}`, {
        headers,
        body: requestOptions?.body,
      });
    }

    let response: Response;
    try {
      response = await fetchImpl(url, fetchOptions);
    } catch (error) {
      // Handle network errors, timeouts, etc.
      const message = error instanceof Error ? error.message : String(error);
      const isTimeout = message.includes("timeout") || message.includes("abort");

      throw new UpstreamProviderError(
        `${options.kitName} HTTP request failed: ${message}`,
        {
          provider: options.kitName,
          statusCode: isTimeout ? 408 : undefined,
          context: {
            endpoint: url,
            method,
            isTimeout,
          },
          cause: error instanceof Error ? error : undefined,
        }
      );
    }

    // Try to parse response body
    let data: T;
    const contentType = response.headers.get("content-type") || "";
    const isJson = contentType.includes("application/json");

    if (isJson) {
      try {
        data = (await response.json()) as T;
      } catch {
        data = {} as T;
      }
    } else {
      // For non-JSON responses, return text as data
      const text = await response.text();
      data = text as T;
    }

    if (options.debug) {
      console.debug(`[${options.kitName}] HTTP ${response.status}`, { data });
    }

    // Handle error responses
    if (!response.ok) {
      // Check if response is a structured kit error
      if (isKitErrorResponse(data)) {
        throw new UpstreamProviderError(data.error.message, {
          provider: options.kitName,
          statusCode: response.status,
          context: {
            endpoint: url,
            method,
            errorCode: data.error.code,
            exitCode: data.error.exitCode,
            details: data.error.details,
            suggestedAction: data.error.suggestedAction,
          },
        });
      }

      // Generic HTTP error
      const errorMessage = typeof data === "string" ? data : JSON.stringify(data);
      throw new UpstreamProviderError(
        `${options.kitName} HTTP ${response.status}: ${response.statusText}${errorMessage ? ` - ${errorMessage}` : ""}`,
        {
          provider: options.kitName,
          statusCode: response.status,
          context: {
            endpoint: url,
            method,
            responseBody: data,
          },
        }
      );
    }

    return {
      data,
      status: response.status,
      headers: response.headers,
      ok: true,
    };
  }

  return {
    get<T>(path: string, requestOptions?: RequestOptions) {
      return makeRequest<T>("GET", path, requestOptions);
    },

    post<T>(path: string, body: unknown, requestOptions?: RequestOptions) {
      return makeRequest<T>("POST", path, { ...requestOptions, body });
    },

    put<T>(path: string, body: unknown, requestOptions?: RequestOptions) {
      return makeRequest<T>("PUT", path, { ...requestOptions, body });
    },

    delete<T>(path: string, requestOptions?: RequestOptions) {
      return makeRequest<T>("DELETE", path, requestOptions);
    },

    request<T>(method: string, path: string, requestOptions?: RequestOptions) {
      return makeRequest<T>(method, path, requestOptions);
    },

    get baseUrl() {
      return baseUrl;
    },

    get kitName() {
      return options.kitName;
    },
  };
}

// ============================================================================
// HTTP Runner Base Types
// ============================================================================

/**
 * Base options for all kit HTTP runners.
 * Individual kits should extend this with kit-specific options.
 */
export interface BaseHttpRunnerOptions {
  /** Base URL of the service */
  baseUrl: string;

  /** Custom fetch implementation */
  fetchImpl?: typeof fetch;

  /** Request timeout in milliseconds */
  timeoutMs?: number;

  /** Custom headers */
  headers?: Record<string, string>;

  /** Enable run records (default: true) */
  enableRunRecords?: boolean;

  /** Directory to write run records */
  runsDir?: string;
}

/**
 * Type helper for creating kit-specific HTTP runner option types.
 *
 * @example
 * ```typescript
 * interface GuardKitHttpRunnerOptions extends BaseHttpRunnerOptions {
 *   blockThreshold?: 'critical' | 'high' | 'medium' | 'low';
 * }
 * ```
 */
export type HttpRunnerOptions<T extends Record<string, unknown> = Record<string, never>> =
  BaseHttpRunnerOptions & T;

